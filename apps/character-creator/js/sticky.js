// Sticky positioning under the shared header, for both pages that need it.
//
// The sheet's vitals strip and the wizard's stepper both stick below .header,
// so both need the header's height as a NUMBER. It cannot be a constant:
// .header wraps to a second row on a narrow screen - 77px at 1440, 166px at
// 390, measured - and any constant is wrong at one of them. So it is measured
// from the rendered header on every render and on resize, and written to
// --header-h for the stylesheet to position against.
//
// A missing header leaves --header-h unset and the CSS falls back to 0px,
// which is the old behaviour rather than a broken one.
//
// THIS LIVES HERE RATHER THAN IN sheet.js BECAUSE TWO PAGES NEED IT. It was
// sheet.js's private function until the wizard wanted the same thing; copying
// it would have made a second place that knows how tall the header is, and
// this app has already had to undo that pattern twice - the save list that
// drifted between the sheet and play mode, and the two pool widgets.
//
// Classic script, one global, same shape as derive.js and rules.js.
(function (global) {
  'use strict';

  function sizeSticky() {
    const h = document.querySelector('.header');
    if (h) document.documentElement.style.setProperty('--header-h', h.offsetHeight + 'px');
    // AND THE STICKY BLOCK'S OWN HEIGHT, for the same reason and by the same
    // argument this file already makes about the header: anything that scrolls
    // a heading to the top of the page has to know what is covering the top of
    // the page, and the sheet's vitals strip is 140px of it. A second place
    // measuring this is the pattern the paragraph above says this app has
    // already had to undo twice.
    //
    // The first [data-sticky] rather than all of them: a page has one sticky
    // block under the header, and `scroll-margin-top` needs one number.
    const s = document.querySelector('[data-sticky]');
    if (s) document.documentElement.style.setProperty('--sticky-h', s.offsetHeight + 'px');
    // And the fixed bar at the BOTTOM, for the same reason at the other end:
    // play mode reserves room so the bar cannot cover the last row of the
    // sheet, and since P5e that bar carries the controls, so its height is no
    // longer a constant anyone can write down. Measured on render and on
    // resize, which deliberately excludes the roll history's transient
    // expansion - that overlays, as it always has.
    const b = document.querySelector('#play-roll-bar');
    if (b) document.documentElement.style.setProperty('--play-bar-h', b.offsetHeight + 'px');
  }

  window.addEventListener('resize', sizeSticky);

  global.sticky = { sizeSticky };
})(globalThis);
