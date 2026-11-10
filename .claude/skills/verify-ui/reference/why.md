# Why verify-ui's rules exist

`SKILL.md` states the rules; this holds the incidents and measurements behind
them, moved out so that the record is not loaded on every call of the skill.
Each section below is named for the one it came from, and the text is moved
unchanged. Read an undated claim as true on the day it was written.

## Which stylesheet you edit decides how many apps you retone

On the hub, `index.html`:

It stayed blue and violet for months after every app behind it had been
retoned.

## 1. The Browser pane lies in three specific ways

On *A blank screenshot is about SCROLL, not height*:

A 2,506px page came back
blank while scrolled; every shot taken at `scrollY: 0` rendered, at page
heights past 11,000px.

On *`read_page` prints a control's VALUE, not its accessible name*:

An audit called both unlabelled and was wrong twice.

## 2. Screenshot at the widths that matter, and read what is ABOVE THE FOLD

The tabs restructure measured as a clear success — page height 4105px → 1702px,
every tab under three tablet screens, one panel visible at a time, print rules
verified. The first tablet screenshot showed the identity block filling the
entire screen with mostly-blank bio fields and **the tab bar below the fold**.
The sheet opened showing no game data and no visible tabs.

Every metric said it worked. The device said it did not, and the fix only
happened because of the screenshot.

## 3. Measure an overflow against the box that actually clips it

A control added to a table cell was measured against the **box** and against the
**page**, found clean both ways, and shipped visibly sliced in half: every skill
row's roll die cut down the middle and `+5` / `98%` collapsed into `+598%`.

The overflow was inside the **cell**, which neither check looked at.

## 4. Print media renders headlessly. Do not read it off the stylesheet

That is how a finding shipped predicting a table
would split with no repeated header — the render showed both pages opening with
their header, because `display: table-header-group` is already the browser
default for `<thead>`. The proposed rule was a no-op.

## 5. On PRODUCTION, verify by reading. Some controls WRITE

One click on a real character to "prove the collapse worked" put a row in Nate's
log that neither of them rolled at a table. It came out of production D1 by hand.
