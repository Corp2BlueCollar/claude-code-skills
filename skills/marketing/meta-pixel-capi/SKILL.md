---
name: meta-pixel-capi
description: Meta Pixel and Conversions API (CAPI) setup, testing, configuration, and troubleshooting. Use when implementing tracking, debugging pixel events, or setting up server-side CAPI.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, WebSearch, WebFetch
user-invocable: true
---

# Meta Pixel & Conversions API (CAPI) Skill

Use this skill for implementing, testing, and debugging Meta Pixel (Facebook Pixel) and the Meta Conversions API for server-side tracking.

## Quick Reference

### Meta Pixel ID Format
- 15-16 digit number (e.g., `3798381640464914`)
- Found in Meta Events Manager > Data Sources > Your Pixel

### Standard Events (use these, not custom events)
| Event | When to Fire | Key Parameters |
|-------|--------------|----------------|
| `PageView` | Every page load | None required |
| `ViewContent` | Product/content pages | `content_name`, `content_category` |
| `Lead` | Form submit, CTA click | `content_name`, `content_category` |
| `Schedule` | Booking/appointment confirmed | `content_name`, `value`, `currency` |
| `Purchase` | Transaction complete | `value`, `currency`, `content_ids` |
| `Contact` | Contact form submitted | `content_name` |

## Implementation Checklist

### 1. Base Pixel Installation (Client-Side)

Add to `<head>` of every page:

```html
<!-- Meta Pixel Code -->
<script>
!function(f,b,e,v,n,t,s)
{if(f.fbq)return;n=f.fbq=function(){n.callMethod?
n.callMethod.apply(n,arguments):n.queue.push(arguments)};
if(!f._fbq)f._fbq=n;n.push=n;n.loaded=!0;n.version='2.0';
n.queue=[];t=b.createElement(e);t.async=!0;
t.src=v;s=b.getElementsByTagName(e)[0];
s.parentNode.insertBefore(t,s)}(window, document,'script',
'https://connect.facebook.net/en_US/fbevents.js');
fbq('init', 'YOUR_PIXEL_ID');
// Generate eventID for CAPI deduplication
window._fbqPageViewId = 'PageView_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
fbq('track', 'PageView', {}, {eventID: window._fbqPageViewId});
</script>
<noscript><img height="1" width="1" style="display:none"
src="https://www.facebook.net/tr?id=YOUR_PIXEL_ID&ev=PageView&noscript=1"
/></noscript>
<!-- End Meta Pixel Code -->
```

### 2. CAPI Server-Side Setup (Vercel/Node.js)

Create `/api/meta-capi.js`:

```javascript
export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { event_name, event_time, event_source_url, event_id, user_data, custom_data } = req.body;

  const payload = {
    data: [{
      event_name,
      event_time: event_time || Math.floor(Date.now() / 1000),
      event_source_url,
      event_id, // CRITICAL: Must match client-side eventID for deduplication
      action_source: 'website',
      user_data: {
        client_ip_address: req.headers['x-forwarded-for'] || req.socket.remoteAddress,
        client_user_agent: req.headers['user-agent'],
        fbc: user_data?.fbc || null,
        fbp: user_data?.fbp || null,
      },
      custom_data: custom_data || {}
    }]
  };

  const response = await fetch(
    `https://graph.facebook.com/v18.0/${process.env.META_PIXEL_ID}/events?access_token=${process.env.META_CAPI_TOKEN}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    }
  );

  const result = await response.json();
  res.status(response.ok ? 200 : 500).json(result);
}
```

### 3. Client-Side CAPI Helper

```javascript
function generateEventId(eventName) {
  return eventName + '_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
}

function getCookie(name) {
  return document.cookie.split('; ').reduce((r, v) => {
    const parts = v.split('=');
    return parts[0] === name ? decodeURIComponent(parts[1]) : r;
  }, '');
}

function sendCAPI(eventName, customData, eventId) {
  fetch('/api/meta-capi', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      event_name: eventName,
      event_time: Math.floor(Date.now() / 1000),
      event_source_url: window.location.href,
      event_id: eventId,
      user_data: { fbc: getCookie('_fbc'), fbp: getCookie('_fbp') },
      custom_data: customData || {}
    })
  }).catch(() => {});
}

// Fire event with deduplication
function trackMetaStandard(eventName, params) {
  var eventId = generateEventId(eventName);

  // Client-side pixel with eventID
  if (typeof fbq !== 'undefined') {
    fbq('track', eventName, params || {}, { eventID: eventId });
  }

  // Server-side CAPI with matching event_id
  sendCAPI(eventName, params || {}, eventId);
}
```

## Event Deduplication (CRITICAL)

**The #1 cause of inaccurate conversion data is duplicate events.**

### How Deduplication Works
1. Generate a unique `event_id` for each event
2. Pass the SAME `event_id` to both Pixel (`eventID` option) and CAPI (`event_id` field)
3. Meta deduplicates based on matching `event_id` within a 48-hour window

### Common Mistakes
- Firing Pixel without `eventID` option
- Generating different IDs for Pixel vs CAPI
- Not passing `event_id` to CAPI at all

## Testing Protocol

### 1. Install Meta Pixel Helper (Chrome Extension)
- Shows all pixel events firing on the page
- Displays event parameters and errors
- **Green checkmark** = event fired successfully

### 2. Check Meta Events Manager
1. Go to Events Manager > Your Pixel > Test Events
2. Open your site in a new tab
3. Events should appear in real-time
4. Check "Deduplication" tab for CAPI matching

### 3. Verify CAPI in Events Manager
- Look for "Browser" and "Server" columns
- Events should show in both columns
- "Match Rate" should be 80%+ (ideally 95%+)

### 4. Debug Common Issues

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| No events in Pixel Helper | Pixel not installed, ad blocker | Check `<head>` code, disable blocker |
| Events fire but no CAPI | Server endpoint failing | Check `/api/meta-capi` logs |
| Duplicate events in Events Manager | Missing eventID deduplication | Add `eventID` to Pixel, match in CAPI |
| Low match rate | Missing fbp/fbc cookies | Ensure cookies are being read |
| Schedule not firing | Third-party iframe (GHL, Calendly) | See iframe detection section |

## Third-Party Booking Widget Integration (GHL, Calendly, etc.)

### The Problem
Booking widgets like GoHighLevel (GHL), Calendly, and others run in cross-origin iframes. They often:
- Don't send postMessage events on booking completion
- Show confirmation inside the iframe (no URL change)
- Block MutationObserver access (cross-origin)

### Detection Strategies

```javascript
function initBookingWidget() {
  var bookingFired = false;

  function onBookingComplete(source) {
    if (bookingFired) return;
    bookingFired = true;
    trackMetaStandard('Schedule', {
      content_name: 'Booking',
      value: 100,
      currency: 'USD'
    });
  }

  // Strategy 1: postMessage listener (if widget sends events)
  window.addEventListener('message', function(e) {
    var data = e.data;

    // GHL/BoothLaunchPad format
    if (Array.isArray(data) && data[0] === 'msgsndr-booking-complete') {
      onBookingComplete('postMessage');
      return;
    }

    // BoothLaunchPad sticky contacts signal
    if (typeof data === 'string') {
      try {
        var parsed = JSON.parse(data);
        if (parsed.action === 'set-sticky-contacts' && parsed.leadCollected) {
          onBookingComplete('sticky-contacts');
        }
      } catch (e) {}
    }

    // Generic booking complete detection
    if (typeof data === 'object' && data.event) {
      var evt = data.event.toLowerCase();
      if (evt.indexOf('booking') !== -1 && evt.indexOf('complete') !== -1) {
        onBookingComplete('postMessage-generic');
      }
    }
  });

  // Strategy 2: Iframe load detection (KEY FALLBACK)
  // When booking completes, iframe navigates from form to confirmation
  var iframe = document.getElementById('booking-embed');
  if (iframe) {
    var loadCount = 0;
    iframe.addEventListener('load', function() {
      loadCount++;
      // First load = initial form, second load = confirmation
      if (loadCount >= 2) {
        onBookingComplete('iframe-load');
      }
    });
  }

  // Strategy 3: Thank-you page fallback
  if (window.location.pathname.match(/thank-?you/i)) {
    onBookingComplete('thank-you-page');
  }
}
```

### Best Practice: Configure Widget Redirect
If possible, configure the booking widget to redirect to your `/thank-you` page after booking. This is the most reliable method.

## Environment Variables

```bash
# .env or .env.local
META_PIXEL_ID=your_pixel_id
META_CAPI_TOKEN=your_capi_access_token
```

### Getting CAPI Access Token
1. Go to Events Manager > Settings > Conversions API
2. Click "Generate access token"
3. Copy and store securely (it won't be shown again)

## Event Match Quality (EMQ)

Target EMQ score: **6.0 or higher** (out of 10)

### Improve EMQ by sending:
- `client_ip_address` (from request headers)
- `client_user_agent` (from request headers)
- `fbp` cookie (Meta's browser ID)
- `fbc` cookie (click ID from ads)
- Hashed email (SHA256) if available
- Hashed phone (SHA256) if available

## Quick Diagnosis Commands

```bash
# Check if pixel is in HTML files
grep -r "fbq('init'" --include="*.html"

# Check for CAPI endpoint
grep -r "meta-capi" --include="*.js"

# Check for eventID deduplication
grep -r "eventID\|event_id" --include="*.js"

# Find all pixel event calls
grep -r "fbq('track'" --include="*.js" --include="*.html"
```

## Resources

- [Meta Events Manager](https://business.facebook.com/events_manager)
- [Meta Pixel Helper Chrome Extension](https://chrome.google.com/webstore/detail/meta-pixel-helper/)
- [Conversions API Documentation](https://developers.facebook.com/docs/marketing-api/conversions-api)
- [Event Setup Tool](https://business.facebook.com/events_manager/pixel/setup)
