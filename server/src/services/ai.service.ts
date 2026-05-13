import { google } from '@ai-sdk/google';
import { generateText, Output } from 'ai';
import { z } from 'zod';

/**
 * Schema for a single page's understanding.
 */
export const PageUnderstandingSchema = z.object({
  path: z.string().describe('The URL path of the page'),
  title: z.string().describe('The page title'),
  intent: z.string().describe('The primary purpose or user intent of this page'),
  summary: z.string().describe('A concise summary of the page content'),
  actions: z.array(z.string()).describe('List of possible user actions (e.g., "sign up", "contact sales")'),
  entities: z.array(z.string()).describe('Key entities or features mentioned on the page'),
  linksTo: z.array(z.string()).describe('Internal links discovered on this page'),
});

/**
 * Schema for the entire site's understanding.
 */
export const SitemapUnderstandingSchema = z.object({
  pages: z.array(PageUnderstandingSchema),
  siteSummary: z.string().describe('An overall summary of what the website does'),
});

export type SitemapUnderstanding = z.infer<typeof SitemapUnderstandingSchema>;

class AiService {
  /**
   * Processes raw crawled website data and uses an LLM to generate a structured
   * understanding of the site's intent, pages, and actions.
   * 
   * @param crawledData The raw output from the WebsiteCrawler
   * @returns Structured sitemap and site summary
   */
  async understandSitemap(crawledData: any): Promise<SitemapUnderstanding> {
    try {
      const { output } = await generateText({
        model: google('gemini-2.5-flash'),
        system: 'You are Orello Site Analyst. Your job is to transform raw website crawl data into structured intelligence for an AI customer support agent.',
        prompt: `
          Analyze the following crawled website data. 
          For each page, identify its intent, provide a summary, list actionable steps a user can take, and extract key entities.
          Also provide an overall summary of the entire website.

          Raw Crawled Data:
          ${JSON.stringify(crawledData, null, 2)}
        `,
        // Use the new output parameter instead of generateObject
        output: Output.object({
          schema: SitemapUnderstandingSchema,
        }),
      });

      return output;
    } catch (error) {
      console.error('[AiService] Error understanding sitemap:', error);
      throw error;
    }
  }
}

const aiService = new AiService();
export default aiService;