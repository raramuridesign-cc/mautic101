# Mautic .htaccess for security headers and embedding

This folder contains an Apache `.htaccess` template for a Mautic instance. It is primarily here to enable **safe embedding** of Mautic forms or pages on other domains using modern security headers.

## Why this exists for Mautic

Mautic often needs to be embedded in iframes (forms, landing pages, widgets) on sites that are **not** the Mautic domain. The legacy `X-Frame-Options: ALLOW-FROM` header is deprecated and no longer works in modern browsers. The supported approach is **Content-Security-Policy** with `frame-ancestors`.

## What is included

- `htaccess/.htaccess` - security headers for Mautic, including the CSP `frame-ancestors` rule used for embedding.

## Quick start

1. Copy `htaccess/.htaccess` into the root of your Mautic installation.
2. Ensure Apache allows `.htaccess` overrides (AllowOverride) and `mod_headers` is enabled.
3. Update the `frame-ancestors` directive to include the domain(s) that are allowed to embed your Mautic instance.
4. Test both the Mautic admin and the remote site that embeds the form.

## Configure frame-ancestors (important)

In `Content-Security-Policy`, update this line:

```
frame-ancestors 'self' https://site-a.com;
```

Notes:
- Add **all** allowed domains separated by spaces (no commas).
- Include the scheme (`https://`) and any required subdomains.
- If you need additional domains later, **update this list** accordingly.

## Compatibility and security notes

- Mautic admin relies on inline scripts/styles, so the CSP includes `'unsafe-inline'` and `'unsafe-eval'`. A stricter CSP will break the backend UI.
- `X-Frame-Options: SAMEORIGIN` is kept as a legacy fallback. Modern browsers prioritize `frame-ancestors`.
- `Strict-Transport-Security` should only be enabled when HTTPS is fully working, or you may lock yourself out.

## Testing and troubleshooting

1. Log into the Mautic admin and verify the dashboard loads and styling is intact.
2. Load the embedded form on the remote site.
3. If you see a browser error like "Refused to connect", check the console for the blocked domain and add it to `frame-ancestors`.
4. For a quick header check, run your site through:

```
https://securityheaders.com
```
