// The ui adapter the shared campaign views take (shared/js/campaign/core.js,
// mcCampaign.init's `ui`), for the Campaigns and GM pages. One copy, so the
// two pages cannot escape differently.
//
//   esc(v)     for element content and attributes (js/sheet.js's)
//   escJs(v)   for a JS string inside an inline handler: HTML-escaped WITHOUT
//              the apostrophe, then backslash-escaped, so a dossier called
//              O'Brien survives the attribute decode and still parses. The
//              same two layers as the Palladium pages' escJs (shared/js/ui.js);
//              js/sheet.js's esc turns ' into &#39;, which the attribute
//              decodes straight back into the string literal - the O'Brien bug.
//   modal      a yes/no question, as a promise
//   toast      where a failure is said: the page's own status line
//   undoable   js/undo.js

import { esc } from './sheet.js';
import { undoable } from './undo.js';

export function escJs(v) {
  return String(v ?? '')
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')
    .replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\r?\n/g, '\\n');
}

export function campaignUi(say) {
  return { esc, escJs, undoable, modal: (text) => Promise.resolve(confirm(text)), toast: say };
}
