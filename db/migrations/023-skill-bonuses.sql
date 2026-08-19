-- What a skill grants beyond its percentage.
--
--   { "attributes": { "PS": 2 }, "combat": { "attacks": 1, "parry": 2, "dodge": 2 } }
--
-- Physical skills are not only percentile. Boxing is "+1 attack per melee, +2
-- parry & dodge, +1 roll, +2 P.S., +3D6 S.D.C."; Wrestling, Body Building,
-- Running, Athletics, Acrobatics and Gymnastics all print bonuses of the same
-- kind. The catalog had nowhere to put them, so a character who took Boxing
-- gained nothing from it - of 22 Physical rows exactly one recorded its
-- bonuses, as free text in `note`, which nothing reads.
--
-- Same JSON shape a class's `bonuses:` block uses, validated through the same
-- validateBonuses(), so a skill cannot express a bonus a class could not and
-- derive.js needs no new cases.
--
-- Dice values and `pools` are REFUSED for skills, unlike classes. Both need to
-- be rolled once and stored against the character - classes do that at creation
-- through attribute_bonuses/rolled_bonuses, and a skill can be taken at any
-- level, so there is no equivalent moment yet. Accepting them here would store
-- Boxing's +3D6 S.D.C. and silently never apply it, which is the failure this
-- column exists to end. They stay in `note` until that work lands.
--
-- One-shot. Run once per environment, in filename order.
ALTER TABLE skills ADD COLUMN bonuses TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('023-skill-bonuses.sql');
