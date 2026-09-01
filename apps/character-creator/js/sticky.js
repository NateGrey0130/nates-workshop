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
  }

  window.addEventListener('resize', sizeSticky);

  global.sticky = { sizeSticky };
})(globalThis);
