/**
 * Cloudflare Worker for METAR/TAF API CORS Proxy
 * 
 * This worker acts as a proxy to bypass CORS restrictions when accessing
 * the Aviation Weather API from web browsers.
 * 
 * Deploy to Cloudflare Workers:
 * 1. Sign up at https://workers.cloudflare.com/
 * 2. Create a new worker
 * 3. Paste this code
 * 4. Deploy
 * 5. Use the worker URL in MetarTafFetcher.proxyUrls
 * 
 * Example worker URL format:
 * https://metar-proxy.your-subdomain.workers.dev/?https://aviationweather.gov/api/data/metar
 * 
 * Free tier CloudFlare account: 100,000 requests/day
 */

export default {
  async fetch(request) {
    // Handle CORS preflight requests
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Max-Age': '86400',
        },
      });
    }

    try {
      const url = new URL(request.url);
      
      // Extract the target URL from the query parameter
      // Format: https://worker-url/?<target-url>?<params>
      const targetUrl = url.search.slice(1); // Remove the leading '?'
      
      if (!targetUrl) {
        return new Response('Missing target URL', { 
          status: 400,
          headers: { 'Access-Control-Allow-Origin': '*' }
        });
      }

      // Validate that we're only proxying aviationweather.gov
      if (!targetUrl.includes('aviationweather.gov')) {
        return new Response('Only aviationweather.gov URLs are allowed', { 
          status: 403,
          headers: { 'Access-Control-Allow-Origin': '*' }
        });
      }

      // Fetch from the target URL
      const response = await fetch(targetUrl, {
        method: request.method,
        headers: {
          'Accept': '*/*',
          'User-Agent': 'metar-taf-fetcher/1.0',
        },
      });

      // Clone the response and add CORS headers
      const modifiedResponse = new Response(response.body, response);
      modifiedResponse.headers.set('Access-Control-Allow-Origin', '*');
      modifiedResponse.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
      modifiedResponse.headers.set('Access-Control-Allow-Headers', '*');

      return modifiedResponse;

    } catch (error) {
      return new Response(`Proxy error: ${error.message}`, { 
        status: 500,
        headers: { 'Access-Control-Allow-Origin': '*' }
      });
    }
  }
};
