# WebLibre — Consolidated Android Runtime Validation Checklist

**Purpose:** one device validation pass for the browser foundation; this document does not claim runtime proof until the steps are actually exercised on a real Android device.

## Evidence rule

Record:
- exact APK/build identifier;
- app version/commit under test;
- device model and Android version;
- timestamp of each scenario;
- observed UA/container/proxy outcome;
- pass/fail and any logs/screenshots needed to reproduce a failure.

`SOURCE-VERIFIED` and `CI-VERIFIED` are not runtime proof.

## Preconditions

1. Use one integrated APK produced from a checkpoint whose source and CI state are already known.
2. Start from a clean, controlled app state unless the scenario explicitly tests restoration.
3. Use two distinct containers, A and B.
4. Assign visibly distinct UAs to A and B.
5. Configure distinct proxy behavior for A and B where supported by the existing UI/configuration.
6. Do not change implementation or settings mid-scenario unless the step explicitly requires it.

## Scenario 1 — Cold start / restored UA

1. Create/open a tab in Container A.
2. Navigate to a page that can expose the request User-Agent.
3. Record the observed UA and tab/container identity.
4. Fully terminate the app process.
5. Relaunch the app and allow normal restoration.
6. Verify the restored tab remains associated with Container A.
7. Verify the restored navigation uses Container A's persisted UA before/at first network navigation.

**Pass condition:** restored tab keeps its container identity and its persisted per-container UA.

## Scenario 2 — Container A/B isolation

1. Create one tab in A with UA-A.
2. Create one tab in B with UA-B.
3. Navigate both to a UA-reporting endpoint/page.
4. Record UA-A and UA-B independently.
5. Duplicate a tab in A and verify the duplicate remains in A with UA-A.
6. Duplicate a tab in B and verify the duplicate remains in B with UA-B.
7. Switch repeatedly between A and B and re-check both identities and UAs.

**Pass condition:** no tab crosses containers and no container receives the other container's UA.

## Scenario 3 — Restore isolation

1. Leave at least one meaningful tab in A and one in B.
2. Ensure both have distinct, observable UAs.
3. Terminate the app process.
4. Relaunch and wait for restoration to complete.
5. Verify each restored tab retains its original `contextId`/container identity.
6. Verify each restored tab uses its original container UA.

**Pass condition:** restoration does not collapse A/B into a shared UA or wrong container.

## Scenario 4 — Proxy A/B isolation

1. Configure the existing proxy path for A and B with intentionally distinguishable behavior/endpoints.
2. Navigate an A tab and record the observed proxy result.
3. Navigate a B tab and record the observed proxy result.
4. Switch between containers and repeat without changing configuration.
5. Verify A traffic remains on A's proxy path and B traffic remains on B's path.

**Pass condition:** proxy selection is isolated by container and does not leak across tabs/containers.

## Scenario 5 — Proxy fail-closed

1. Select a container whose proxy is configured through the existing fail-closed path.
2. Make the configured proxy unavailable or otherwise trigger the existing failure condition.
3. Attempt navigation.
4. Verify the app does not silently bypass the required proxy and send the request directly.
5. Restore valid proxy connectivity and verify normal navigation resumes.

**Pass condition:** required proxy failure blocks/breaks navigation rather than silently falling back to direct traffic.

## Scenario 6 — No cross-container mutation

1. Establish known A and B state: UA, proxy, and tabs.
2. Perform ordinary operations in A: open, duplicate, switch, close.
3. Verify B's tab list, UA, and proxy configuration remain unchanged.
4. Perform the corresponding operations in B.
5. Verify A remains unchanged.
6. Repeat once after app restoration if practical in the same session.

**Pass condition:** operations in one container do not mutate another container's state.

## Result matrix

| Scenario | Runtime result | Evidence |
|---|---|---|
| Cold start / restored UA | PENDING | — |
| Container A/B UA isolation | PENDING | — |
| Restore isolation | PENDING | — |
| Proxy A/B isolation | PENDING | — |
| Proxy fail-closed | PENDING | — |
| No cross-container mutation | PENDING | — |

## Stop conditions

Stop the validation pass and preserve evidence if any scenario fails. Do not compensate by changing multiple layers. Reproduce the first causal failure, inspect the existing call chain, and change only the minimum code required if source/runtime evidence proves the current implementation insufficient.

## Relationship to CI

The existing Quality workflow validates source/unit/native checks but cannot establish Android process-death or real-device network behavior. The release workflow already builds the native runtime and stable split-ABI APKs/app bundle. This checklist is therefore a manual/device validation checkpoint, not a replacement for CI.
