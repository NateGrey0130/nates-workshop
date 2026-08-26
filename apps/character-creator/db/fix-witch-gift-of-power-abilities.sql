-- The Witch's Gift of Power becomes a real choose-four, instead of eleven
-- abilities described in one paragraph that grants nothing.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-witch-gift-of-power-abilities.sql
--
-- CLASS-AUDIT.md S6. The Gift of Power witch picks FOUR abilities from eleven,
-- permanently - they never improve with level. All eleven were stored as a
-- single prose ability whose whole content was one description string, so the
-- player picked nothing and the sheet added nothing up.
--
-- The note explaining why said the eleven "would need bonuses the shape cannot
-- express together". That stopped being true: special_abilities validates a
-- choice group, and ABILITY_GRANTS lets a named ability carry bonuses, psionics
-- and magic through the same validateBonuses() a class uses. applyAbilities
-- then folds in the bonuses of abilities the character actually CHOSE.
--
-- SEVEN of the eleven carry real bonuses now. FOUR stay prose, and the reason
-- is the same in each case - what they grant has no field to go in: an immunity
-- (not a save bonus), a constant sense, a flight speed that applies only while
-- flying, and a healing rate. Those are prose by the rule that conditional and
-- unmodellable effects are prose, not by a gap worth filing again.
--
-- THE SIXTH SENSE GRANT IS DELIBERATELY LEFT PROSE, and this is the one
-- judgement call in the script. An ability-level `psionics` block REPLACES the
-- character's psionics block rather than merging into it (parser.js, applyAbilities:
-- the stronger tier wins). This class has no psionics block at all, so granting
-- Sixth Sense here would install one with no `type` - inventing a psychic tier
-- the book never states, on a class whose I.S.P. can also arrive from a
-- different gift. The saves that ability grants ARE modelled; only the power is
-- prose. Better a stated gap than an invented fact.
--
-- IT ALSO CLOSES A HOLE. The gift-of-power variant carried
--   ppe_base: "2d4x10+20, but only if the P.P.E. ability is one of the four
--              selected; otherwise none"
-- - a CONDITION written inside a field that holds a dice formula. leveling.js
-- feeds ppe_base straight into perLevelDiceOf, so a condition expressed as prose
-- there cannot be enforced: the P.P.E. either reached every Gift of Power witch
-- including those who never picked it, or the string failed to parse and none
-- did. The P.P.E. now rides on the pick, where the condition actually lives, and
-- the variant's ppe_base is removed. There is no top-level ppe_base, so a Gift
-- of Power witch who does not take that gift correctly has none.
--
-- WHY THE MARKERS. SQLite caps an expression tree at depth 100 and a `||` chain
-- is one node per term, so a forty-line block cannot be spliced in one
-- statement. It goes in three chunks behind sequential markers. Each statement
-- is guarded by its own marker, so the sequence is idempotent - a second run
-- fires nothing - and an interrupted run leaves the marker that names where it
-- stopped.

-- 1. The old single ability out, the first marker in.
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         '  - name: "Gift of Power: select four"' || char(10) ||
         '    description: "The Gift of Power grants FOUR abilities chosen from eleven, and they never improve - skills rise with experience, the gifts do not. The eleven: add 1D6x10+40 I.S.P.; add 2D4x10+20 P.P.E.; impervious to poisons, toxins, drugs, gases and disease; Super Tough, adding 200 physical S.D.C. and healing twice as fast; +2 to save vs all magic and possession; see the invisible and sense magic, automatic; increased mental endurance, +3 vs horror factor, +1 vs psionic attack and all mind control, plus the psionic power of Sixth Sense; flight at will and without limit at Spd 1D6x10+44; supernatural strength and endurance, +10 P.S., rarely fatigues, double damage to mortals and normal damage to demons and creatures of magic otherwise vulnerable only to magic; increased physical prowess, +10 P.P. with the appropriate bonuses and +2 initiative; bio-regeneration restoring 1D4x10 S.D.C. and 4D6 hit points per hour. A demon familiar may be added later at fourth level or higher if the monster feels generous."',
         '@@GOP1@@')
 WHERE class_id = 'witch'
   AND instr(markdown, '  - name: "Gift of Power: select four"') > 0;

-- 2. Chunk A: the framing ability, the choose group, and the first three gifts.
UPDATE imported_classes
   SET markdown = replace(markdown, '@@GOP1@@',
         '  - name: "Gift of Power: select four"' || char(10) ||
         '    description: "The Gift of Power grants FOUR abilities chosen from eleven, and they never improve - skills rise with experience, the gifts do not. Four of the eleven are recorded as prose because what they grant has no field to hold it: an immunity, a constant sense, a flight speed that applies only while flying, and a healing rate. A demon familiar may be added later at fourth level or higher if the monster feels generous."' || char(10) ||
         '  - { choose: 4, from: ["Gift: I.S.P.", "Gift: P.P.E.", "Gift: Impervious", "Gift: Super Tough", "Gift: Resist Magic", "Gift: See the Invisible", "Gift: Mental Endurance", "Gift: Flight", "Gift: Supernatural Strength", "Gift: Physical Prowess", "Gift: Bio-Regeneration"] }' || char(10) ||
         '  - name: "Gift: I.S.P."' || char(10) ||
         '    description: "Add 1D6x10+40 I.S.P."' || char(10) ||
         '    bonuses:' || char(10) ||
         '      pools: { isp: "1d6x10+40" }' || char(10) ||
         '  - name: "Gift: P.P.E."' || char(10) ||
         '    description: "Add 2D4x10+20 P.P.E. The gift-of-power variant used to state this conditionally in ppe_base, where the condition could not be enforced; it arrives with the pick instead."' || char(10) ||
         '    bonuses:' || char(10) ||
         '      pools: { ppe: "2d4x10+20" }' || char(10) ||
         '  - name: "Gift: Impervious"' || char(10) ||
         '    description: "Impervious to poisons, toxins, drugs, gases and disease. An immunity rather than a bonus to save against them, so it is not written as one."' || char(10) ||
         '@@GOP2@@')
 WHERE class_id = 'witch' AND instr(markdown, '@@GOP1@@') > 0;

-- 3. Chunk B: Super Tough, Resist Magic, See the Invisible, Mental Endurance.
UPDATE imported_classes
   SET markdown = replace(markdown, '@@GOP2@@',
         '  - name: "Gift: Super Tough"' || char(10) ||
         '    description: "Adds 200 physical S.D.C. and heals twice as fast. The S.D.C. is modelled; the healing rate is prose, because no field holds a rate."' || char(10) ||
         '    bonuses:' || char(10) ||
         '      pools: { sdc: 200 }' || char(10) ||
         '  - name: "Gift: Resist Magic"' || char(10) ||
         '    description: "+2 to save vs all magic and possession. Written against the two magic saves the schema holds, spell and ritual, plus possession."' || char(10) ||
         '    bonuses:' || char(10) ||
         '      saves: { spell_magic: 2, ritual_magic: 2, possession: 2 }' || char(10) ||
         '  - name: "Gift: See the Invisible"' || char(10) ||
         '    description: "See the invisible and sense magic, both automatic and constant."' || char(10) ||
         '  - name: "Gift: Mental Endurance"' || char(10) ||
         '    description: "+3 vs horror factor, +1 vs psionic attack and all mind control, plus the psionic power of Sixth Sense. The three saves are modelled. The Sixth Sense grant is not: an ability-level psionics block replaces the character psionics block rather than merging into it, and this class has none, so granting it here would invent a psychic tier the book never states."' || char(10) ||
         '    bonuses:' || char(10) ||
         '      saves: { horror_factor: 3, psionics: 1, mind_control: 1 }' || char(10) ||
         '@@GOP3@@')
 WHERE class_id = 'witch' AND instr(markdown, '@@GOP2@@') > 0;

-- 4. Chunk C: the last four gifts, and the marker goes away with it.
UPDATE imported_classes
   SET markdown = replace(markdown, '@@GOP3@@',
         '  - name: "Gift: Flight"' || char(10) ||
         '    description: "Flight at will and without limit at Spd 1D6x10+44. The Spd applies only while flying, and a conditional bonus is prose by rule."' || char(10) ||
         '  - name: "Gift: Supernatural Strength"' || char(10) ||
         '    description: "Supernatural strength and endurance: +10 P.S., rarely fatigues, double damage to mortals, and normal damage to demons and creatures of magic otherwise vulnerable only to magic. The +10 P.S. is modelled; the damage riders are prose."' || char(10) ||
         '    bonuses:' || char(10) ||
         '      attributes: { PS: 10 }' || char(10) ||
         '  - name: "Gift: Physical Prowess"' || char(10) ||
         '    description: "Increased physical prowess: +10 P.P. with the appropriate bonuses, and +2 initiative."' || char(10) ||
         '    bonuses:' || char(10) ||
         '      attributes: { PP: 10 }' || char(10) ||
         '      combat: { initiative: 2 }' || char(10) ||
         '  - name: "Gift: Bio-Regeneration"' || char(10) ||
         '    description: "Bio-regeneration restoring 1D4x10 S.D.C. and 4D6 hit points per hour. A rate, which no field holds."')
 WHERE class_id = 'witch' AND instr(markdown, '@@GOP3@@') > 0;

-- 5. The variant stops stating a condition it cannot enforce.
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         '    name: "Witch (Gift of Power)"' || char(10) ||
         '    ppe_base: "2d4x10+20, but only if the P.P.E. ability is one of the four selected; otherwise none"',
         '    name: "Witch (Gift of Power)"')
 WHERE class_id = 'witch'
   AND instr(markdown, 'but only if the P.P.E. ability is one of the four selected') > 0;

-- 6. The note that said this could not be done. Rewritten in the same script as
--    the fix, per the claim-audit rule - a note outliving its limitation is the
--    exact rot this audit item exists to clear.
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         'The Gift of Power''s four-from-eleven is the one part that would fit special_abilities'' own choose group; it is written out as a single ability instead because several of the eleven grant things - +10 P.S., 200 S.D.C., a psionic power, unlimited flight - that would need bonuses the shape cannot express together.',
         'The Gift of Power''s four-from-eleven is a real choose group: eleven ability definitions and a choose-four over them, with bonuses on the seven that grant something the schema holds. Four stay prose because what they grant has no field - an immunity, a constant sense, a flight speed that applies only while flying, and a healing rate. The Sixth Sense grant stays prose for a different reason: an ability-level psionics block replaces the character block rather than merging with it, and this class has none, so granting it would invent a psychic tier the book never states.')
 WHERE class_id = 'witch'
   AND instr(markdown, 'that would need bonuses the shape cannot express together.') > 0;

-- Readback one: the shape changed and no marker survived.
SELECT instr(markdown, '@@GOP')                                              AS no_marker_left,
       instr(markdown, 'The eleven: add 1D6x10+40')                          AS old_paragraph_gone,
       (instr(markdown, '{ choose: 4, from: ["Gift: I.S.P."') > 0)           AS choose_group_present,
       instr(markdown, 'but only if the P.P.E. ability')                     AS conditional_ppe_gone,
       instr(markdown, 'cannot express together')                            AS stale_note_gone
  FROM imported_classes WHERE class_id = 'witch';

-- Readback two: the seven that carry bonuses all landed. Summed rather than
-- UNIONed - D1 rejects a compound SELECT of six or more terms.
SELECT (instr(markdown, 'pools: { isp: "1d6x10+40" }') > 0)
     + (instr(markdown, 'pools: { ppe: "2d4x10+20" }') > 0)
     + (instr(markdown, 'pools: { sdc: 200 }') > 0)
     + (instr(markdown, 'saves: { spell_magic: 2, ritual_magic: 2, possession: 2 }') > 0)
     + (instr(markdown, 'saves: { horror_factor: 3, psionics: 1, mind_control: 1 }') > 0)
     + (instr(markdown, 'attributes: { PS: 10 }') > 0)
     + (instr(markdown, 'combat: { initiative: 2 }') > 0)   AS bonus_gifts_of_seven
  FROM imported_classes WHERE class_id = 'witch';

-- Records this run. Every statement above guards itself, so re-running is safe.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-witch-gift-of-power-abilities.sql');
