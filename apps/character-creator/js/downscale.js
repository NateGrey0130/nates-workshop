// Shrink a picture in the browser before it is uploaded. UI-AUDIT F57, option A.
//
// WHY IN THE BROWSER AND NOT ON THE WAY OUT. This platform cannot resize an
// image: `docs/pages-to-workers-migration.md` has a row for the Image Resizing
// binding reading "Workers yes, Pages no", with NPC portraits served at full
// size as its worked example. So a 5MB scan of a two-page map spread reaches a
// phone as 5MB, and the two list views that show it cap the picture at 160px
// and 70vh - they download the whole thing to paint a fraction of it. The only
// place the bytes can be made smaller is before they leave.
//
// A CLASSIC SCRIPT with one global, like sticky.js and derive.js, because the
// pages that need it are not modules and because the NPC portrait upload in
// apps/campaign/campaign.js is the second caller waiting to happen - see
// UI-AUDIT F59, which is that half, filed rather than taken.
//
// EVERY REFUSAL RETURNS THE ORIGINAL FILE. Nothing here is allowed to stop an
// upload: a canvas that will not decode, a browser without createImageBitmap,
// a re-encode that comes out bigger - each one hands the original back and the
// upload proceeds exactly as it did before this file existed.
(function (global) {
  'use strict';

  // 2048 on the longest edge. Present mode is the only view that wants more
  // than about 1000 CSS px, and it is full-screen: 2048 covers a 1024pt tablet
  // at device-pixel-ratio 2 with room over. Larger than that is detail no
  // screen in this app can render.
  const MAX_EDGE = 2048;

  // GIF IS NEVER RE-ENCODED, and this is the whole reason the type is chosen
  // rather than defaulted. `canvas.toBlob` cannot produce image/gif - browsers
  // fall back to PNG for a type they cannot write - so re-encoding an animated
  // gif silently flattens it to one frame. The upload allowlist accepts gif, so
  // this path has to exist and it has to be "leave it alone".
  const REENCODABLE = new Set(['image/jpeg', 'image/png', 'image/webp']);

  function blobFrom(canvas, type) {
    return new Promise((resolve) => canvas.toBlob(resolve, type, 0.9));
  }

  // Returns the blob to upload: a smaller one, or the original file untouched.
  // The CALLER MUST TAKE THE CONTENT TYPE FROM WHAT THIS RETURNS, not from the
  // File it passed in - the server derives the R2 key's extension, the stored
  // content_type and the Content-Type it later serves from that one header, so
  // a re-encoded blob described by the original file's type would be wrong in
  // three places at once.
  async function toUpload(file, maxEdge = MAX_EDGE) {
    try {
      if (!file || !REENCODABLE.has(file.type)) return file;
      if (typeof createImageBitmap !== 'function') return file;

      const bmp = await createImageBitmap(file);
      const longest = Math.max(bmp.width, bmp.height);
      // Already small enough: hand back the original bytes rather than a
      // re-encode of them. A round trip through a canvas is lossy for a JPEG
      // and pointless for everything else.
      if (longest <= maxEdge) { bmp.close?.(); return file; }

      const scale = maxEdge / longest;
      const canvas = document.createElement('canvas');
      canvas.width = Math.round(bmp.width * scale);
      canvas.height = Math.round(bmp.height * scale);
      const ctx = canvas.getContext('2d');
      if (!ctx) { bmp.close?.(); return file; }
      ctx.drawImage(bmp, 0, 0, canvas.width, canvas.height);
      bmp.close?.();

      // The SAME type out as in. A PNG carries transparency a JPEG would fill
      // in, and this is a map or a portrait rather than a photograph to
      // optimise - the point is the pixel count, not the codec.
      const out = await blobFrom(canvas, file.type);
      // A small PNG re-encoded can come out LARGER than it went in. If the
      // work made things worse, it did not happen.
      if (!out || out.size >= file.size) return file;
      return out;
    } catch {
      return file;            // see the header: never block an upload
    }
  }

  global.downscale = { toUpload, MAX_EDGE };
})(globalThis);
