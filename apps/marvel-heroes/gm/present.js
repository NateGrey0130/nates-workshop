// Marvel Heroes - present mode, the page script.
//
// Everything present mode does - the picture fitted to the screen, the arrows
// and keys, the chrome that fades, the wake lock, and the one Reveal write - is
// shared/js/campaign/present.js, shared with the Palladium GM page. What is
// Marvel's is only the API base and where leaving goes: back to GM tools with
// the campaign and the page that was being shown, so the GM lands where they
// were.
//
// ?campaign_id=<id>&entry_id=<id> are the setting view's link (setting.js).

const params = new URLSearchParams(location.search);
const campaignId = params.get('campaign_id');
const entryId = params.get('entry_id');

function leave() {
  const q = new URLSearchParams();
  if (campaignId) q.set('c', campaignId);
  if (entryId) q.set('entry_id', entryId);
  location.href = `./${q.toString() ? `?${q}` : ''}`;
}

globalThis.mcPresent.start({ base: '/api/marvel-heroes', campaignId, entryId, leave });
