# 📘 **README: Cloudflare Worker for Mautic Form Styling**

*Version: 1.0 — Updated for production use*

---

## 📝 **Overview**

This Cloudflare Worker injects **custom CSS styles** into **Mautic embed forms** on pages within `mydomain.com`, supporting both iframe and JavaScript embedding methods.

Mautic forms can be embedded using:

```html
<!-- JavaScript embed (loads form dynamically) -->
<script src="//mydomain.com/go/form/generate.js?id=1"></script>

<!-- Iframe embed -->
<iframe src="//mydomain.com/go/form/1"></iframe>
```

Forms may be served from various paths on your domain. The Worker intercepts HTML responses and injects CSS into the `<head>` element, ensuring styles are available for both static iframes and dynamically loaded forms.

This technique provides full visual control over embedded forms without modifying Mautic or injecting client-side JavaScript.

---

# 🚀 **How It Works**

### **1. Cloudflare Worker intercepts requests**

This line fetches the requested HTML (for both pages and iframes):

```javascript
const response = await fetch(request);
```

### **2. Worker inspects content type**

We only process HTML content (including variations like `text/html; charset=UTF-8`):

```javascript
if (!contentType.toLowerCase().includes("html")) {
  return response;
}
```

### **3. HTMLRewriter scans HTML and injects CSS into the head**

The worker targets the `<head>` element:

```javascript
.on('head', new InjectCSS())
```

### **4. Worker injects global CSS into the head**

Using:

```javascript
el.append(`<style>${css}</style>`, { html: true });
```

This ensures:

- ✔ Styles are globally available for all Mautic forms on the page
- ✔ Works for both iframe and JavaScript embedded forms
- ✔ No external CSS files required
- ✔ Styles override inline or embedded Mautic styles
- ✔ No JS execution needed in browser

---

# 📦 **Source Code**

```javascript
export default {
  async fetch(request, env, ctx) {

    const response = await fetch(request);

    // Match any HTML response (handles various charsets)
    const contentType = response.headers.get("Content-Type") || "";
    if (!contentType.toLowerCase().includes("html")) {
      return response;
    }

    return new HTMLRewriter()
      .on('head', new InjectCSS())
      .transform(response);
  }
};

class InjectCSS {
  element(el) {
    const css = `
      /* ==========================================
         Custom Styles for ALL Mautic Forms
         ========================================== */

      /* Text fields */
      form[id^="mauticform_"] input[type="text"], form[id^="mauticform_"] input[type="email"], form[id^="mauticform_"] input[type="tel"], form[id^="mauticform_"] textarea, form[id^="mauticform_"] select {
        width: 100% !important;
        padding: 5px 10px !important;
        border-radius: 5px !important;
        border: 1px solid #4e4e4e !important;
        margin-bottom: 5px !important;
        font-size: 14px !important;
        box-sizing: border-box !important;
      }
      form[id^="mauticform_"] textarea {
        height: 125px;
      }
      .mauticform-checkboxgrp-checkbox {
        height: 24px;
        width: 24px;
      }

      /* Labels */
      form[id^="mauticform_"] label, .mauticform-helpmessage {
        display: inline-block;
        font-size: 0.9em;
        margin-bottom: 5px;
        font-family: arial;
        font-weight: bold !important;
      }

      /* Submit button */
      form[id^="mauticform_"] button[type="submit"], form[id^="mauticform_"] input[type="submit"] {
        background-color: #0c2135 !important;
        color: #4ee3fd !important;
        font-size: 16px !important;
        padding: 12px 20px !important;
        border-radius: 6px !important;
        border: none !important;
        width: 100% !important;
        cursor: pointer !important;
        transition: background-color .2s ease-in-out !important;
      }

      form[id^="mauticform_"] button[type="submit"]:hover {
        background-color: #4ee3fd !important;
        color: #0c2135 !important;
      }

      .mauticform-errormsg {
        display: block;
        color: red;
        margin-top: 2px;
        font-family: arial;
        font-size: 0.8rem;
        font-style: italic;
      }
    `;

    el.append(`<style>${css}</style>`, { html: true });
  }
}
```

**Note:** For production deployment, minify the CSS string to reduce the worker's size and improve performance.

---

# 🛠 **Deployment Guide: Cloudflare Workers**

### **Step 1 — Create a new Worker**

Cloudflare Dashboard → Workers → *Create Worker*
Replace the placeholder code with the Worker code above.

---

# 🌐 **Step 2 — Add Worker Routes (Critical)**

Since Mautic forms can be served from any path on your domain, bind the Worker to cover all routes:

```
mydomain.com/*
*.mydomain.com/*
```

This ensures:

* All HTML pages on your domain are processed
* Both iframe and JavaScript embedded forms are styled
* Any subdomain (e.g., www) is included
* Forms from any folder/file are covered

---

# 🔁 **Step 3 — Bypass cache for form paths**

Cloudflare Caching → Page Rules or Cache Rules:

```
URL: mydomain.com/*
Setting: Cache Level → Bypass
```

WHY?
Because cached HTML bypasses the Worker rewrite.

---

# 🧪 **Step 4 — Verify Worker Execution**

Open any page with a Mautic form (iframe or JS embed) in a browser.

View source, check the `<head>` section for:

```html
<style>/* your custom CSS */</style>
```

If it appears → Worker is active and will style both embedding methods.

---

# 🐞 **Debugging Tips**

### 1️⃣ If changes do not appear

Check routes → this is the #1 cause.

### 2️⃣ If only partial content rewrites

Clear Cloudflare cache:

Cloudflare → Caching → Purge Cache → Purge Everything

### 3️⃣ If styles don’t apply

Mautic sometimes injects inline CSS → you must use:

```
!important
```

(which this Worker does)

### 4️⃣ If rewriting does not run for certain form IDs

Verify the form structure:

```html
<form id="mauticform_xxxxx">
```

All Mautic forms follow this pattern.

---

# ⚙️ **How HTMLRewriter Works Internally**

Cloudflare's HTMLRewriter:

* Streams HTML from the origin
* Parses element-by-element
* Allows you to modify, remove, or insert content
* Does NOT require loading the full DOM
* Is extremely fast (no performance penalty)

Our Worker uses this to:

* Detect the `<head>` element in HTML responses
* Inject a global style block into the head

---

# 🛡 **Security Notes**

* No client-side JavaScript is injected → clean and safe
* Styles are fully sandboxed inside the iframe content
* No CORS issues because the iframe domain matches the Worker domain
* No access to user-submitted form data

---

# 🚧 **Limitations**

* Cannot change CSS inside iframes from another domain
* Cannot inject JavaScript directly into iframe (HTMLRewriter only handles HTML/CSS)
* Must ensure Cloudflare caching does not override rewritten content

---

# 🎉 **Conclusion**

This Worker gives you **full visual control over Mautic forms** embedded on your domain using both iframe and JavaScript methods.
It is clean, server-side only, cache-safe, and works with all browsers since it outputs pure HTML/CSS.