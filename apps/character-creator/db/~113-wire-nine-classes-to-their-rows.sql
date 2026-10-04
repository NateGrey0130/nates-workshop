-- Nine classes wired to rows the catalog already holds: seven cyborg bodies,
-- the Time Master's temporal magic and the Summoner's circles.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~113-wire-nine-classes-to-their-rows.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~113-wire-nine-classes-to-their-rows.sql
--
-- ~085 added the four Dragon 'Borg and three Geo-Borg bodies as `borg` vessel
-- rows, and ~091 added the 25 Temporal Magic spells and the 51 Palladium
-- Fantasy circles. Both said in their headers that no class was wired to the
-- new rows, and ~092 wrote that into four class notes. This is the wiring
-- (close-out package A7, Nate's ruling 7 of 2026-10-04).
--
-- THE SEVEN BODIES take the shape BOOK-INGEST-AUDIT F41 settled for a class
-- whose book issues it a vessel (~018): a gear row whose slug is the vessel's
-- own, carrying vehicle_slug, listed in equipment_starting. No frontmatter key
-- and no code. Cost and main body M.D.C. are the vessel row's; weight is the
-- vessel's printed weight in pounds (the Lion's "2 tons" is 4000, the
-- Demon-Eater's "One ton" 2000). Each class still describes its body in
-- special_abilities; nothing is removed.
--
-- THE TIME MASTER (Phase World printed 28): two temporal spells and two
-- regular spells of levels 1-3 at first level, then one temporal and one
-- normal spell of the character's level or lower at every level. Until now
-- only the normal half was granted. The temporal half is a named list, the 25
-- rows of ~091; "of the same or lower level as the character" is read as
-- bounding the normal spell only, since the temporal list starts at spell
-- level 7. A schedule replaces a flat spells_per_level (js/leveling.js), so
-- both picks are schedule entries for levels 2 to 15.
--
-- THE SUMMONER (Palladium Fantasy printed 135): "knows all protection and
-- summoning circles" and "starts with no power circles". The magic block
-- grants the 18 protection and 15 summoning circles by name and learns nothing
-- by level; the 18 power circles are acquired in play and are not offered.
--
-- Every replace() is guarded on the text it replaces and on the new text being
-- absent, so a second run is a no-op. MUST SORT AFTER ~085, ~091 and ~092.
-- THIS SCRIPT CHANGES PRODUCTION: nine class rows and seven new gear rows.

INSERT OR IGNORE INTO gear
  (slug, name, system, category, weight_lbs, cost, cost_note, is_mega_damage,
   mdc, description, source_book, vehicle_slug)
VALUES
  ('at-c8000-wing-blade-cyborg', 'AT-C8000 Wing Blade Dragon ''Borg', 'rifts', 'vehicle',
   1000, 6000000, 'Six million credits with all standard features and weapons. Poor availability; outside of the Republic only Ichto makes them, and at 10% more money. Armatech makes the dragon ''borgs exclusively for the military and police of the Republic of Japan; they are not available to the public.',
   1, 270,
   'The Republic of Japan''s winged dragon ''borg body, which the dragon-borg-wing-blade class is built into. Its M.D.C. by location and weapon systems are the vessel of the same slug; this row exists so the class can list the body in its starting equipment.',
   'Rifts World Book 8: Japan p.101-102', 'at-c8000-wing-blade-cyborg'),

  ('at-c9000-tsunami-cyborg', 'AT-C9000 Tsunami Dragon ''Borg', 'rifts', 'vehicle',
   1200, 8000000, 'Eight million credits with all standard features and weapons. Poor availability; outside of the Republic only Ichto makes them, and at 10% more money. Armatech makes the dragon ''borgs exclusively for the military and police of the Republic of Japan; they are not available to the public.',
   1, 320,
   'The Republic of Japan''s amphibious dragon ''borg body, which the dragon-borg-tsunami class is built into. Its M.D.C. by location and weapon systems are the vessel of the same slug; this row exists so the class can list the body in its starting equipment.',
   'Rifts World Book 8: Japan p.102-105', 'at-c9000-tsunami-cyborg'),

  ('at-c10000-imperial-dragon-cyborg', 'AT-C10000 Imperial Dragon Combat ''Borg', 'rifts', 'vehicle',
   1500, 10000000, 'Ten million credits with all standard features and weapons. Poor availability; outside of the Republic only Ichto makes them, and at 10% more money. Armatech makes the dragon ''borgs exclusively for the military and police of the Republic of Japan; they are not available to the public.',
   1, 350,
   'The Republic of Japan''s four-legged dragon combat ''borg body, which the dragon-borg-imperial-combat class is built into. Its M.D.C. by location and weapon systems are the vessel of the same slug; this row exists so the class can list the body in its starting equipment.',
   'Rifts World Book 8: Japan p.105-107', 'at-c10000-imperial-dragon-cyborg'),

  ('at-c12000-flame-cloud-cyborg', 'AT-C12000 Flame Cloud Dragon Attack ''Borg', 'rifts', 'vehicle',
   1500, 12000000, 'Twelve million credits with all standard features and weapons. Poor availability; outside of the Republic only Ichto makes them, and at 10% more money. Armatech makes the dragon ''borgs exclusively for the military and police of the Republic of Japan; they are not available to the public.',
   1, 320,
   'The Republic of Japan''s flying dragon attack ''borg body, which the dragon-borg-flame-cloud class is built into. Its M.D.C. by location and weapon systems are the vessel of the same slug; this row exists so the class can list the body in its starting equipment.',
   'Rifts World Book 8: Japan p.107-109', 'at-c12000-flame-cloud-cyborg'),

  ('db-800-demon-eater-cyborg', 'Demon-Eater Cyborg (DB-800)', 'rifts', 'vehicle',
   2000, 12000000, '12 million credits.',
   1, 220,
   'The Geofront''s heavy Demon-Eater cyborg body, which the geofront-demon-eater-geo-borg class is built into. Its M.D.C. by location and weapon systems are the vessel of the same slug; this row exists so the class can list the body in its starting equipment.',
   'Rifts World Book 25: China 2 p.128-130', 'db-800-demon-eater-cyborg'),

  ('ab-830-assault-geo-borg', 'Assault Geo-Borg (AB-830)', 'rifts', 'vehicle',
   600, 8000000, '8 million credits.',
   1, 180,
   'The Geofront''s Assault Geo-Borg body, which the geofront-assault-geo-borg class is built into. Its M.D.C. by location and weapon systems are the vessel of the same slug; this row exists so the class can list the body in its starting equipment.',
   'Rifts World Book 25: China 2 p.130-131', 'ab-830-assault-geo-borg'),

  ('ab-955-lion-geo-borg', 'Lion Geo-Borg (AB-955)', 'rifts', 'vehicle',
   4000, 8000000, 'Mass production should get the cost down to around 8-10 million credits.',
   1, 280,
   'The Geofront''s lion-shaped Geo-Borg body, which the geofront-lion-geo-borg class is built into. Its M.D.C. by location and weapon systems are the vessel of the same slug; this row exists so the class can list the body in its starting equipment.',
   'Rifts World Book 25: China 2 p.131-132', 'ab-955-lion-geo-borg');

UPDATE imported_classes
   SET markdown = replace(markdown,
         'equipment_starting:
',
         'equipment_starting:
  - { item_id: "at-c8000-wing-blade-cyborg", qty: 1, note: "The cyborg body itself. This row points at the vessel of the same slug, which holds the body''s M.D.C. by location and its built-in weapons." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'dragon-borg-wing-blade'
   AND instr(markdown, 'equipment_starting:
') > 0
   AND instr(markdown, ' This row points at the vessel of the same slug, which holds the body''s M.D.C. by location and its built-in weapons." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The body is the vehicles row at-c8000-wing-blade-cyborg (since ~085); the class is not wired to it, and the chassis is still in special_abilities, side_effects and the body.',
         'The body is the vehicles row at-c8000-wing-blade-cyborg (since ~085), and equipment_starting lists the gear pointer of the same slug (since ~113), which is how the sheet reaches it; the chassis is also still described in special_abilities, side_effects and the body.'),
       updated_at = datetime('now')
 WHERE class_id = 'dragon-borg-wing-blade'
   AND instr(markdown, 'The body is the vehicles row at-c8000-wing-blade-cyborg (since ~085); the class is not wired to it, and the chassis is s') > 0
   AND instr(markdown, ' which is how the sheet reaches it; the chassis is also still described in special_abilities, side_effects and the body.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'equipment_starting:
',
         'equipment_starting:
  - { item_id: "at-c9000-tsunami-cyborg", qty: 1, note: "The cyborg body itself. This row points at the vessel of the same slug, which holds the body''s M.D.C. by location and its built-in weapons." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'dragon-borg-tsunami'
   AND instr(markdown, 'equipment_starting:
') > 0
   AND instr(markdown, ' This row points at the vessel of the same slug, which holds the body''s M.D.C. by location and its built-in weapons." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '(this one is at-c9000-tsunami-cyborg), but the class is not wired to its row, so the body''s locations, weapons, movement and features are still special_abilities here.',
         '(this one is at-c9000-tsunami-cyborg), and equipment_starting lists the gear pointer of the same slug (since ~113), which is how the sheet reaches it; the body''s locations, weapons, movement and features are also still special_abilities here.'),
       updated_at = datetime('now')
 WHERE class_id = 'dragon-borg-tsunami'
   AND instr(markdown, '(this one is at-c9000-tsunami-cyborg), but the class is not wired to its row, so the body''s locations, weapons, movement') > 0
   AND instr(markdown, 'is how the sheet reaches it; the body''s locations, weapons, movement and features are also still special_abilities here.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'equipment_starting:
',
         'equipment_starting:
  - { item_id: "at-c10000-imperial-dragon-cyborg", qty: 1, note: "The cyborg body itself. This row points at the vessel of the same slug, which holds the body''s M.D.C. by location and its built-in weapons." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'dragon-borg-imperial-combat'
   AND instr(markdown, 'equipment_starting:
') > 0
   AND instr(markdown, ' This row points at the vessel of the same slug, which holds the body''s M.D.C. by location and its built-in weapons." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '(the vehicles row at-c10000-imperial-dragon-cyborg holds this body since ~085; the class is not wired to it)',
         '(the vehicles row at-c10000-imperial-dragon-cyborg holds this body since ~085, and equipment_starting lists the gear pointer of the same slug (since ~113), which is how the sheet reaches it)'),
       updated_at = datetime('now')
 WHERE class_id = 'dragon-borg-imperial-combat'
   AND instr(markdown, '(the vehicles row at-c10000-imperial-dragon-cyborg holds this body since ~085; the class is not wired to it)') > 0
   AND instr(markdown, 'ce ~085, and equipment_starting lists the gear pointer of the same slug (since ~113), which is how the sheet reaches it)') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'equipment_starting:
',
         'equipment_starting:
  - { item_id: "at-c12000-flame-cloud-cyborg", qty: 1, note: "The cyborg body itself. This row points at the vessel of the same slug, which holds the body''s M.D.C. by location and its built-in weapons." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'dragon-borg-flame-cloud'
   AND instr(markdown, 'equipment_starting:
') > 0
   AND instr(markdown, ' This row points at the vessel of the same slug, which holds the body''s M.D.C. by location and its built-in weapons." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'BODY: main body 320 M.D.C. as mdc_base; the other locations are prose.',
         'BODY: main body 320 M.D.C. as mdc_base; the other locations are prose. The body is also the vehicles row at-c12000-flame-cloud-cyborg (since ~085), and equipment_starting lists the gear pointer of the same slug (since ~113), which is how the sheet reaches it.'),
       updated_at = datetime('now')
 WHERE class_id = 'dragon-borg-flame-cloud'
   AND instr(markdown, 'BODY: main body 320 M.D.C. as mdc_base; the other locations are prose.') > 0
   AND instr(markdown, 'e ~085), and equipment_starting lists the gear pointer of the same slug (since ~113), which is how the sheet reaches it.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'equipment_starting:
',
         'equipment_starting:
  - { item_id: "db-800-demon-eater-cyborg", qty: 1, note: "The cyborg body itself. This row points at the vessel of the same slug, which holds the body''s M.D.C. by location and its built-in weapons." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'geofront-demon-eater-geo-borg'
   AND instr(markdown, 'equipment_starting:
') > 0
   AND instr(markdown, ' This row points at the vessel of the same slug, which holds the body''s M.D.C. by location and its built-in weapons." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'BODY: main body 220 M.D.C. is mdc_base; the 340 M.D.C. hook-on heavy armor is armor, not body, and is prose with the M.D.C. by location.',
         'BODY: main body 220 M.D.C. is mdc_base; the 340 M.D.C. hook-on heavy armor is armor, not body, and is prose with the M.D.C. by location. The body is also the vehicles row db-800-demon-eater-cyborg (since ~085), and equipment_starting lists the gear pointer of the same slug (since ~113), which is how the sheet reaches it.'),
       updated_at = datetime('now')
 WHERE class_id = 'geofront-demon-eater-geo-borg'
   AND instr(markdown, 'BODY: main body 220 M.D.C. is mdc_base; the 340 M.D.C. hook-on heavy armor is armor, not body, and is prose with the M.D') > 0
   AND instr(markdown, 'e ~085), and equipment_starting lists the gear pointer of the same slug (since ~113), which is how the sheet reaches it.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'equipment_starting:
',
         'equipment_starting:
  - { item_id: "ab-830-assault-geo-borg", qty: 1, note: "The cyborg body itself. This row points at the vessel of the same slug, which holds the body''s M.D.C. by location and its built-in weapons." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'geofront-assault-geo-borg'
   AND instr(markdown, 'equipment_starting:
') > 0
   AND instr(markdown, ' This row points at the vessel of the same slug, which holds the body''s M.D.C. by location and its built-in weapons." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'BODY: main body 180 M.D.C. is mdc_base; the 140 M.D.C. hook-on light espionage armor and the optional 240 M.D.C. heavy armor are prose.',
         'BODY: main body 180 M.D.C. is mdc_base; the 140 M.D.C. hook-on light espionage armor and the optional 240 M.D.C. heavy armor are prose. The body is also the vehicles row ab-830-assault-geo-borg (since ~085), and equipment_starting lists the gear pointer of the same slug (since ~113), which is how the sheet reaches it.'),
       updated_at = datetime('now')
 WHERE class_id = 'geofront-assault-geo-borg'
   AND instr(markdown, 'BODY: main body 180 M.D.C. is mdc_base; the 140 M.D.C. hook-on light espionage armor and the optional 240 M.D.C. heavy a') > 0
   AND instr(markdown, 'e ~085), and equipment_starting lists the gear pointer of the same slug (since ~113), which is how the sheet reaches it.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'equipment_starting: []
',
         'equipment_starting:
  - { item_id: "ab-955-lion-geo-borg", qty: 1, note: "The cyborg body itself. This row points at the vessel of the same slug, which holds the body''s M.D.C. by location and its built-in weapons." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'geofront-lion-geo-borg'
   AND instr(markdown, 'equipment_starting: []
') > 0
   AND instr(markdown, ' This row points at the vessel of the same slug, which holds the body''s M.D.C. by location and its built-in weapons." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'BODY: main body 280 M.D.C. is mdc_base.',
         'BODY: main body 280 M.D.C. is mdc_base. The body is also the vehicles row ab-955-lion-geo-borg (since ~085), and equipment_starting lists the gear pointer of the same slug (since ~113), which is how the sheet reaches it.'),
       updated_at = datetime('now')
 WHERE class_id = 'geofront-lion-geo-borg'
   AND instr(markdown, 'BODY: main body 280 M.D.C. is mdc_base.') > 0
   AND instr(markdown, 'e ~085), and equipment_starting lists the gear pointer of the same slug (since ~113), which is how the sheet reaches it.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'is not starting kit, so equipment_starting is empty.',
         'is not starting kit, so equipment_starting holds the body''s own pointer and nothing else.'),
       updated_at = datetime('now')
 WHERE class_id = 'geofront-lion-geo-borg'
   AND instr(markdown, 'is not starting kit, so equipment_starting is empty.') > 0
   AND instr(markdown, 'is not starting kit, so equipment_starting holds the body''s own pointer and nothing else.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'magic:
  type: "Time Master (temporal ritual)"
  spells_starting: 2
  spell_levels_allowed: [1, 2, 3]
  spells_per_level: 1
  spells_per_level_levels: up_to_character_level
',
         'magic:
  type: "Time Master (temporal ritual)"
  spells_starting: 4
  spell_levels_allowed: [1, 2, 3]
  spells_starting_groups:
    - { count: 2, from_list: "temporal", note: "Two temporal magic spells of choice." }
    - { count: 2, spell_levels: [1, 2, 3], note: "Two regular magic spells from levels 1-3." }
  spell_lists:
    temporal:
      - "Temporal: D-Phase"
      - "Temporal: D-Shift Phantom"
      - "Temporal: D-Shift Two Dimensions"
      - "Temporal: Suspended Animation/Stasis Field"
      - "Temporal: T-Dep (Time Deprivation)"
      - "Temporal: Time Warp: Send"
      - "Temporal: Attune Object to Owner"
      - "Temporal: Retro-Viewing"
      - "Temporal: See Dimensional Anomaly"
      - "Temporal: Sense Dimensional Anomaly"
      - "Temporal: Time Capsule"
      - "Temporal: Wink-Out"
      - "Temporal: Remote Viewing"
      - "Temporal: S-Dep (Sensory Deprivation)"
      - "Temporal: Time Warp: Age"
      - "Temporal: Time Warp: Slow Motion"
      - "Temporal: Dimensional Pockets"
      - "Temporal: Temporary Time Hole"
      - "Temporal: Time Maelstrom"
      - "Temporal: Time Warp: Fast Forward"
      - "Temporal: Time Barrier"
      - "Temporal: Dimensional Envelope"
      - "Temporal: Id Self"
      - "Temporal: Fourth Dimension Transformation"
      - "Temporal: Time Warp: Space & Time"
  spells_schedule:
    - { level: 2, count: 1, from_list: "temporal", note: "One temporal magic spell." }
    - { level: 2, count: 1, spell_levels: "up_to_character_level", note: "One normal magic spell of the character''s level or lower." }
    - { level: 3, count: 1, from_list: "temporal", note: "One temporal magic spell." }
    - { level: 3, count: 1, spell_levels: "up_to_character_level", note: "One normal magic spell of the character''s level or lower." }
    - { level: 4, count: 1, from_list: "temporal", note: "One temporal magic spell." }
    - { level: 4, count: 1, spell_levels: "up_to_character_level", note: "One normal magic spell of the character''s level or lower." }
    - { level: 5, count: 1, from_list: "temporal", note: "One temporal magic spell." }
    - { level: 5, count: 1, spell_levels: "up_to_character_level", note: "One normal magic spell of the character''s level or lower." }
    - { level: 6, count: 1, from_list: "temporal", note: "One temporal magic spell." }
    - { level: 6, count: 1, spell_levels: "up_to_character_level", note: "One normal magic spell of the character''s level or lower." }
    - { level: 7, count: 1, from_list: "temporal", note: "One temporal magic spell." }
    - { level: 7, count: 1, spell_levels: "up_to_character_level", note: "One normal magic spell of the character''s level or lower." }
    - { level: 8, count: 1, from_list: "temporal", note: "One temporal magic spell." }
    - { level: 8, count: 1, spell_levels: "up_to_character_level", note: "One normal magic spell of the character''s level or lower." }
    - { level: 9, count: 1, from_list: "temporal", note: "One temporal magic spell." }
    - { level: 9, count: 1, spell_levels: "up_to_character_level", note: "One normal magic spell of the character''s level or lower." }
    - { level: 10, count: 1, from_list: "temporal", note: "One temporal magic spell." }
    - { level: 10, count: 1, spell_levels: "up_to_character_level", note: "One normal magic spell of the character''s level or lower." }
    - { level: 11, count: 1, from_list: "temporal", note: "One temporal magic spell." }
    - { level: 11, count: 1, spell_levels: "up_to_character_level", note: "One normal magic spell of the character''s level or lower." }
    - { level: 12, count: 1, from_list: "temporal", note: "One temporal magic spell." }
    - { level: 12, count: 1, spell_levels: "up_to_character_level", note: "One normal magic spell of the character''s level or lower." }
    - { level: 13, count: 1, from_list: "temporal", note: "One temporal magic spell." }
    - { level: 13, count: 1, spell_levels: "up_to_character_level", note: "One normal magic spell of the character''s level or lower." }
    - { level: 14, count: 1, from_list: "temporal", note: "One temporal magic spell." }
    - { level: 14, count: 1, spell_levels: "up_to_character_level", note: "One normal magic spell of the character''s level or lower." }
    - { level: 15, count: 1, from_list: "temporal", note: "One temporal magic spell." }
    - { level: 15, count: 1, spell_levels: "up_to_character_level", note: "One normal magic spell of the character''s level or lower." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'promethean-time-master'
   AND instr(markdown, 'magic:
  type: "Time Master (temporal ritual)"
  spells_starting: 2
  spell_levels_allowed: [1, 2, 3]
  spells_per_level') > 0
   AND instr(markdown, '5, count: 1, spell_levels: "up_to_character_level", note: "One normal magic spell of the character''s level or lower." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Only the normal spell is granted through the spell list; see the note below on temporal magic."',
         'Both are picked at each level: the temporal spell from the temporal magic list, the normal one from the general spells."'),
       updated_at = datetime('now')
 WHERE class_id = 'promethean-time-master'
   AND instr(markdown, 'Only the normal spell is granted through the spell list; see the note below on temporal magic."') > 0
   AND instr(markdown, 'Both are picked at each level: the temporal spell from the temporal magic list, the normal one from the general spells."') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'are chosen from the temporal magic list in Rifts England, which this catalog does not hold - so they are recorded here and chosen at the table rather than granted from a list the app would have to invent."',
         'are chosen from the temporal magic list. The book points at Rifts England for it; the catalog holds the 25 temporal spells as the Rifts Book of Magic reprints them (printed 244-251), and the picks are offered from those."'),
       updated_at = datetime('now')
 WHERE class_id = 'promethean-time-master'
   AND instr(markdown, 'are chosen from the temporal magic list in Rifts England, which this catalog does not hold - so they are recorded here a') > 0
   AND instr(markdown, 'he 25 temporal spells as the Rifts Book of Magic reprints them (printed 244-251), and the picks are offered from those."') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - HALF OF THIS CLASS''S MAGIC IS NOT IMPORTED, AND UNDER-GRANTING IS THE
    DELIBERATE CHOICE. First level is two temporal magic spells of choice PLUS
    two regular spells from levels 1-3; each level after is one temporal spell
    plus one normal spell of the character''s level or lower. Only the normal
    half is granted: spells_starting 2 gated to levels 1-3, and one per level
    with spells_per_level_levels up_to_character_level, which expresses "of the
    same or lower level as the character" exactly. The temporal half has nowhere
    to go - the catalog holds 607 spells and NOT ONE of them is temporal magic;
    a search for Rifts England as a source book returns zero rows, and the five
    time-flavoured spells it does hold (Time Slip, Time Hole, Time Capsule and
    two Ley Line Time spells) are ordinary invocations from the Book of Magic
    and Palladium Fantasy, not the temporal list. A spell group with a note and
    no gate would have offered the whole catalog for a pick the book restricts
    to a list this machine does not have, which is the near-miss F7 warns
    against; granting nothing and saying so is the smaller error. Recorded on
    the Temporal Magic ability so the player sees it at the table.
',
         '  - BOTH HALVES OF THIS CLASS''S MAGIC ARE GRANTED SINCE ~113. First level is
    two temporal magic spells of choice PLUS two regular spells from levels
    1-3; each level after is one temporal spell plus one normal spell of the
    character''s level or lower. Stored as two starting groups and two schedule
    entries per level from 2 to 15. The temporal picks draw on spell_lists
    temporal: the 25 Temporal Magic spells of the Rifts Book of Magic (printed
    244-251, added by ~091), the list the book points to Rifts England for,
    which is not on this machine. "Of the same or lower level as the
    character" is read as bounding the normal spell only: the temporal list
    starts at spell level 7, so a cap on it would leave the two first-level
    temporal spells with nothing to choose from. Until ~113 only the normal
    half was granted, because the catalog held no temporal spell.
'),
       updated_at = datetime('now')
 WHERE class_id = 'promethean-time-master'
   AND instr(markdown, '  - HALF OF THIS CLASS''S MAGIC IS NOT IMPORTED, AND UNDER-GRANTING IS THE
    DELIBERATE CHOICE. First level is two temp') > 0
   AND instr(markdown, 'th nothing to choose from. Until ~113 only the normal
    half was granted, because the catalog held no temporal spell.
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The temporal spells a time master knows come from the list in Rifts England,
which this catalog does not hold - no row in it cites that book. Two are known
at first level and one more is gained at every level after, alongside the normal
spell the app does grant. Choose them from the book at the table; nothing here
will offer them, and nothing here will stop you.
',
         'The temporal spells a time master knows come from the temporal magic list,
which the book points to Rifts England for and the Rifts Book of Magic reprints.
Two are known at first level and one more is gained at every level after,
alongside one normal spell of the character''s level or lower.
'),
       updated_at = datetime('now')
 WHERE class_id = 'promethean-time-master'
   AND instr(markdown, 'The temporal spells a time master knows come from the list in Rifts England,
which this catalog does not hold - no row i') > 0
   AND instr(markdown, ' first level and one more is gained at every level after,
alongside one normal spell of the character''s level or lower.
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'special_abilities:
  - { name: "Circle Magic"',
         'magic:
  type: "circle"
  spell_traditions_allowed: ["circle"]
  spells_starting: 0
  spells_per_level: 0
  spells:
    - "Circle: Protection Circle: Simple"
    - "Circle: Protection Circle: Superior"
    - "Circle: Protection from Angels"
    - "Circle: Protection from Deevils"
    - "Circle: Protection from Demons"
    - "Circle: Protection from Elemental Forces"
    - "Circle: Protection from Evil"
    - "Circle: Protection from Faerie Folk"
    - "Circle: Protection from Ghosts, Spirits & Entities"
    - "Circle: Protection from Good"
    - "Circle: Protection from Magic (simple)"
    - "Circle: Protection from Magic (superior)"
    - "Circle: Protection from True Elementals"
    - "Circle: Protection from Were-beasts"
    - "Circle: Protection from Witches"
    - "Circle: Protection from the Jinn"
    - "Circle: Protection from the Old Ones"
    - "Circle: Protection from the Undead"
    - "Circle: Summon Angels"
    - "Circle: Summon Animal"
    - "Circle: Summon Elemental Forces"
    - "Circle: Summon Faerie Folk"
    - "Circle: Summon Gargoyles & Sub-Demons"
    - "Circle: Summon Ghosts & Entities"
    - "Circle: Summon Greater Demon or Deevil"
    - "Circle: Summon Insects"
    - "Circle: Summon Lesser Demon or Deevil"
    - "Circle: Summon Pawn"
    - "Circle: Summon Serpents"
    - "Circle: Summon Spirits"
    - "Circle: Summon True Elementals"
    - "Circle: Summon the Jinn"
    - "Circle: Summon the Undead"
special_abilities:
  - { name: "Circle Magic"'),
       updated_at = datetime('now')
 WHERE class_id = 'summoner'
   AND instr(markdown, 'special_abilities:
  - { name: "Circle Magic"') > 0
   AND instr(markdown, 'mentals"
    - "Circle: Summon the Jinn"
    - "Circle: Summon the Undead"
special_abilities:
  - { name: "Circle Magic"') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Circles of Power for the summoner''s own work. Circles are not in the spell catalog and are not modelled as spells; the character sheet has no circle list." }',
         'Circles of Power for the summoner''s own work. The summoner knows every protection and summoning circle from the start, and they are on the sheet. He starts with no power circles: those are bought, won or deciphered from a found circle over time, at the G.M.''s say." }'),
       updated_at = datetime('now')
 WHERE class_id = 'summoner'
   AND instr(markdown, 'Circles of Power for the summoner''s own work. Circles are not in the spell catalog and are not modelled as spells; the c') > 0
   AND instr(markdown, 'e starts with no power circles: those are bought, won or deciphered from a found circle over time, at the G.M.''s say." }') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Circles are the whole of this class''s magic. The 51 circles are spell rows in tradition circle since ~091, but nothing grants that tradition yet, so the three families are still recorded as a special ability rather than faked into the spell list; the class carries no magic block at all.',
         'Circles are the whole of this class''s magic. The 51 circles are spell rows in tradition circle since ~091, and since ~113 the magic block grants the 18 protection and 15 summoning circles by name, because printed 135 says the Summoner knows all protection and summoning circles and starts with no power circles. The 18 power circles are not granted and no pick offers them: the book has them acquired in play. spells_per_level is 0 because the class learns nothing by level. The Deciphering Circles skill (20% +4% per level, printed 135) and the circle strength rule (printed 136) are not stored.'),
       updated_at = datetime('now')
 WHERE class_id = 'summoner'
   AND instr(markdown, 'Circles are the whole of this class''s magic. The 51 circles are spell rows in tradition circle since ~091, but nothing g') > 0
   AND instr(markdown, 'he Deciphering Circles skill (20% +4% per level, printed 135) and the circle strength rule (printed 136) are not stored.') = 0;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the seven pointer rows are in and point at their vessels' AS assertion, count(*) AS got, 7 AS want
  FROM gear g JOIN vehicles v ON v.slug = g.vehicle_slug
 WHERE g.slug IN ('at-c8000-wing-blade-cyborg', 'at-c9000-tsunami-cyborg', 'at-c10000-imperial-dragon-cyborg', 'at-c12000-flame-cloud-cyborg', 'db-800-demon-eater-cyborg', 'ab-830-assault-geo-borg', 'ab-955-lion-geo-borg') AND g.vehicle_slug = g.slug AND g.mdc = v.mdc_main_body;

SELECT 'each of the seven classes lists its own body' AS assertion, count(*) AS got, 7 AS want
  FROM imported_classes
 WHERE (class_id = 'dragon-borg-wing-blade' AND instr(markdown, 'item_id: "at-c8000-wing-blade-cyborg"') > 0)
    OR (class_id = 'dragon-borg-tsunami' AND instr(markdown, 'item_id: "at-c9000-tsunami-cyborg"') > 0)
    OR (class_id = 'dragon-borg-imperial-combat' AND instr(markdown, 'item_id: "at-c10000-imperial-dragon-cyborg"') > 0)
    OR (class_id = 'dragon-borg-flame-cloud' AND instr(markdown, 'item_id: "at-c12000-flame-cloud-cyborg"') > 0)
    OR (class_id = 'geofront-demon-eater-geo-borg' AND instr(markdown, 'item_id: "db-800-demon-eater-cyborg"') > 0)
    OR (class_id = 'geofront-assault-geo-borg' AND instr(markdown, 'item_id: "ab-830-assault-geo-borg"') > 0)
    OR (class_id = 'geofront-lion-geo-borg' AND instr(markdown, 'item_id: "ab-955-lion-geo-borg"') > 0);

SELECT 'no class still says it is not wired' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('dragon-borg-wing-blade', 'dragon-borg-tsunami', 'dragon-borg-imperial-combat', 'dragon-borg-flame-cloud', 'geofront-demon-eater-geo-borg', 'geofront-assault-geo-borg', 'geofront-lion-geo-borg', 'promethean-time-master', 'summoner')
   AND instr(markdown, 'not wired to it') + instr(markdown, 'not wired to its row') + instr(markdown, 'nothing grants that tradition yet') + instr(markdown, 'which this catalog does not hold') > 0;

SELECT 'every temporal spell the Time Master lists is a row' AS assertion, count(*) AS got, 25 AS want
  FROM spells WHERE tradition = 'temporal'
   AND instr((SELECT markdown FROM imported_classes WHERE class_id = 'promethean-time-master'), '      - "' || name || '"') > 0;

SELECT 'every circle the Summoner is granted is a row' AS assertion, count(*) AS got, 33 AS want
  FROM spells WHERE tradition = 'circle' AND system = 'palladium-fantasy'
   AND instr((SELECT markdown FROM imported_classes WHERE class_id = 'summoner'), '    - "' || name || '"') > 0;

SELECT 'no power circle is granted' AS assertion, count(*) AS got, 0 AS want
  FROM spells WHERE tradition = 'circle' AND name LIKE '% - Power Circle'
   AND instr((SELECT markdown FROM imported_classes WHERE class_id = 'summoner'), '    - "' || name || '"') > 0;

SELECT 'all nine classes are exactly the length this script leaves them' AS assertion, count(*) AS got, 9 AS want
  FROM imported_classes
 WHERE (class_id = 'dragon-borg-wing-blade' AND length(markdown) = 20968)
    OR (class_id = 'dragon-borg-tsunami' AND length(markdown) = 21534)
    OR (class_id = 'dragon-borg-imperial-combat' AND length(markdown) = 19508)
    OR (class_id = 'dragon-borg-flame-cloud' AND length(markdown) = 19401)
    OR (class_id = 'geofront-demon-eater-geo-borg' AND length(markdown) = 16231)
    OR (class_id = 'geofront-assault-geo-borg' AND length(markdown) = 15027)
    OR (class_id = 'geofront-lion-geo-borg' AND length(markdown) = 11067)
    OR (class_id = 'promethean-time-master' AND length(markdown) = 13842)
    OR (class_id = 'summoner' AND length(markdown) = 11014);

INSERT INTO data_script_runs (filename) VALUES ('~113-wire-nine-classes-to-their-rows.sql');
