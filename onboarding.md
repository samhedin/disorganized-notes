# Onboarding & D1 retention — status and follow-up

Last updated: 2026-07-22. Follow up when the next ~10–15 users have come in.

## Status

The new onboarding (shipped 2026-07-08, commits `2bf947b`..`b991e71`) has now had
two cohorts and **0 confirmed D1 returns in either**.

The 2026-07-17 fixes *are* live for cohort 2 (see "Release status" below). They
worked as designed — prompt-recoil went to zero and activation counts are no
longer inflated — but they did not move retention, because two larger holes were
in the way:

1. **Crashes are the #1 loss driver**, at 2 of 6 visible Android users. Fix #1
   was crash *reporting*, not a crash fix, so this was expected to persist; what
   is new is that Crashlytics should now have the stack traces.
2. **An entire path bypassed onboarding.** Registering outright, or tapping
   "Skip registration", created an account and dropped the user on an empty home
   screen with no welcome note. Fixed 2026-07-22.

Caveat to keep in mind: n=12 and n=8. 0 D1 returns at these sizes was always
statistically compatible with the old ~8% baseline. Everything here is
directional, not proof.

## How we got there

1. **Funnel exploration first** — showed "75% abandoned before Get Started".
   This turned out to be partly an artifact: GA4 funnels require strict timestamp
   order, and `welcome_get_started_clicked` / `user_created` /
   `onboarding_welcome_seeded` fire in the same ~1s burst, so same-second jitter
   causes phantom drop-offs. Closed funnels also silently exclude users whose
   `first_open` predates the date range.
2. **User Explorer (per-user event streams) second** — this was the useful tool
   at this scale. Reading each user individually gave a different and more
   actionable picture, in both cohorts.

### Cohort 1 scorecard (installs ~July 8–16, n=12)

| Category                                                | Users | Verdict |
|---------------------------------------------------------|-------|---------|
| Bounced at/before welcome screen (`first_open` only)    | ~5    | Low-intent store traffic; not addressable in-app |
| Crashed out (`app_exception` ×3 → `app_remove`)         | 1     | Real bug, invisible to Crashlytics (async errors unhandled) |
| Uninstalled right after notification prompt (44s in)    | 1     | Prompt fired after 1 note, minutes into first session |
| Engaged with tutorial (`section_added`) → uninstalled   | 2     | Tutorial works; no bridge to their own use case, and/or expectation mismatch |
| Created a real note (`first_note_created`) → uninstalled| 1     | Even activation didn't hold |
| Open verdict (still installed / events maybe pending)   | 2     | — |

### Cohort 2 scorecard (installs July 19–21, n=8, 157 events)

Running the 07-17 fixes. ~7 actual humans — see the Calpella duplicate below.

| Category                                    | Users | vs. cohort 1 |
|---------------------------------------------|-------|--------------|
| **Crashed out**                             | **2** | up from 1 — now the dominant loss |
| **Onboarding bypassed** (no welcome note)   | **1** | new; was invisible in cohort 1 |
| Bounced at/before welcome screen            | 2     | proportionally similar |
| Uninstalled right after notification prompt | **0** | fix #2 holds — no `reminder_prompt_*` anywhere |
| Engaged with tutorial → uninstalled         | 0     | no `section_added` in cohort |
| iOS, no detail panel exported               | 2     | — |

Per-user, by effective user ID:

- **`053eebc4…`** (Calpella US, Android) — the most engaged user in the cohort
  and lost to a crash. Picked 4 templates from the "A few things to try!" menu
  (9:18:43 → 9:19:41), created a real note (9:20:16), `app_exception` **2
  seconds later** (9:20:18), `first_note_created` 9:20:20, tried a second note
  9:20:23, `app_remove` 9:20:41. 6m48s engaged. Crash → uninstall in 23s.
- **`ad9b3865…`** (Bucharest RO, Android) — crash loop on the welcome screen,
  never reached signup. `first_open` 11:32:33 → `onboarding_starting` 11:32:49 →
  **four** `app_exception` (11:32:59, 11:33:12, 11:33:33, 11:34:43) →
  `app_remove` 11:37:49. `sessions = 0`. Same shape as cohort 1's crash user,
  worse. **Fix this one first — it blocks users before they can even sign up.**
- **`de9820d2…`** (Boardman US, Android) — the onboarding bypass. `first_open`
  1:32:58 → `onboarding_starting` 1:33:14 → 37s → `user_created` 1:33:51 →
  `login` 1:33:52 → nothing for 3m36s. No `welcome_get_started_clicked`, no
  `onboarding_welcome_seeded`, no `example_note`. They got an account and an
  empty home screen, sat there, and left.
- **`5c001357…`** (Calpella US, Android) — full chain to `user_created` at
  9:12:15, `app_remove` 9:12:24. 14 seconds start to finish, 0s engagement.
- **`e757a828…`** (geo not set, Android) — saw the welcome screen twice
  (`onboarding_starting` 1:48:53 and 1:50:40), never clicked through. No
  `app_remove`; may still be installed.
- **`c1692fc4…`** (Isfahan IR, Android) — 3s bounce, 5 events.
- **`0218A632…` / `719115D3…`** (both iOS) — 46 events / **2 sessions** / 17 key
  events, and 34 events / 1 session / 6 key events. **No detail panels in the
  export.** The 2-session user is the only D1-return candidate in the cohort;
  both sessions could be same-day. Unresolved.

Two Calpella installs 3 minutes apart (`5c001357…` uninstalls 9:12:24,
`053eebc4…`'s session starts 9:15:59) in a town of ~500 people are almost
certainly one person reinstalling — or a test device on a release build.

Data caveats: GA4 batches events on-device and uploads on next app open, so
uninstallers' final events may be lost (streams understate engagement).
`app_remove` is Android-only, so **iOS churn is structurally invisible**.

## Release status

Cohort 2 was running the 07-17 fixes. Evidence: `053eebc4…`'s
`first_note_created` fired at 9:20:20, immediately after a real `note_created`
at 9:20:16 — *not* during the template picks minutes earlier. If the `:default`
fix were absent, the template notes would have fired it themselves. So the
`:default true` change was live, and by implication so were the other two.

Consequence: **Crashlytics should hold all five `app_exception`s** — one US
device ~9:20:18 AM Jul 20, four Romanian ~11:32–11:34 PM Jul 20.

## Fixes shipped 2026-07-17 (live in cohort 2)

1. **Async crash reporting** — `main.cljd`: wired
   `PlatformDispatcher.instance.onError` → Crashlytics (`recordError fatal`).
   Previously only `FlutterError.onError` was wired, so uncaught async errors
   crashed silently (GA4 `app_exception`, nothing in Crashlytics).
   **This is reporting, not a fix — the crashes are still there.**
2. **Notification prompt moved later** — `tutorial.cljd`
   `maybe-prime-reminders`: now requires **2** real (non-`:default`) notes
   instead of 1. Also `examples.cljd`: added missing `:default true` to
   `groceries`, `todo`, `workout` — they previously counted as real notes,
   which inflated `first_note_created`/`activation_note` analytics, let starter
   notes trigger the prompt, and gave streak credit for menu clicks.
   **Note: cohort-1 `first_note_created` counts are inflated by this bug.**
   Verdict: worked. Zero prompt-recoil in cohort 2.
3. **Tutorial → product bridge** — `examples.cljd` welcome note: added final
   checklist item "Now make your own note — go back and tap the + button!"
   Verdict: unmeasurable in cohort 2 (nobody reached it).

## Fix shipped 2026-07-22 (needs release)

**Sign-up paths unified** — `login.cljd`. There were four `user-created` call
sites and whether you got onboarding was uncorrelated with whether you were new:

| Path | Was | Now |
|------|-----|-----|
| Get started (anonymous) | seeded welcome note | unchanged |
| "Skip registration" | no seeding — dumped on empty home screen | **button deleted** |
| Register outright, no prior uid | no seeding | seeds welcome note |
| Anonymous user upgrading | seeded a **second** welcome note | plain redirect |

The last two were straightforwardly inverted. "Skip registration" was removed
outright rather than fixed: once it seeds the welcome note it is identical to
Get started, so it was a second door onto the same path — reachable only via
"I've used this app before", which is how `de9820d2…` got lost. That screen is
now only for people who really do have an account. The `anonymous` widget went
with it.

`redirect-to-first-note` now takes a `via` argument and logs
`onboarding_welcome_seeded {"via" "get_started"|"registration"}`.

Not compiled — verify on hot reload. The register-outright path is the one to
exercise: it calls `redirect-to-first-note` from a Firebase-UI action callback
using that callback's `context`, which gives the navigation race below a new
caller.

## Known issues, deliberately not fixed yet

- **Navigation race** (`login.cljd` `build-first-note`): the `:bg-watcher` on
  `authStateChanges` calls `.go "/"` when a uid appears; if it fires after
  `redirect-to-first-note`'s `pushNamed "edit"`, the user lands on the home list
  instead of inside the welcome note. Timing-dependent. Guard it (only redirect
  if still on the welcome route) or remove it. **Now has a second caller** (the
  registration path) — priority raised.
- **Welcome screen redesign** (product-showing visual/SVG, dominant CTA, demote
  "I've used this app before" to a text link): partly overtaken — the
  destination behind that link no longer strands anyone. Still worth demoting:
  in cohort 2 it pulled a user out of onboarding entirely. Two of six visible
  Android users saw the welcome screen and never clicked through.
- **Anonymous users have no re-engagement channel** besides local notifications.
  Structural; revisit after prompt-timing change is measured.
- **Streak/premium mechanics untouched** — unreachable for ~90% of users until
  the earlier funnel holds. Don't polish further yet.

## Next steps

1. **Pull Crashlytics for Jul 20** and fix the Bucharest crash first — it fires
   on the welcome screen before signup, so it costs 100% of affected users. Then
   the Calpella one, which fires ~2s after note creation.
2. Release the 07-22 sign-up unification.
3. **Resolve the iOS blind spot.** Two of eight users, including the only
   D1-return candidate, had no detail panel in the export. Open
   `0218A632…` directly in the GA4 UI and check whether its 2 sessions span two
   days. Remember `app_remove` will never appear for these users.
4. Repeat the User Explorer pass on the next ~10–15 users (date range = release
   date onward; segment = users with `first_open` in range). Add a column to the
   cohort table.
5. What "working" looks like: crash category → 0; onboarding-bypass → 0
   (`onboarding_welcome_seeded` should now fire for every `user_created`);
   anyone with a *second-day* session.
6. If tourists stay the dominant loss: that's a traffic/store-listing problem,
   not onboarding. Consider a higher-intent traffic burst (Reddit, notes-app
   communities, PH) — also the only realistic way to get cohort sizes where any
   of this is measurable.

## Funnel/analytics notes for future reference

- Reliable funnel steps (time-separated user decisions only):
  `first_open` → `onboarding_starting` → `welcome_get_started_clicked` →
  `first_note_created` → `activation_note`. Never use same-instant events
  (`user_created`, `onboarding_welcome_seeded`) as adjacent steps.
- **`example_note` is mostly a user-intent signal, not seeding noise.** Only
  `which=welcome` is automatic (`login.cljd` `redirect-to-first-note`). The
  other four — `groceries`, `todo`, `workout`, `recipe` — fire from
  `tutorial.cljd` `.onSelected`, i.e. the user tapping a template in the "A few
  things to try!" menu. Spread-out timestamps mean engagement; a same-second
  single `example_note` alongside `onboarding_welcome_seeded` is the seeded one.
  Always read the `which` parameter.
- **`onboarding_welcome_seeded` now fires on every new-account path** (since
  2026-07-22) and carries `via`. It is the truthful "onboarding began" marker —
  better than `welcome_get_started_clicked`, which only covers one door. Still
  don't put it adjacent to `user_created` in a funnel.
- `onboarding_starting` (main.cljd, fires when a uid-less user is routed to the
  welcome screen) doubles as "welcome screen shown".
- `login` (main.cljd auth watcher) fires on *every* auth emission incl. right
  after anonymous sign-up — it is not a sign-in-screen event.
- GA4 user-data retention for explorations defaults to 2 months — export or
  analyze cohorts before they age out (Admin → Data settings → Data retention).

### Getting the data out of GA4

- **Use the PDF export, not CSV.** The CSV export of a User Activity panel drops
  the chronological event stream entirely — the `IUR event activity` /
  `Event timestamp` section comes out empty, and each summary tile is dumped as
  its own headerless block. The PDF keeps per-event timestamps, which is the
  only thing that makes these streams readable.
- **The PDF omits detail panels for some users** — cohort 2's two iOS users
  appeared in the summary table with no `User activity` page. Open those in the
  UI individually.
- **The activity timeline hides `user_engagement` events.** The day-group header
  count is `Event count` *minus* `user_engagement`, so a user showing 16 events
  but a "6 Events" group is not evidence of a second day — verified across all
  six of cohort 2's panels. Occasionally it renders as an unnamed `(not set)`
  row instead.
- Panel numbering (`User activity 1..N`) does **not** match summary-table row
  numbering. Refer to users by effective user ID.
