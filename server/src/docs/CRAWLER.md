## Orello Context Engine

Orello is an AI-first customer support and navigation system. Its core capability is understanding any website it is embedded into and helping users take actions across it.

This document defines how Orello acquires, processes, and uses website context.

---

## 1. Objective

Enable Jenny (Orello’s AI assistant) to:

* Understand what a website does
* Understand page structure and navigation
* Guide users across routes
* Answer questions based on real site content
* Trigger or suggest actions (signup, demo, checkout, etc.)

---

## 2. System Overview

Orello uses a **3-layer context system**:

### 1. Sitemap Discovery

Maps the structure of the website.

### 2. Page Understanding

Extracts meaning and intent from each page.

### 3. Navigation Graph

Connects pages into actionable flows.

---

## 3. Sitemap Discovery

### Goal

Automatically generate a usable sitemap when none is provided.

### Method

* Start from root (`/`)
* Extract all anchor links (`<a href="">`)
* Normalize URLs:

  * Remove query params
  * Remove fragments
  * Keep same-domain only
* Crawl using BFS

### Constraints

* Max depth: 2–3
* Max pages: configurable (default: 50)
* Skip duplicates

### Output

```json
{
  "routes": [
    {
      "path": "/",
      "title": "Home",
      "linksTo": ["/pricing", "/features"]
    }
  ]
}
```

---

## 4. Page Understanding

### Goal

Convert raw HTML into structured, usable meaning.

### Extraction

From each page:

* Title
* Meta description
* Headings (H1, H2, H3)
* Paragraph content
* Buttons / CTAs
* Forms and inputs

### Transformation

Send extracted content to LLM → produce structured output:

```json
{
  "page": "/pricing",
  "intent": "Display pricing plans",
  "summary": "Shows subscription tiers and features",
  "actions": [
    "start free trial",
    "contact sales"
  ],
  "entities": [
    "Basic Plan",
    "Pro Plan"
  ]
}
```

### Storage

* Store as JSON
* Embed for semantic search

---

## 5. Navigation Graph

### Goal

Enable step-by-step user guidance.

### Structure

Directed graph of routes:

```json
{
  "edges": [
    { "from": "/", "to": "/pricing" },
    { "from": "/pricing", "to": "/signup" }
  ]
}
```

### Usage

* Suggest next steps
* Guide user journeys
* Recover lost users

---

## 6. Dynamic Site Handling

### Problem

Modern sites use client-side rendering (React, Next.js).

### Solution

Use headless browser:

* Wait for DOM render
* Wait for network idle
* Extract final DOM

### Additional Signals

* Detect route changes (SPA navigation)
* Capture button-triggered navigation

---

## 7. Hybrid Context Strategy

Scraping alone is unreliable. Orello supports augmentation.

### SDK Injection (Preferred)

```js
orello.init({
  routes: [...],
  actions: [...],
  context: [...]
})
```

### Benefits

* Higher accuracy
* Lower latency
* Developer control

---

## 8. Confidence Handling

Orello must not hallucinate.

If confidence is low:

* Ask clarifying questions
* Offer best guess with uncertainty

Example:

> “I think billing is under settings. Can you confirm?”

---

## 9. Constraints

* Respect robots.txt where applicable
* Avoid deep or aggressive crawling
* Cache results
* Re-crawl periodically
* Handle auth pages separately

---

## 10. Versioning Strategy

### V1

* Crawl homepage + 1 level
* Extract text + links
* Basic Q&A via embeddings

### V2

* Structured page understanding
* Navigation graph

### V3

* Real-time interaction tracking
* Behavior-aware responses

---

## 11. Key Principle

Orello is not a scraper.

Orello is:

> A system that understands and operates websites.

This means:

* Structure over raw HTML
* Intent over text
* Actions over information

---

## 12. Future Extensions

* User session awareness
* Personalized navigation
* Action execution (auto-fill, click simulation)
* API-level integrations (skip UI entirely)
