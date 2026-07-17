# Onboarding & D1 retention — status and follow-up

Last updated: 2026-07-17. Follow up when the next ~10–15 users have come in.

## Status

The new onboarding (shipped 2026-07-08, commits `2bf947b`..`b991e71`) got its first
cohort: 12 users, 0 confirmed D1 returns. Per-user analysis showed the funnel
mechanics mostly *work* — the losses came from a crash, a too-early notification
prompt, and users churning right after finishing the tutorial. Three fixes were
made on 2026-07-17 (see below) and need to be released, then re-measured against
the next cohort.

Caveat to keep in mind: at n=12, 0 D1 returns was statistically compatible with
the old ~8% baseline all along. Everything here is directional, not proof.

## How we got there

1. **Funnel exploration first** — showed "75% abandoned before Get Started".
   This turned out to be partly an artifact: GA4 funnels require strict timestamp
   order, and `welcome_get_started_clicked` / `user_created` /
   `onboarding_welcome_seeded` / `example_note` all fire in the same ~1s burst,
   so same-second jitter causes phantom drop-offs. Closed funnels also silently
   exclude users whose `first_open` predates the date range.
2. **User Explorer (per-user event streams) second** — this was the useful tool
   at this scale. Reading each of the 12 users individually gave a different and
   more actionable picture.

### Cohort 1 scorecard (installs ~July 8–16)

| Category                                                | Users | Verdict |
|---------------------------------------------------------|-------|---------|
| Bounced at/before welcome screen (`first_open` only)    | ~5    | Low-intent store traffic; not addressable in-app |
| Crashed out (`app_exception` ×3 → `app_remove`)         | 1     | Real bug, invisible to Crashlytics (async errors unhandled) |
| Uninstalled right after notification prompt (44s in)    | 1     | Prompt fired after 1 note, minutes into first session |
| Engaged with tutorial (`section_added`) → uninstalled   | 2     | Tutorial works; no bridge to their own use case, and/or expectation mismatch |
| Created a real note (`first_note_created`) → uninstalled| 1     | Even activation didn't hold |
| Open verdict (still installed / events maybe pending)   | 2     | — |

Data caveats: GA4 batches events on-device and uploads on next app open, so
uninstallers' final events may be lost (streams understate engagement).
`app_remove` is Android-only.

## Fixes shipped 2026-07-17 (in repo, need release)

1. **Async crash reporting** — `main.cljd`: wired
   `PlatformDispatcher.instance.onError` → Crashlytics (`recordError fatal`).
   Previously only `FlutterError.onError` was wired, so uncaught async errors
   crashed silently (GA4 `app_exception`, nothing in Crashlytics). The crash
   user's device/OS is visible in their User Explorer panel — check for repro.
2. **Notification prompt moved later** — `tutorial.cljd`
   `maybe-prime-reminders`: now requires **2** real (non-`:default`) notes
   instead of 1. Also `examples.cljd`: added missing `:default true` to
   `groceries`, `todo`, `workout` — they previously counted as real notes,
   which inflated `first_note_created`/`activation_note` analytics, let starter
   notes trigger the prompt, and gave streak credit for menu clicks.
   **Note: cohort-1 `first_note_created` counts are inflated by this bug.**
3. **Tutorial → product bridge** — `examples.cljd` welcome note: added final
   checklist item "Now make your own note — go back and tap the + button!"
   (cohort-1 users finished the checklist and uninstalled; nothing pointed them
   onward).

## Known issues, deliberately not fixed yet

- **Navigation race** (`login.cljd` `build-first-note`): the `:bg-watcher` on
  `authStateChanges` calls `.go "/"` when a uid appears; if it fires after
  `redirect-to-first-note`'s `pushNamed "edit"`, the user lands on the home list
  instead of inside the welcome note. Timing-dependent. Guard it (only redirect
  if still on the welcome route) or remove it.
- **Welcome screen redesign** (product-showing visual/SVG, dominant CTA, demote
  "I've used this app before" to a text link): deprioritized — cohort 1 showed
  the people who saw the screen mostly got through it. Revisit if the next
  cohort's `onboarding_starting` → `welcome_get_started_clicked` gap is large
  among users with real engagement time.
- **Anonymous users have no re-engagement channel** besides local notifications.
  Structural; revisit after prompt-timing change is measured.
- **Streak/premium mechanics untouched** — unreachable for ~90% of users until
  the earlier funnel holds. Don't polish further yet.

## Next steps (when ~10–15 new users are in)

1. Release the three fixes; note the release date here so cohorts map to
   versions.
2. Repeat the User Explorer pass (GA4 → Explore → User explorer; date range =
   release date onward; segment: has `first_open`, evaluated in-range = new
   users). Assign each user to a scorecard category, add a column to the table
   above, compare.
3. What "working" looks like: crash category → 0; prompt-recoil → 0 (prompt now
   later); engaged-then-uninstalled shrinking; anyone with a *second-day*
   session.
4. Probe the engaged-then-churned group further: did anyone touch the product
   beyond the seeded notes (second note opened, section picker, search)? Check
   Play Console acquisition/listing data for expectation mismatch.
5. If tourists (~5/12) stay the dominant loss: that's a traffic/store-listing
   problem, not onboarding. Consider a higher-intent traffic burst (Reddit,
   notes-app communities, PH) — also the only realistic way to get cohort sizes
   where any of this is measurable.

## Funnel/analytics notes for future reference

- Reliable funnel steps (time-separated user decisions only):
  `first_open` → `onboarding_starting` → `welcome_get_started_clicked` →
  `first_note_created` → `activation_note`. Never use same-instant events
  (`user_created`, `onboarding_welcome_seeded`, `example_note`) as steps.
- `onboarding_starting` (main.cljd, fires when a uid-less user is routed to the
  welcome screen) doubles as "welcome screen shown".
- `login` (main.cljd auth watcher) fires on *every* auth emission incl. right
  after anonymous sign-up — it is not a sign-in-screen event.
- GA4 user-data retention for explorations defaults to 2 months — export or
  analyze cohorts before they age out (Admin → Data settings → Data retention).
