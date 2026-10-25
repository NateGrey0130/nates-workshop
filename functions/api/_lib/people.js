// Who can sign in to the Workshop, as far as a Function can know it. Moved here
// from functions/api/media-vault/shares.js so that more than one app can offer
// and re-check the same closed list of people; MediaVault's sharing was the
// first, and the rules below were written for it.

// Enough to reject a typo and a paste of something that is not an address at
// all. NOT an authorization test - that is the candidate list.
export const looksLikeEmail = (s) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(s);

// The one case convention for an address compared against another request's
// identity: trimmed and lowercased, because the middleware already treats the
// two cases as one identity (functions/api/_middleware.js compares header and
// token lowercased).
export const normalizeEmail = (s) => String(s || '').trim().toLowerCase();

// WHO CAN ACTUALLY SIGN IN, mirrored by hand from the Cloudflare Access allow
// policy into MV_SHARE_CANDIDATES (a Pages environment variable). SHARE-AUDIT V4.
//
// WHY A MIRROR RATHER THAN THE REAL LIST. A Function COULD read the live policy
// - `GET /accounts/{id}/access/apps/{app}/policies` is an ordinary API call -
// and that option was declined on cost rather than being impossible: it means a
// standing account-scoped Cloudflare credential living in the deployment to
// serve a list short enough to read at a glance and edited by hand. An
// earlier version of
// this comment said no Function could read it and cited CLAUDE.md, which says
// no such thing; CLAUDE.md's `Three credentials` table is about what an agent
// on Nate's machine should reach for. Corrected rather than repeated.
//
// SO IT CAN GO STALE, AND THE DIRECTION MATTERS. A stale list fails CLOSED: the
// person just added to Access is not offered, the owner asks Nate, the variable
// catches up. The alternative shape - free text with a "pending" badge - fails
// OPEN, letting an owner grant to an address that can never sign in and produce
// a share that silently never works.
//
// NOTHING CAN COMPARE THE TWO LISTS, AND SOMETHING CAN COMPARE THEIR LENGTHS.
// `V6` declined a check on the ground that "there is no request that reveals who
// is on an email allow list", which is true and does not cover a COUNT: the GET
// in functions/api/media-vault/shares.js reports `candidateCount`, the number of
// addresses the mirror holds, and that is compared by hand against the Access
// policy's rule count. No address leaves the deployment. SHARE-AUDIT V8, filed
// when the policy had grown to seven while shares.js still described five.
// SETUP.md carries the comparison beside the step that changes them.
//
// UNSET MEANS NOBODY, deliberately, the same posture isAdminEmail takes for
// ADMIN_EMAIL: a missing variable must not mean "allow anyone".
export function shareCandidates(env) {
  return String((env && env.MV_SHARE_CANDIDATES) || '')
    .split(/[\s,;]+/)
    .map((s) => s.trim().toLowerCase())
    .filter((s) => looksLikeEmail(s));
}
