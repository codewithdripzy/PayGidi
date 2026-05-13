import axios from 'axios';
import * as cheerio from 'cheerio';
import { URL } from 'url';

/**
 * Metadata extracted from a single webpage.
 */
export interface PageMetadata {
  url: string;
  path: string;
  title: string;
  description?: string;
  headings: {
    h1: string[];
    h2: string[];
    h3: string[];
  };
  paragraphs: string[];
  buttons: string[];
  forms: {
    action?: string;
    method?: string;
    inputs: { name?: string; type?: string; placeholder?: string }[];
  }[];
  linksTo: string[];
}

/**
 * The final output of the crawling process.
 */
export interface CrawlResult {
  routes: {
    path: string;
    title: string;
    linksTo: string[];
  }[];
  pages: PageMetadata[];
  navigationGraph: { from: string; to: string }[];
}

/**
 * Options for the crawler.
 */
export interface CrawlerOptions {
  maxDepth?: number;
  maxPages?: number;
  timeout?: number;
}

/**
 * WebsiteCrawler handles discovery and extraction of website content.
 * It uses a BFS approach to map out the site structure and extract semantic meaning.
 * 
 * Implements requirements from CRAWLER.md
 */
export class WebsiteCrawler {
  private visited = new Set<string>();
  private queue: { url: string; depth: number }[] = [];
  private results: PageMetadata[] = [];
  private baseUrl: string = '';
  private domain: string = '';

  constructor(private options: CrawlerOptions = { maxDepth: 2, maxPages: 50, timeout: 10000 }) {
    // Ensure defaults if partial options provided
    this.options.maxDepth = this.options.maxDepth ?? 2;
    this.options.maxPages = this.options.maxPages ?? 50;
    this.options.timeout = this.options.timeout ?? 10000;
  }

  /**
   * Starts the crawling process from a base URL.
   */
  async crawl(startUrl: string): Promise<CrawlResult> {
    // Reset state for new crawl
    this.visited.clear();
    this.queue = [];
    this.results = [];

    try {
      const urlObj = new URL(startUrl);
      this.baseUrl = urlObj.origin;
      this.domain = urlObj.hostname;
      
      // Start BFS
      this.queue.push({ url: startUrl, depth: 0 });

      while (this.queue.length > 0 && this.results.length < (this.options.maxPages || 50)) {
        const current = this.queue.shift();
        if (!current) break;

        const { url, depth } = current;

        // Skip if already visited (normalize to avoid variants)
        const normalizedUrl = this.normalizeFullUrl(url);
        if (this.visited.has(normalizedUrl)) continue;
        this.visited.add(normalizedUrl);

        if (depth > (this.options.maxDepth || 2)) continue;

        try {
          console.log(`[Crawler] Processing: ${url} (Depth: ${depth})`);
          const pageData = await this.processPage(url);
          this.results.push(pageData);

          // Add newly discovered internal links to queue
          for (const linkPath of pageData.linksTo) {
            const absoluteUrl = new URL(linkPath, this.baseUrl).href;
            const normalizedLink = this.normalizeFullUrl(absoluteUrl);
            
            if (!this.visited.has(normalizedLink)) {
              this.queue.push({ url: absoluteUrl, depth: depth + 1 });
            }
          }
        } catch (error) {
          console.error(`[Crawler] Failed to process ${url}:`, error instanceof Error ? error.message : error);
        }
      }

      return this.formatResults();
    } catch (error) {
      console.error('[Crawler] Critical error during crawl:', error);
      throw error;
    }
  }

  /**
   * Fetches and parses a single page.
   */
  private async processPage(url: string): Promise<PageMetadata> {
    const response = await axios.get(url, {
      headers: {
        'User-Agent': 'OrelloBot/1.0 (+https://orello.ai)',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      },
      timeout: this.options.timeout,
      // Handle redirects automatically
      maxRedirects: 5,
    });

    const html = response.data;
    const $ = cheerio.load(html);
    const parsedUrl = new URL(url);

    // Extraction logic based on CRAWLER.md (Section 4: Page Understanding)
    const metadata: PageMetadata = {
      url,
      path: parsedUrl.pathname,
      title: $('title').text().trim() || $('h1').first().text().trim() || 'Untitled Page',
      description: $('meta[name="description"]').attr('content') || $('meta[property="og:description"]').attr('content'),
      headings: {
        h1: this.extractText($, 'h1'),
        h2: this.extractText($, 'h2'),
        h3: this.extractText($, 'h3'),
      },
      paragraphs: this.extractText($, 'p').filter(text => text.length > 40), // Filter out short fragments
      buttons: this.extractText($, 'button, a.btn, a.button, [role="button"]'),
      forms: this.extractForms($),
      linksTo: this.extractInternalLinks($, url),
    };

    return metadata;
  }

  /**
   * Helper to extract trimmed text from elements.
   */
  private extractText($: cheerio.CheerioAPI, selector: string): string[] {
    const results: string[] = [];
    $(selector).each((_, el) => {
      const text = $(el).text().trim();
      if (text && !results.includes(text)) {
        results.push(text);
      }
    });
    return results;
  }

  /**
   * Extracts form structures from the page.
   */
  private extractForms($: cheerio.CheerioAPI): PageMetadata['forms'] {
    const forms: PageMetadata['forms'] = [];
    $('form').each((_, el) => {
      const $form = $(el);
      forms.push({
        action: $form.attr('action'),
        method: $form.attr('method'),
        inputs: $form.find('input, select, textarea').map((_, input) => {
          const $input = $(input);
          return {
            name: $input.attr('name'),
            type: $input.attr('type') || input.tagName,
            placeholder: $input.attr('placeholder'),
          };
        }).get(),
      });
    });
    return forms;
  }

  /**
   * Extracts and normalizes internal links for BFS.
   * Normalize: Remove query params, fragments, keep same-domain only (Section 3).
   */
  private extractInternalLinks($: cheerio.CheerioAPI, currentUrl: string): string[] {
    const internalLinks = new Set<string>();
    
    $('a[href]').each((_, el) => {
      const href = $(el).attr('href');
      if (!href || href.startsWith('#') || href.startsWith('javascript:')) return;

      try {
        const absoluteUrl = new URL(href, currentUrl);
        
        // Ensure same domain (Section 3)
        if (absoluteUrl.hostname === this.domain) {
          const path = absoluteUrl.pathname;
          
          // Skip non-page assets
          if (!path.match(/\.(png|jpg|jpeg|gif|svg|pdf|zip|css|js|woff|woff2|xml|json|ico)$/i)) {
            internalLinks.add(path === '' ? '/' : path);
          }
        }
      } catch (e) {
        // Ignore malformed URLs
      }
    });

    return Array.from(internalLinks);
  }

  /**
   * Normalizes a URL to a consistent string for the "visited" set.
   * Removes query params and fragments as per CRAWLER.md
   */
  private normalizeFullUrl(url: string): string {
    try {
      const u = new URL(url);
      u.hash = ''; 
      u.search = ''; 
      return u.href.toLowerCase().replace(/\/$/, ''); 
    } catch (e) {
      return url.toLowerCase();
    }
  }

  /**
   * Formats the accumulated results into the structure defined in CRAWLER.md.
   */
  private formatResults(): CrawlResult {
    const routes = this.results.map(p => ({
      path: p.path,
      title: p.title,
      linksTo: p.linksTo,
    }));

    const navigationGraph: { from: string; to: string }[] = [];
    this.results.forEach(page => {
      page.linksTo.forEach(targetPath => {
        navigationGraph.push({ from: page.path, to: targetPath });
      });
    });

    return {
      routes,
      pages: this.results,
      navigationGraph,
    };
  }
}

/**
 * Convenience function to crawl a site.
 */
export const crawlWebsite = async (url: string, options?: CrawlerOptions) => {
  const crawler = new WebsiteCrawler(options);
  return crawler.crawl(url);
};
