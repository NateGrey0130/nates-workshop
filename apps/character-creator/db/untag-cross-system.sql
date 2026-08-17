-- Skills and psionic powers are available in every system.
--
-- Rifts and Palladium Fantasy share a multiverse: dimensional rifts open onto
-- the Palladium world, and a campaign can legitimately hold both. A skill or a
-- psychic power is not bound to the book it was first printed in — a psychic is
-- a psychic whichever realm they walk into.
--
-- This is a DELIBERATE setting decision, not an oversight. NULL means "every
-- system", which is already how the pickers read an absent tag. Do not "fix" it
-- by tagging these rows from their source_book; that was considered and
-- rejected, and it would strip Carpentry, Sniper, First Aid, Hunting and some
-- thirty others from Palladium characters — including skills the Long Bowman's
-- own O.C.C. list grants.
--
-- Gear is deliberately NOT included. A laser rifle arriving in a medieval realm
-- is an event in play, not something every character picks at creation.

-- Four skills tagged rifts-only while eighty Rifts-sourced ones were not; the
-- inconsistency is the bug, not the untagged majority.
UPDATE skills
   SET systems = NULL
 WHERE systems IS NOT NULL;

-- The Rifts psionics chapter arrived tagged. Untagging it roughly doubles what
-- a Palladium psychic can choose from, and is what makes a major psionic's
-- "eight powers from one category" possible there at all — the largest
-- Palladium-visible category held six.
UPDATE psionic_powers
   SET system = NULL
 WHERE system IS NOT NULL;
