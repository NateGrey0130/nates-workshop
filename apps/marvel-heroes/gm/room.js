// Marvel Heroes - the room view: the GM's screen turned round at the table.
//
// It shows the initiative order and whose turn it is, in type the far end of
// the table can read, and nothing else - no notes, no Health, no Karma.
//
// WHILE THE TABLE IS OPEN, initiative is the table's room's, and this page
// becomes the table's TV view (apps/table/?as=display): the same order and the
// current name, large, read from the room by every screen at once, and the
// pictures and public rolls with it. Its one request is table/status, to ask.
//
// With no table open it works as it always has: it reads the list the GM page
// keeps in this browser's localStorage (gm.js, one list per campaign) and
// redraws on the `storage` event, which fires here whenever the GM page, open
// in another window on the same machine, changes it.
//
// No innerHTML: every name is set as textContent, so there is nothing to
// escape. ?c=<id> names the campaign.

const $ = (id) => document.getElementById(id);
const id = new URLSearchParams(location.search).get('c');
const key = `mh-init-${id}`;
if (id) $('room-back').href = `./?c=${encodeURIComponent(id)}`;

function read() {
  try { return JSON.parse(localStorage.getItem(key) || 'null'); } catch { return null; }
}

function draw() {
  const I = read();
  const list = $('room-list');
  list.replaceChildren();
  const rows = I?.order;
  $('room-round').textContent = I ? `Round ${I.round}` : 'Waiting for the GM';
  $('room-empty').hidden = !!rows?.length;
  if (!rows?.length) return;
  rows.forEach((r, i) => {
    const li = document.createElement('li');
    li.className = i === I.turn ? 'on' : (i < I.turn ? 'done' : '');
    if (i === I.turn) li.setAttribute('aria-current', 'true');
    const name = document.createElement('span');
    name.className = 'room-name';
    name.textContent = r.name;
    const roll = document.createElement('span');
    roll.className = 'room-roll';
    roll.textContent = String(r.roll).padStart(2, '0') + (r.tags?.length ? ` (${r.tags.join(', ')})` : '');
    li.append(name, roll);
    list.append(li);
  });
  list.querySelector('.on')?.scrollIntoView({ block: 'center', behavior: 'smooth' });
}

window.addEventListener('storage', (e) => { if (e.key === key) draw(); });
draw();

// An open table wins: go to its TV view. A deployment without the room, or no
// table, leaves this page as it is.
if (id) {
  try {
    const res = await fetch(`/api/marvel-heroes/table/status?campaign_id=${encodeURIComponent(id)}`);
    const t = res.ok ? await res.json() : null;
    if (t?.open && t.room === 'open') location.replace(`/apps/table/?code=${encodeURIComponent(t.code)}&as=display`);
  } catch { /* offline: the local list stands */ }
}
