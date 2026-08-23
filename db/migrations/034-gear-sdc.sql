-- Structural Damage Capacity, which is half of what Palladium armour IS.
--
-- The book does not treat this as a detail. Printed 270, under Body Armor:
-- "The two attributes of armor are the Armor Rating (A.R.) and the Structural
-- Damage Capacity (S.D.C.)." The Types of Armor table has a column for it, and
-- the rules that follow spend it: damage is subtracted from a suit's S.D.C.,
-- at half S.D.C. the A.R. drops two points, at a third it drops two more, and
-- at zero the armour is gone and the body is open to attack.
--
-- `gear` had `ar` and `mdc` and nothing for it, so all six Palladium suits kept
-- the number in free-text description - "Full suit of chain mail. A.R. 14, 44
-- S.D.C." - where no sheet, no arithmetic and no enchantment can reach it. A
-- prose field is where a number goes to stop being one.
--
-- INTEGER alongside `ar` and `mdc` rather than TEXT, for the same reason those
-- two are numbers: the sheet's armour block subtracts from it. Rifts M.D.C.
-- armour keeps `mdc` and leaves this NULL, which is the honest distinction -
-- S.D.C. and M.D.C. are different scales and a suit has one or the other.
--
-- It is not only armour. Anything solid enough to be broken has an S.D.C.: a
-- walkie-talkie is 30, polarized goggles 15, a small shield 30. The column
-- holds an object's own durability and nothing else - notably NOT the "1D6
-- S.D.C." a knife DEALS, which is damage and already lives in `damage`.

ALTER TABLE gear ADD COLUMN sdc INTEGER;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('034-gear-sdc.sql');
