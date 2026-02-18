# METAR/TAF API Proxy Deployment

This folder contains proxy implementations to bypass CORS restrictions when accessing the Aviation Weather API from web browsers.

## Why Do I Need This?

The Aviation Weather API (aviationweather.gov) doesn't allow direct browser requests due to CORS (Cross-Origin Resource Sharing) restrictions. These proxies act as intermediaries that:

1. Receive requests from your Flutter web app
2. Fetch data from the Aviation Weather API (server-to-server, no CORS)
3. Return the data to your app with proper CORS headers

**Note:** Mobile and desktop apps don't have CORS restrictions, so proxies are only needed for web builds.

## Available Proxies

### 1. Cloudflare Worker (`cloudflare-worker.js`)

**Pros:**
- Fast global edge network
- Very simple deployment
- Free tier: 100,000 requests/day

**Deployment Steps:**

1. Go to https://workers.cloudflare.com/
2. Sign up for a free account
3. Click "Create a Service"
4. Choose "HTTP Handler" template
5. Replace the code with `cloudflare-worker.js`
6. Click "Save and Deploy"
7. Copy your worker URL (e.g., `https://metar-proxy.your-subdomain.workers.dev/?`)

**Usage:**
```dart
MetarTafFetcher.proxyUrls = [
  'https://metar-proxy.your-subdomain.workers.dev/?',
];
```

---

### 2. Vercel Edge Function (`vercel-edge-function.js`)

**Pros:**
- Better developer experience
- Git-based deployment
- Free tier: 100,000 requests/day, 100 GB-hrs compute/month

**Deployment Steps:**

1. Create a Vercel account at https://vercel.com
2. Create a new project (or use an existing one)
3. In your project root, create an `api` folder
4. Save `vercel-edge-function.js` as `api/metar-proxy.js`
5. Push to Git or run `vercel deploy`
6. Your function will be available at `https://your-app.vercel.app/api/metar-proxy?`

**Usage:**
```dart
MetarTafFetcher.proxyUrls = [
  'https://your-app.vercel.app/api/metar-proxy?',
];
```

---

## Using Both for Redundancy

Configure both proxies for automatic fallback:

```dart
void main() {
  MetarTafFetcher.proxyUrls = [
    'https://metar-proxy.your-subdomain.workers.dev/?',  // Cloudflare (1st)
    'https://your-app.vercel.app/api/metar-proxy?',      // Vercel (2nd)
  ];
  
  runApp(MyApp());
}
```

The package will automatically try the second proxy if the first hits rate limits (429) or fails.

---

## Per-Request Custom Proxies

Web-based users of your package can provide their own proxy URLs:

```dart
final result = await MetarTafFetcher.fetch(
  icao: 'EGBJ',
  dateTime: DateTime.now(),
  customProxyUrls: [
    'https://my-custom-proxy.com/?',
  ],
);
```

---

## Direct API Access (Mobile/Desktop Only)

For mobile and desktop apps, leave `proxyUrls` empty to call the API directly:

```dart
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  // Only use proxies on web
  if (kIsWeb) {
    MetarTafFetcher.proxyUrls = [
      'https://metar-proxy.your-subdomain.workers.dev/?',
    ];
  } else {
    MetarTafFetcher.proxyUrls = []; // Direct API access
  }
  
  runApp(MyApp());
}
```

---

## Security Notes

- Both proxies validate that only `aviationweather.gov` URLs are proxied
- CORS headers allow all origins (`*`) since this is a public API
- Rate limiting is handled by the Aviation Weather API itself
- Consider adding your own rate limiting or authentication if needed

---

## Troubleshooting

**"All attempts failed" error:**
- Check that your proxy URLs end with `?`
- Verify your proxies are deployed and accessible
- Check browser console for specific error messages

**429 Rate Limit errors:**
- You've exceeded 100k requests/day on a proxy
- The fallback system should automatically try the next proxy
- Consider deploying additional proxies or caching responses

**CORS errors on web:**
- Ensure you've configured `MetarTafFetcher.proxyUrls`
- Verify the proxy is returning proper CORS headers
- Check that the proxy URL format is correct

---

## Cost Estimates

Both services are free for reasonable usage:

| Service | Free Tier | Cost if Exceeded |
|---------|-----------|------------------|
| **Cloudflare Workers** | 100k req/day | $5/10M requests |
| **Vercel Edge Functions** | 100k req/day | $20/1M requests (beyond 1M) |

For 200k requests/day total (using both), you'll stay within free tiers.
