// Pool changes that could not reach the server yet.
//
// WHAT THIS DOES AND DOES NOT PROMISE. It survives a network drop and a reload
// while the tab is open, and it does NOT make the app work offline: nothing
// here serves the page, so closing the tab with no connection means the sheet
// will not load at all next time. That needs a service worker, which on a site
// that deploys on every merge brings a cache-invalidation problem of its own,
// and is deliberately not in scope. "Queued" is the honest word for this, not
// "offline".
//
// IndexedDB rather than localStorage for two reasons. It is asynchronous, so a
// long fight's worth of queued events cannot jank the thumb-sized +/- buttons
// that write them; and localStorage is a per-origin string budget shared with
// every other app in this workshop, which is the wrong place for a queue whose
// length is decided by how long the wi-fi is out.
//
// Classic script, one global, same shape as derive.js and rules.js.
(function (global) {
  'use strict';

  const DB_NAME = 'cc-play-queue';
  const STORE = 'pending';
  const VERSION = 1;

  let dbPromise = null;

  function open() {
    if (dbPromise) return dbPromise;
    dbPromise = new Promise((resolve, reject) => {
      // Private windows and browsers with site data blocked throw here rather
      // than returning null, and a sheet that cannot queue must still work.
      let req;
      try { req = indexedDB.open(DB_NAME, VERSION); } catch (e) { reject(e); return; }
      req.onupgradeneeded = () => {
        const db = req.result;
        if (!db.objectStoreNames.contains(STORE)) {
          // autoIncrement gives the queue its order for free, and order is the
          // whole contract: two adjustments to the same pool only compose if
          // they are replayed in the sequence they were made.
          db.createObjectStore(STORE, { keyPath: 'seq', autoIncrement: true });
        }
      };
      req.onsuccess = () => resolve(req.result);
      req.onerror = () => reject(req.error);
    });
    return dbPromise;
  }

  const tx = async (mode, fn) => {
    const db = await open();
    return new Promise((resolve, reject) => {
      const t = db.transaction(STORE, mode);
      const store = t.objectStore(STORE);
      let out;
      try { out = fn(store); } catch (e) { reject(e); return; }
      t.oncomplete = () => resolve(out && out.result !== undefined ? out.result : out);
      t.onerror = () => reject(t.error);
      t.onabort = () => reject(t.error);
    });
  };

  // One queued write. `characterId` is stored on every row because a player
  // with two characters open in two tabs shares one database.
  async function push(entry) {
    return tx('readwrite', (s) => s.add({ ...entry, queued_at: Date.now() }));
  }

  async function all(characterId) {
    const db = await open();
    return new Promise((resolve, reject) => {
      const out = [];
      const req = db.transaction(STORE, 'readonly').objectStore(STORE).openCursor();
      req.onsuccess = () => {
        const c = req.result;
        if (!c) { resolve(out); return; }
        if (characterId == null || c.value.characterId === characterId) out.push(c.value);
        c.continue();
      };
      req.onerror = () => reject(req.error);
    });
  }

  async function remove(seq) {
    return tx('readwrite', (s) => s.delete(seq));
  }

  async function count(characterId) {
    return (await all(characterId)).length;
  }

  async function clear(characterId) {
    for (const e of await all(characterId)) await remove(e.seq);
  }

  // Whether the queue can be used at all. A browser that refuses IndexedDB
  // gets the old behaviour - a failed write rolls back - rather than an error.
  async function available() {
    try { await open(); return true; } catch { return false; }
  }

  global.playQueue = { push, all, remove, count, clear, available };
})(globalThis);
