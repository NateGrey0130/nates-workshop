---
name: verify-ui
description: Prove a visual change in this repo actually looks right, on this machine. Use after any CSS, template, layout or sheet change, when asked "does this look right", "check the sheet", "screenshot it", before calling UI work done, and when auditing an interface. Covers which port to serve on, the three ways the in-app Browser pane lies, rendering real print media, measuring an overflow against the right box, and which controls write to production if you click them.
---

# Verifying a change you can see

**A measured DOM number is not a substitute for looking at the page**, and every
rule below is a case where the numbers said one thing and the render said
another. `ship-pr` step 4 says *"changed anything visible: drive it in a
browser"*; this is how, here.

## 0. Serve on YOUR port. 8788 probably is not yours

A dev server already listening on 8788 is almost always **another worktree**, and
it serves that checkout's `.wrangler/state`. The page loads, looks like your app,
and is not: an API layer once showed old markdown while
`wrangler d1 execute --local` readbacks showed the fix applied.

Use an escape hatch — `nates-apps-8791` or `nates-apps-8793`, in both
`.claude/launch.json` and `Downloads\.claude\launch.json`. A different port is
also a different **origin**, so `localStorage` state cannot collide either.

**Confirm the page is yours before trusting it:** find a string your branch
added and check it is on the page. Port ownership is not evidence.

**Wizard drafts are server-side**, one row per owner in local D1
(`character_drafts`), so they appear on every port and *Discard and start fresh*
destroys real state. Snapshot before walking the wizard:
`GET /api/character-creator/draft`, keep the JSON, then restore with `PUT`
passing `expect_updated_at` of whatever the walk left behind.

## 1. The Browser pane lies in three specific ways

Looking at the page is still right. The pane is not a neutral window, and each
of these produced a **false finding** in one session:

- **`key` moves focus but does not activate.** `Tab` works; `Enter` and `Return`
  on a focused `<button>` do nothing, and a `left_click` on a real button has
  silently failed to fire. `element.click()` does fire the handler. Verify
  activation with `.click()`, and rest keyboard behaviour on the platform
  guarantee for a real `<button>` rather than on what the pane did.
- **A blank screenshot is about SCROLL, not height.** A 2,506px page came back
  blank while scrolled; every shot taken at `scrollY: 0` rendered, at page
  heights past 11,000px. **Scroll to top, then screenshot** — or accept DOM
  evidence and say so.
- **`read_page` prints a control's VALUE, not its accessible name.** A properly
  labelled checkbox reads as `checkbox "on"`, a labelled `<select>` as
  `combobox "— choose —"`. An audit called both unlabelled and was wrong twice.
  Check `el.labels.length` and `labels[0].textContent` before reporting a
  missing label.

**Prove a pane limitation against a control your change never touched.** That is
what separates "the pane cannot do this" from "I broke it".

## 2. Screenshot at the widths that matter, and read what is ABOVE THE FOLD

The tabs restructure measured as a clear success — page height 4105px → 1702px,
every tab under three tablet screens, one panel visible at a time, print rules
verified. The first tablet screenshot showed the identity block filling the
entire screen with mostly-blank bio fields and **the tab bar below the fold**.
The sheet opened showing no game data and no visible tabs.

Every metric said it worked. The device said it did not, and the fix only
happened because of the screenshot.

So: **tablet (768px) and desktop**, and judge what is reachable without
scrolling rather than a total. When screenshots are unavailable, say the
assessment is DOM-based and unverified — do not treat it as confirmation.

## 3. Measure an overflow against the box that actually clips it

A control added to a table cell was measured against the **box** and against the
**page**, found clean both ways, and shipped visibly sliced in half: every skill
row's roll die cut down the middle and `+5` / `98%` collapsed into `+598%`.

The overflow was inside the **cell**, which neither check looked at.

```js
btn.getBoundingClientRect().right - cell.getBoundingClientRect().right
```

**Check `table-layout` first.** Under `fixed`, a column is its declared width
whatever is in it — the cell will not grow for a 44px control, and the
surrounding `overflow-x: auto` cuts it. A width override is required, not
optional.

## 4. Print media renders headlessly. Do not read it off the stylesheet

The pane has no print emulation and `window.print()` blocks, so print findings
used to be reasoned from CSS. That is how a finding shipped predicting a table
would split with no repeated header — the render showed both pages opening with
their header, because `display: table-header-group` is already the browser
default for `<thead>`. The proposed rule was a no-op.

```bash
"/c/Program Files/Google/Chrome/Application/chrome.exe" --headless=new \
  --disable-gpu --no-pdf-header-footer --virtual-time-budget=20000 \
  --print-to-pdf="<ABSOLUTE windows path>" "http://localhost:8791/..."
```

- **The output path must be absolute and Windows-shaped**; a bare filename gives
  `Failed to write file: Access is denied`.
- `--virtual-time-budget` is what lets the page's JS finish before capture.
- **`pymupdf` rasterises the result** — `page.get_pixmap(dpi=110).save(...)`
  gives a PNG the Read tool can look at. A print finding can be *seen*.
- This Chrome **ignores `--print-to-pdf-paper-width/height`** — Letter and A4
  came back byte-identical. And a flag render cannot drive the page first, so it
  cannot test anything depending on state (a filter, a tab). For either, drive
  Chrome over **CDP**: `--remote-debugging-port` with its own `--user-data-dir`,
  `PUT /json/new?<url>` (GET is refused), then `Page.printToPDF`.
- **Kill the headless instance by its `--user-data-dir`**, matching
  `CommandLine` in `Get-CimInstance Win32_Process`. Never by image name: one
  launch left 15 processes behind, and a blanket `taskkill /IM chrome.exe` would
  take Nate's real browser with it.

**A print change can be diffed without rasterising**: pull the colour operators
out of the content streams into a set and compare before against after.

## 5. On PRODUCTION, verify by reading. Some controls WRITE

Play mode's roll buttons `POST` to `characters/<id>/events`. **A roll is not a
read** — it writes a `play_events` row into that character's session log,
attributed to whoever is signed in, and there is no DELETE route.

One click on a real character to "prove the collapse worked" put a row in Nate's
log that neither of them rolled at a table. It came out of production D1 by hand.

**The controls that write:** roll buttons, the `+`/`−` pool steppers, Damage,
End session, the weapon Strike/damage/fire buttons, and the psionics use
buttons.

So exercise anything stateful on the **local** server against a **local**
character. On production: fetch the JS and assert the shipped shape, read
computed styles, read the DOM — and stop short of anything that calls
`postEvent`.

Production also sits behind Access, so `curl` and the in-app pane get a 302;
`claude-in-chrome` works because Nate's Chrome holds the session.

## What "verified" means

- served on a port you own, with a string from your branch confirmed on the page
- screenshotted at tablet and desktop, judged above the fold
- any new control measured against its own cell, not the page
- print checked with a render if the change could reach paper
- nothing on production clicked that writes

**If you could not do one of these, say which and say the finding is
unverified.** A DOM-based assessment reported as confirmation is how the tab bar
shipped below the fold.
