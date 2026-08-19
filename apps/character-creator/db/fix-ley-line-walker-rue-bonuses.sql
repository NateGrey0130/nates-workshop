-- The Ley Line Walker's O.C.C. bonuses, corrected against Rifts Ultimate
-- Edition p.116 (#13, O.C.C. Bonuses). Two misreadings, verified against the
-- page:
--
--   - "+3 to save vs curses" is FLAT; the stored entry had it arriving at
--     levels 3/9/11/14 instead.
--   - "+1 to save vs magic at levels three, six, nine, eleven and fourteen"
--     was missing entirely - the leveled thing is the MAGIC save, not curses.
--   - "insanity: 2" appears in no edition's bonus list and is removed.
--
-- Not modeled, stated in the class prose: +1D4 on any one Mental attribute,
-- +1 Spell Strength at levels 3/7/10/13, +1 Perception at 2/5/7/10/13
-- (double on a ley line).
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-ley-line-walker-rue-bonuses.sql
--
-- Guarded on the exact old block; re-running does nothing.

UPDATE imported_classes SET
  markdown = replace(markdown,
  'bonuses:' || char(10) ||
  '  saves: { horror_factor: 4, possession: 2, insanity: 2, mind_control: 2 }' || char(10) ||
  '  at_level:' || char(10) ||
  '    - { level: 3, saves: { curses: 3 } }' || char(10) ||
  '    - { level: 9, saves: { curses: 3 } }' || char(10) ||
  '    - { level: 11, saves: { curses: 3 } }' || char(10) ||
  '    - { level: 14, saves: { curses: 3 } }',
  'bonuses:' || char(10) ||
  '  saves: { horror_factor: 4, possession: 2, mind_control: 2, curses: 3 }' || char(10) ||
  '  at_level:' || char(10) ||
  '    - { level: 3, saves: { spell_magic: 1, ritual_magic: 1 } }' || char(10) ||
  '    - { level: 6, saves: { spell_magic: 1, ritual_magic: 1 } }' || char(10) ||
  '    - { level: 9, saves: { spell_magic: 1, ritual_magic: 1 } }' || char(10) ||
  '    - { level: 11, saves: { spell_magic: 1, ritual_magic: 1 } }' || char(10) ||
  '    - { level: 14, saves: { spell_magic: 1, ritual_magic: 1 } }'),
  updated_at = datetime('now')
WHERE class_id = 'ley-line-walker'
  AND instr(markdown, 'insanity: 2') > 0;

-- Read the result back rather than trusting the exit code.
SELECT class_id,
       instr(markdown, 'spell_magic: 1') > 0 AS has_magic_saves,
       instr(markdown, 'insanity: 2') > 0 AS still_has_insanity,
       instr(markdown, 'curses: 3 }') > 0 AS curses_flat
FROM imported_classes WHERE class_id = 'ley-line-walker';
