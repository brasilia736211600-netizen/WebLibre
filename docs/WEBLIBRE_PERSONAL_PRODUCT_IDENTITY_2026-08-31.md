# WebLibre — Personal Product Identity

**Date:** 2026-08-31  
**Branch:** `weblibre-ua-mainline-v3`

## Product identity

This repository is the personal WebLibre derivative maintained and developed by **Braziao**.

The user-facing product identity should use the personal project identity rather than promotional identity inherited from the former upstream maintainer.

## What is intentionally removed from the product identity

- Former maintainer donation/support links.
- Former maintainer feedback/community promotion.
- Former maintainer GitHub promotion in the user-facing About/product presentation.
- Account/Sync service categories from the personal Settings UI.
- Automatic initialization of the former account callback service.
- Device-name transmission in the account sign-in handoff.
- Device-name persistence as account-sync source metadata.

## Legal boundary

WebLibre is derived from AGPL-licensed upstream code. Copyright, license, and attribution notices that the applicable license requires must remain. The personal product must not falsely claim authorship of inherited code.

Changing the visible product identity does not authorize deleting required legal notices or rewriting Git history to erase historical authorship.

## Privacy boundary

The personal build follows:

`NO SILENT TELEMETRY -> NO SILENT DEVICE IDENTIFIERS -> NO SILENT BACKGROUND USER-DATA UPLOAD -> EXPLICIT OPT-IN FOR OPTIONAL ONLINE SERVICES`

Normal user-directed browsing, searches, feeds, proxies/Tor, sharing, and explicitly enabled online functions remain browser functionality rather than being mislabeled as telemetry.

## Durable rule

Any new feature that transmits application-level user/device data must document:

1. exactly what data leaves the device;
2. destination/service;
3. trigger and whether it is user initiated;
4. retention/deletion behavior where known;
5. why the feature is necessary;
6. the user control/opt-in boundary.

No silent collection or transmission may be introduced merely because a dependency or upstream feature already exists.
