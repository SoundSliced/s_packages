/**
 * Vercel Edge Function for METAR/TAF API CORS Proxy
 * 
 * This edge function acts as a proxy to bypass CORS restrictions when accessing
 * the Aviation Weather API from web browsers.
 * 
 * Deploy to Vercel:
 * 1. Create a new Vercel project or use existing one
 * 2. Create an `api` folder in your project root
 * 3. Save this file as `api/metar-proxy.js`
 * 4. Deploy to Vercel (git push or `vercel deploy`)
 * 5. Use the edge function URL in MetarTafFetcher.proxyUrls
 * 
 * Example edge function URL format:
 * https://your-app.vercel.app/api/metar-proxy?https://aviationweather.gov/api/data/metar
 * 
 * Free tier: 100,000 requests/day, 100 GB-hrs compute/month
 */

export const config = {
  runtime: 'edge',
};

export default async function handler(request) {
  // Handle CORS preflight requests
  if (request.method === 'OPTIONS') {
    return new Response(null, {
      status: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': '*',
        'Access-Control-Max-Age': '86400',
      },
    });
  }

  try {
    const { searchParams } = new URL(request.url);
    
    // Extract the target URL from the query parameter
    // Format: /api/metar-proxy?<target-url>?<params>
    const targetUrl = request.url.split('?').slice(1).join('?');
    
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
      method: 'GET',
      headers: {
        'Accept': '*/*',
        'User-Agent': 'metar-taf-fetcher/1.0',
      },
    });

    // Clone the response body
    const body = await response.text();

    // Return with CORS headers
    return new Response(body, {
      status: response.status,
      headers: {
        'Content-Type': response.headers.get('Content-Type') || 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': '*',
        'Cache-Control': 'public, max-age=300', // Cache for 5 minutes
      },
    });

  } catch (error) {
    return new Response(`Proxy error: ${error.message}`, { 
      status: 500,
      headers: { 'Access-Control-Allow-Origin': '*' }
    });
  }
}
