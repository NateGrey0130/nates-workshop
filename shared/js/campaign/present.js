// Present mode - the GM's screen turned round at the table. Needs core.js
// alone: it writes no markup, so it takes no ui adapter.
//
// One picture, fitted to the screen, on black. Arrows move through the
// pictures of ONE setting page (setting.js), Escape leaves.
//
// SHOW IS NOT REVEAL, and this file is where that holds or does not.
// `toggleReveal` is the ONLY function here that sends a write, and it runs
// from one button press and nothing else - not from opening the page, not from
// `go()`, not from a key. A GM shows a map to the room a dozen times before
// deciding the party keeps a copy of it, and those are different decisions:
// the second one lands in the players' Handouts forever and the first one ends
// when the laptop turns back round.
//
// The affordance is here ANYWAY, rather than only on the setting page, because
// the two do happen together at a table and walking out of the room view to
// press a button on another page is how a GM ends up not bothering.
//
// NO innerHTML IN THIS FILE. The markup is static in the page and this only
// fills it - a caption is set as textContent, an image as a src. The page
// supplies these ids, and styles them however its game looks:
//   frame (figure, starts hidden) > pic (img)     state (the loading/error line)
//   title, count, caption      prev, next         reveal (button), shown, msg
//   close, fullscreen          and on <body>: the classes `idle` and `is-error`
// The reveal button's classes are set here: `mc-btn`, plus `mc-btn-primary`
// while the picture is still the GM's alone.
//
// mcPresent.start({ base, campaignId, entryId, imageId, leave, load })
//   leave() - where Escape and ✕ go
//   load()  - optional: what to show INSTEAD of a setting page, for a page
//             with something else to present (the Palladium page's city
//             maps). It can use mcPresent.fail and mcPresent.keepAwake.
'use strict';

(function (global) {
  const $ = (id) => document.getElementById(id);
  const P = { entry: null, images: [], at: 0, lock: null };
  let O = {};
  let api = null;
  let campaignId = null;
  let entryId = null;

  function leave() { O.leave(); }

  // A dead end says what went wrong and keeps the way out: the top bar stays,
  // the picture and the arrows go. A player who reaches this URL lands here -
  // the entry endpoint is GM-only, so the refusal is the server's rather than a
  // check this page performs.
  function fail(text) {
    document.body.classList.add('is-error');
    $('frame').hidden = true;
    $('state').hidden = false;
    $('state').textContent = text;
    wake(true);
  }

  async function load() {
    if (!campaignId || !entryId) {
      fail('Present mode opens a page of pictures. Pick one on the dashboard and press Present.');
      return;
    }
    try {
      const res = await api(`campaigns/${campaignId}/entries/${entryId}`);
      P.entry = res.entry;
      P.images = res.images || [];
    } catch (err) {
      fail(err.status === 403 ? 'Only the GM of this campaign can present its pages.' : err.message);
      return;
    }
    if (!P.images.length) {
      $('title').textContent = P.entry.title;
      fail('This page has no pictures yet. Add one on the dashboard and it can be shown here.');
      return;
    }
    // image_id names the picture to open on, so "Present" on a particular
    // picture starts there rather than at the top of the page.
    const at = P.images.findIndex((i) => String(i.id) === String(O.imageId));
    P.at = at >= 0 ? at : 0;
    $('state').hidden = true;
    $('frame').hidden = false;
    show();
    keepAwake();
  }

  function src(image) {
    return `${O.base.replace(/\/+$/, '')}/campaigns/${campaignId}/images/${image.id}`;
  }

  function show() {
    const image = P.images[P.at];
    const pic = $('pic');
    pic.src = src(image);
    // The caption when there is one, the page's title when there is not: an
    // empty alt on the only thing on the screen tells a screen reader nothing.
    pic.alt = image.caption || P.entry.title;

    $('title').textContent = P.entry.title;
    $('count').textContent = `${P.at + 1} / ${P.images.length}`;
    $('caption').textContent = image.caption || '';
    $('prev').disabled = P.at === 0;
    $('next').disabled = P.at === P.images.length - 1;
    paintReveal(image);
    $('msg').textContent = '';

    // The address bar names the picture on screen, so a reload stays put and
    // Escape goes back to the right page.
    const q = new URLSearchParams({ campaign_id: campaignId, entry_id: entryId, image_id: String(image.id) });
    history.replaceState(null, '', location.pathname + '?' + q);

    // A picture is served at the size it was uploaded, and there is no resizing
    // on this runtime, so the one after this is fetched now rather than when
    // the arrow is pressed. Both neighbours, because a GM steps back through a
    // page as often as forward.
    for (const n of [P.at + 1, P.at - 1]) {
      if (P.images[n]) new Image().src = src(P.images[n]);
    }
  }

  function paintReveal(image) {
    const on = !!image.revealed_at;
    const btn = $('reveal');
    btn.textContent = on ? '🙈 Hide from players' : '👁 Reveal to players';
    btn.className = on ? 'mc-btn' : 'mc-btn mc-btn-primary';
    // Said plainly, because it is the one thing on this screen that has already
    // left the room: what the party can open in their own Handouts.
    $('shown').textContent = on ? 'the party has this' : 'yours alone — showing it here does not change that';
  }

  function goTo(at) {
    if (at < 0 || at >= P.images.length || at === P.at) return;
    P.at = at;
    show();
  }

  const go = (by) => goTo(P.at + by);

  // THE ONE WRITE ON THIS PAGE.
  async function toggleReveal() {
    const image = P.images[P.at];
    const on = !image.revealed_at;
    $('msg').textContent = on ? 'Revealing…' : 'Hiding…';
    try {
      const res = await api(`campaigns/${campaignId}/images/${image.id}`, {
        method: 'PATCH', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ revealed: on }),
      });
      P.images[P.at] = { ...image, ...res.image };
      paintReveal(P.images[P.at]);
      $('msg').textContent = on ? 'In their Handouts now.' : 'Gone from their Handouts.';
    } catch (err) {
      $('msg').textContent = err.message;
    }
  }

  // ---------- the chrome, and when it is not there ----------
  //
  // Everything that is not the picture fades after a few seconds of nothing
  // happening, and comes back on any movement, key or touch. A GM who turns the
  // laptop round mid-sentence should not be showing the party a row of buttons.
  let idle = null;
  function wake(stay) {
    document.body.classList.remove('idle');
    clearTimeout(idle);
    if (!stay) idle = setTimeout(() => document.body.classList.add('idle'), 2800);
  }

  // ---------- the screen stays on ----------
  //
  // A tablet propped on the table dims and locks in a minute or two, which is
  // the exact failure this page exists to avoid. Not supported everywhere and
  // refused in some contexts; a refusal is silent because the page works
  // perfectly well without it and a warning would be noise the GM cannot act on.
  async function keepAwake() {
    try {
      P.lock = await navigator.wakeLock?.request('screen');
      P.lock?.addEventListener('release', () => { P.lock = null; });
    } catch { /* see above */ }
  }

  async function fullscreen() {
    try {
      if (document.fullscreenElement) await document.exitFullscreen();
      else await document.documentElement.requestFullscreen();
    } catch { /* a browser may refuse it; nothing else depends on it */ }
  }

  function bind() {
    $('prev').addEventListener('click', () => go(-1));
    $('next').addEventListener('click', () => go(1));
    $('close').addEventListener('click', leave);
    $('fullscreen').addEventListener('click', fullscreen);
    $('reveal').addEventListener('click', toggleReveal);
    document.addEventListener('fullscreenchange', () => {
      $('fullscreen').textContent = document.fullscreenElement ? '⛶ Leave fullscreen' : '⛶ Fullscreen';
    });

    // Arrows, and the two keys a presenter's clicker actually sends. NOT the
    // space bar: space activates whatever button has focus, and the button most
    // likely to have it is the one that shows a picture to the party.
    document.addEventListener('keydown', (e) => {
      wake();
      if (e.key === 'Escape') leave();
      else if (e.key === 'ArrowRight' || e.key === 'PageDown') go(1);
      else if (e.key === 'ArrowLeft' || e.key === 'PageUp') go(-1);
      else if (e.key === 'Home') goTo(0);
      else if (e.key === 'End') goTo(P.images.length - 1);
      else return;
      e.preventDefault();
    });
    for (const ev of ['mousemove', 'pointerdown', 'touchstart', 'wheel']) {
      document.addEventListener(ev, () => wake(), { passive: true });
    }
    // The lock is dropped whenever the tab is hidden and is not handed back, so
    // it has to be asked for again when the page comes forward.
    document.addEventListener('visibilitychange', () => {
      if (document.visibilityState === 'visible' && !P.lock && P.images.length) keepAwake();
    });
  }

  function start(opts) {
    O = opts;
    api = global.mcCampaign.client(opts.base);
    campaignId = opts.campaignId;
    entryId = opts.entryId;
    bind();
    wake();
    return (opts.load || load)();
  }

  global.mcPresent = { start, fail, keepAwake, wake, state: P };
})(globalThis);
