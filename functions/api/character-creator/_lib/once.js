// A load made once per REQUEST, however many times the request asks for it.
//
// Rolling ten NPCs calls createCharacter ten times, and each call read the
// campaign, both class rows, the race-and-occupation verdict and every skill's
// category again - the same answers, ten times. A campaign roster did the same
// with the class of every character holding a second form. The handler makes
// one Map, hands it down as `loads`, and anything keyed the same is read once.
//
// `loads` is the caller's and dies with the request. It is NOT a module-level
// cache: an isolate outlives a request, and a class edited between two
// requests must be read again by the second. Pass nothing and every call
// loads for itself, which is what every other caller still does.
//
// The PROMISE is stored, so two callers that ask before the first answer
// arrives share one read. What comes back is shared too: treat it as read-only.
export function once(loads, key, load) {
  if (!loads) return load();
  if (!loads.has(key)) loads.set(key, load());
  return loads.get(key);
}
