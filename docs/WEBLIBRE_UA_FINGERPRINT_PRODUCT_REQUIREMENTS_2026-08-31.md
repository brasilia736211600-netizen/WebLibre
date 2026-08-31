# WebLibre — UA & Browser Fingerprint Product Requirements

**Date:** 2026-08-31  
**Status:** Research/requirements only; no implementation implied by this document.  
**Purpose:** capture the newly observed UX/runtime requirements and benchmark the desired per-profile identity controls against current anti-detect/profile browsers without prematurely expanding architecture.

## User-observed findings from the first Android runtime pass

1. The installed validation build feels relatively heavy during use. This is an observation, not yet a measured performance regression.
2. Previously visited pages should not be unnecessarily reloaded as if they were first visits. The desired behavior is to preserve normal browser/cache/session behavior and avoid avoidable reloads during tab/session restoration. This is a requirement to investigate, not evidence that HTTP/WebView cache is currently disabled.
3. The current UA experience is too primitive for the intended product: it exposes a raw UA value rather than a professional profile editor with OS/browser/version templates and compatibility-aware combinations.
4. A useful profile should be selectable/customizable by coherent identity dimensions rather than requiring users to manually construct opaque UA strings.
5. The desired direction is broader than UA alone: a per-container/browser-profile identity should be internally consistent across browser, OS/platform, display metrics, locale/timezone, network/proxy, and relevant browser fingerprint surfaces, while remaining compatible with the actual capabilities of the underlying engine.

## Benchmark findings (current products)

### GoLogin
Current documentation describes profile-level OS choices including Windows 10, Windows 11, Mac Intel, Mac ARM, Linux, and Android. It also exposes fingerprint settings covering User-Agent, Chromium/Orbita version, screen resolution, languages, platform, CPU threads, RAM, Do Not Track, fonts, media devices, Canvas, WebGL, AudioContext, ClientRects, and WebRTC. GoLogin recommends keeping strongly related values consistent rather than changing them independently.  
Sources: GoLogin profile settings and fingerprint settings documentation.

### Multilogin
Current documentation describes isolated browser profiles with their own cookies, session data, proxy settings, and browser fingerprint. Its fingerprint settings include WebRTC, timezone, geolocation, languages, screen resolution, fonts, media devices, Navigator, WebGL, Canvas, AudioContext, and port-scan protection. It also distinguishes Chromium-like Mimic from Firefox-like Stealthfox and provides profile templates.  
Sources: Multilogin profile setup, fingerprint section, and feature documentation.

### AdsPower
Current documentation describes predefined screen-resolution behavior that can follow the selected User-Agent/device type, rather than treating resolution as an unrelated free-form field. Its migration documentation also exposes the breadth of profile state typically modeled together: User-Agent, browser kernel, WebRTC, Flash, Canvas, Audio, WebGL, fonts, media devices, geolocation, timezone, port-scan protection, resolution, hardware concurrency, Do Not Track, language, proxy, and device metadata.  
Sources: AdsPower fingerprint and profile-transfer documentation.

### Kameleo
Current documentation emphasizes coherent fingerprints: locale/languages, timezone, screen/window metrics, media capabilities, browser feature switches/client hints, WebRTC, WebGL, Canvas, fonts, and proxy/geolocation. It explicitly warns that arbitrary independent UA changes can create impossible combinations and recommends letting the profile system keep tightly linked parameters aligned.  
Sources: Kameleo fingerprint documentation and profile-management documentation.

## Product direction for WebLibre

The target should be a **profile-based identity editor**, not a raw UA-string box.

A profile should have at least these conceptual groups:

- **Platform:** Android, Windows, Linux, macOS, and only other platforms that the underlying engine can emulate coherently.
- **Browser family:** Chromium/Chrome, Firefox/Gecko, and other browser families only where the underlying engine can actually provide compatible behavior. Safari/WebKit should not be offered as a cosmetic UA-only choice when the engine cannot reproduce WebKit semantics.
- **Browser version:** supported versions/ranges tied to the engine build and capability set.
- **Device/display:** device class, screen/window resolution, device pixel ratio, touch capability, color depth, and related metrics where technically controllable.
- **Locale:** language(s), locale, timezone, and optional geolocation, with consistency rules.
- **Network:** proxy configuration and IP-derived defaults/consistency.
- **Navigator/hardware signals:** platform, hardware concurrency, memory reporting, media devices, Do Not Track, and other fields only where the browser stack can control them without destabilizing sites.
- **Rendering/fingerprint surfaces:** Canvas, WebGL, AudioContext, ClientRects, fonts, and WebRTC behavior, only to the degree supported by the actual engine.
- **Profile lifecycle:** persistent profile identity, cloning, duplication, reset/new fingerprint, import/export where later justified.

## Consistency rules

The product should prefer **coherent preset profiles** over arbitrary independent combinations. Examples:

- OS + browser family + browser version must form a supported tuple.
- Mobile/desktop device class should constrain plausible display/touch values.
- Browser version should align with the actual engine capabilities and any UA/client-hint reporting.
- Locale/timezone/geolocation should be optionally aligned with the configured proxy location.
- Changing a core identity field after a profile has been used should warn that websites may see a new device identity.
- Hardware values reported to websites are not the same as changing real device performance; UI should keep that distinction explicit.

## Important non-goals

- Do not copy every feature of commercial anti-detect browsers indiscriminately.
- Do not add fingerprint spoofing surfaces that the current Android engine cannot implement consistently.
- Do not add a second database or new persistence system when existing ContainerMetadata/profile persistence is sufficient.
- Do not implement large UI/catalog work before the restore/session UA defect is fixed and the core runtime path is proven.
- Do not claim 'anti-detect' or fingerprint quality from UA-string customization alone.

## Performance and navigation requirement

The perceived heaviness and page-reload behavior are separate investigations from UA design.

Required future measurement before optimization:
- cold start time;
- time to first usable page after restore;
- memory footprint at idle and with multiple tabs/containers;
- frequency and cause of unnecessary page reloads;
- cache hit/miss behavior where observable;
- whether restored sessions recreate engine sessions unnecessarily;
- APK size breakdown by native runtime/assets/features before removing functionality.

Only remove functionality after evidence shows a feature contributes materially to APK size, memory, startup time, or runtime work and is not required by the product specification.

## Implementation ordering

Current blocker remains the first runtime failure: persisted per-container UA is lost on restored navigation. The immediate implementation task is therefore still root-cause inspection and minimum correction of the restore/session UA path.

After Scenario 1 is fixed and revalidated:
1. finish the consolidated runtime scenarios;
2. measure performance/page-reload behavior;
3. design the smallest coherent UA/profile editor based on this requirements document;
4. implement only the fingerprint controls that the existing Gecko/Android stack can support consistently;
5. validate each profile dimension against actual network and JavaScript-observable values.

This document is requirements/research evidence, not a commitment to implement all listed commercial features.
