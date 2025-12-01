# 📘 **README: Cloudflare Worker for Mautic Form Styling**

*Version: 1.0 — Updated for production use*

---

## 📝 **Overview**

This Cloudflare Worker injects **custom CSS styles** into **Mautic embed forms** that are loaded inside an iframe on pages within `mydomain.com`.

Since Mautic forms are embedded using:

```html
<script src="//mydomain.com/go/form/generate.js?id=1"></script>
<iframe src="//mydomain.com/go/form/1"></iframe>
```

…the iframe loads HTML content served from:

```
https://mydomain.com/go/form/*
```

Because this domain is under your control and behind Cloudflare, a Worker can intercept the HTML **before it reaches the browser**, allowing us to:

* Detect the Mautic form markup
* Locate the `<form>` with ID prefix `mauticform_`
* Inject a `<style>` element *directly after the closing `</form>` tag*
* Apply custom CSS to override Mautic’s default styles

This technique ensures full visual control over embedded forms without modifying Mautic or injecting JavaScript into the client side.

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

### **3. HTMLRewriter scans HTML and finds the target form**

Mautic forms always follow this pattern:

```html
<form id="mauticform_[formname]">
```

The worker uses a prefix selector:

```javascript
.on('form[id^="mauticform_"]', new MauticFormCSS())
```

### **4. Worker injects CSS directly after the form**

Using:

```javascript
el.after(`<style>${css}</style>`, { html: true });
```

This ensures:

✔ Styles remain scoped to the specific form
✔ No external CSS files required
✔ Styles override inline or embedded Mautic styles
✔ No JS execution needed in browser

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
      .on('form[id^="mauticform_"]', new MauticFormCSS())
      .transform(response);
  }
};

class MauticFormCSS {
  element(el) {

    const css = `
      /* ==========================================
         Custom Styles for ALL Mautic Forms
         ========================================== */

      /* Text fields */
      form[id^="mauticform_"] input[type="text"],
      form[id^="mauticform_"] input[type="email"],
      form[id^="mauticform_"] input[type="tel"],
      form[id^="mauticform_"] textarea,
      form[id^="mauticform_"] select {
        width: 100% !important;
        padding: 12px !important;
        border-radius: 6px !important;
        border: 2px solid #0066cc !important;
        margin-bottom: 10px !important;
        font-size: 16px !important;
        box-sizing: border-box !important;
      }

      /* Labels */
      form[id^="mauticform_"] label {
        font-weight: bold !important;
        margin-bottom: 6px !important;
        display: block !important;
      }

      /* Submit button */
      form[id^="mauticform_"] button[type="submit"],
      form[id^="mauticform_"] input[type="submit"] {
        background-color: #333 !important;
        color: #fff !important;
        font-size: 16px !important;
        padding: 12px 20px !important;
        border-radius: 6px !important;
        border: none !important;
        width: 100% !important;
        cursor: pointer !important;
        transition: background-color .2s ease-in-out !important;
      }

      form[id^="mauticform_"] button[type="submit"]:hover {
        background-color: #555 !important;
      }
    `;

    // Inject the styles immediately after the form
    el.after(`<style>${css}</style>`, { html: true });
  }
}
```

---

# 🛠 **Deployment Guide: Cloudflare Workers**

### **Step 1 — Create a new Worker**

Cloudflare Dashboard → Workers → *Create Worker*
Replace the placeholder code with the Worker code above.

---

# 🌐 **Step 2 — Add Worker Routes (Critical)**

To rewrite iframe content, you must bind the Worker to:

```
mydomain.com/go/form/*
*.mydomain.com/go/form/*
```

This ensures:

* The parent page is rewritten (if needed)
* The iframe HTML is rewritten
* Any subdomain (e.g., www) is included
* Bare domain `mydomain.com` is included

---

# 🔁 **Step 3 — Bypass cache for form paths**

Cloudflare Caching → Page Rules or Cache Rules:

```
URL: mydomain.com/go/form/*
Setting: Cache Level → Bypass
```

WHY?
Because cached HTML bypasses the Worker rewrite.

---

# 🧪 **Step 4 — Verify Worker Execution**

Open the iframe URL directly in a browser:

👉 **[https://mydomain.com/go/form/1](https://mydomain.com/go/form/1)**

View source, scroll to bottom of the form, check for:

```html
<style>/* your custom CSS */</style>
```

If it appears → Worker is active.

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

* Detect every `<form>` with ID starting `mauticform_`
* Inject a style block after the element stream

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

# 🔮 **Future Enhancements**

You can extend this Worker to:

### ✔ Per-form styling

Different CSS per form name:

```
form[id="mauticform_contactform"] { ... }
```

### ✔ Inject custom HTML blocks

E.g., GDPR messages, icons, required field notes

### ✔ Add Tailwind or bootstrap utility classes

Right inside the iframe

### ✔ Add button text overrides

E.g., change default Mautic “Submit” → “Send Message”

---

# 🎉 **Conclusion**

This Worker gives you **full visual control over Mautic forms** embedded inside your domain using iframes.
It is clean, server-side only, cache-safe, and works with all browsers since it outputs pure HTML/CSS.

If you want, I can also generate:

* A **dark mode version**
* A **per-form theme manager**
* A **version that rewrites form markup** (wrap inputs, add icons)
* A **version that injects JavaScript** via Cloudflare Worker (advanced)