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

    // Inject the styles immediately after the form
    el.after(`<style>${css}</style>`, { html: true });
  }
}