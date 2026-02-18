# GitHub Pages: Multi-Page Sites — Issue & Solution

## Problem

The project has multiple HTML pages, for example:

- `index.html`
- `terms-and-conditions.html`
- `privacy-policy.html`

When deploying to GitHub Pages (e.g. using the `gh-pages` branch), the main page works:

- `https://username.github.io/repository-name/` → **works** (serves `index.html`)

But visiting other pages directly returns **404 Not Found**:

- `https://username.github.io/repository-name/terms-and-conditions.html` → 404
- `https://username.github.io/repository-name/privacy-policy.html` → 404

## Causes

1. **Missing or wrong path**  
   GitHub Pages only serves files that exist in the deployed branch at the correct path. If extra HTML files are not in that branch or are in a different folder, they will 404.

2. **Absolute paths**  
   Using absolute paths for links or assets breaks on GitHub Pages because the “root” is not the same as on a local server:

   - **Local:** site root might be `http://localhost/` or `file:///...`
   - **GitHub Pages:** site root is `https://username.github.io/repository-name/`

   So:

   - `href="/"` → goes to `https://username.github.io/` instead of your repo’s index.
   - `href="/privacy-policy.html"` → goes to `https://username.github.io/privacy-policy.html` (wrong repo path).
   - `<link href="/styles.css">` → requests `https://username.github.io/styles.css` and your CSS never loads.

## Solutions

### 1. Ensure all pages are on the deployed branch

- Use the same branch (e.g. `gh-pages`) or the same folder that GitHub Pages is configured to publish.
- Put all HTML files (e.g. `index.html`, `terms-and-conditions.html`, `privacy-policy.html`) in the root of that branch/folder so URLs like `.../terms-and-conditions.html` match the file path.

### 2. Use relative paths everywhere

- **Links to other pages:**  
  Use relative paths instead of absolute:
  - `index.html` or `./index.html` for the home page.
  - `terms-and-conditions.html`, `privacy-policy.html` for the other pages.
- **Assets (CSS, JS, images):**  
  Use relative paths from the current HTML file, e.g.:
  - `styles.css`, `script.js`, `assets/images/logo.png`  
  Avoid paths starting with `/` (e.g. `/styles.css`).
- **Navigation / footer links** (including those coming from locale or config):  
  Use the same relative paths (e.g. `"href": "privacy-policy.html"`) so they work from any page under `.../repository-name/`.

### 3. Optional: `<base href="...">` for asset root

If you need a single “root” for all assets, you can set:

```html
<base href="https://username.github.io/repository-name/">
```

Then paths like `/styles.css` resolve to that base. This ties the site to one URL and can be awkward for local development, so relative paths are usually simpler.

## Summary

| Do | Avoid |
|----|--------|
| Put all HTML and assets in the published branch/folder | Deploying only `index.html` or moving pages to a different path |
| Use relative links: `index.html`, `privacy-policy.html` | Absolute links: `href="/"`, `href="/privacy-policy.html"` |
| Use relative asset paths: `styles.css`, `assets/...` | Absolute asset paths: `/styles.css`, `/assets/...` |

Applying these in this repo fixes the 404s and broken CSS/JS when the site is viewed at `https://username.github.io/repository-name/`.
