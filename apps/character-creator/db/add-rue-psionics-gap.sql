-- Sixteen psionic powers Rifts Ultimate Edition defines that the catalog did
-- not carry.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-rue-psionics-gap.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-rue-psionics-gap.sql
--
-- HOW THESE WERE FOUND. The authority is the Psionic checklist on printed
-- p164, which states every power's name, category and I.S.P. cost in one
-- place. Each row was then read a second time from its own stat block on
-- printed pp.165-184, and the two readings agree on all sixteen.
--
-- The first diff of that checklist against the catalog claimed 21 missing and
-- 23 wrong categories. Both numbers were mostly noise and acting on either
-- would have done damage:
--
--   * The catalog's category vocabulary is Healing/Physical/Sensitive/SUPER.
--     RUE's heading reads "Super-Psionics". That one word accounted for 22 of
--     the 23 "wrong" categories. Rewriting them would have broken every picker
--     that filters on category.
--
--   * RUE prints Bio-Regenerate (self) AND Bio-Regeneration (Super), and
--     Telekinesis AND Telekinesis (Super). Matching on names with the
--     parenthetical stripped collapsed each pair onto one catalog row and
--     produced three I.S.P. "corrections" to rows that were already right.
--     A qualifier in parentheses is part of the identity.
--
--   * Three more were false gaps under a different spelling, all already
--     present: Bio-Regenerate (self) = Bio-Regeneration, Impervious to Poison
--     = Impervious to Poison/Toxin, Commune with Spirits = Commune with
--     Spirit.
--
-- Descriptions are the book's own text, cleaned of OCR damage, rather than a
-- re-extraction - it costs nothing and cannot invent anything.
--
-- I.S.P. follows the spells.ppe/ppe_note split already in use: the numeric
-- column holds the MINIMUM the sheet spends, and isp_note carries a variable
-- cost's schedule verbatim. Three powers here have one.
--
-- Pure ASCII on purpose - passing a non-ASCII character through
-- `wrangler d1 execute` on Windows has produced mojibake before.
--
-- INSERT OR IGNORE, so re-running is a no-op and a name that somehow already
-- exists is left exactly as it is.

-- printed p166
INSERT OR IGNORE INTO psionic_powers
  (name, category, isp, isp_note, "range", duration, saving_throw,
   description, min_tier, source, source_book, system)
VALUES ('Restore P.P.E.', 'Healing', 4, '4 plus the amount of P.P.E. transferred; 2 I.S.P. converts to 1 P.P.E.', 'Touch', 'Permanent', NULL,
        'This power allows the psychic to convert some of his I.S.P. into P.P.E. energy and transfer that energy to another person. Two I.S.P. counts as one P.P.E. point. In addition, the conversion and transfer costs four I.S.P. to initiate. For example, 10 I.S.P. converts into five P.P.E. and costs an additional four points to make the transferal and conversion. Total cost is 14 I.S.P. A Mind Block will prevent this energy transfer. Note: P.P.E. can not be turned into I.S.P.', NULL, 'import', 'Rifts Ultimate Edition', 'rifts');

-- printed p166
INSERT OR IGNORE INTO psionic_powers
  (name, category, isp, isp_note, "range", duration, saving_throw,
   description, min_tier, source, source_book, system)
VALUES ('Stop Bleeding', 'Healing', 2, '2 for self, 4 for others', 'Self or other by touch', 'Indefinite, as long as the healer concentrates; four minutes per level of experience if used as a temporary tourniquet', NULL,
        'the injury and concentrates on stopping the bleeding. Four minutes per experience level of the psi-healer if the character uses this temporary tourniquet and leaves his patient to do other things. Another type of bio-feedback, mind over matter power, in which the psychic stops bleeding from wounds and internal injury using the power of his mind. This means stopping additional damage from blood loss and being able to function relatively unimpaired. As impressive and potentially lifesaving as this ability may be, it is only a stopgap measure. The injury is NOT being healed and the character still needs medical attention or he will, eventually, die from his injuries. If rendered unconscious, the bleeding and blood loss damage immediately begins. Note: Stops the bleeding from all sources, however, additional/ new Hit Point damage suffered after the Stop Bleeding requires additional concentration and another two I.S.P. to stop the bleeding from the new wound(s). on stopping the bleeding, which means his number of attacks per melee round and all combat bonuses are reduced by half, but skill performance and other abilities function at normal capacity (he can run, leap, climb, swim, drive, operate machinery, etc. at full tilt, for example).', NULL, 'import', 'Rifts Ultimate Edition', 'rifts');

-- printed p168
INSERT OR IGNORE INTO psionic_powers
  (name, category, isp, isp_note, "range", duration, saving_throw,
   description, min_tier, source, source_book, system)
VALUES ('Ectoplasmic Disguise', 'Physical', 12, NULL, 'Self', '10 minutes per level of experience', NULL,
        'This is an enhanced control over ectoplasm that gives the psychic the ability to cover and disguise his physical features. Ectoplasm is created as normal, with the mysterious pseudo-substance rising from the pores of the skin. Instead of forming wispy tentacles, the ectoplasm covers the face. As it solidifies, it becomes a sort of putty-like material that can be mentally shaped and molded by the psychic. Once the desired shapes and features are achieved, the psychic can make the ectoplasm look like real flesh. The best way to create an Ectoplasmic Disguise is for the psychic to look at a photograph or a frozen video image and concentrate on that image while the ectoplasm automatically molds into that shape/image, including skin color. Not only can the psychic create a mask to hide his facial features, but he can also change the shape and bulk of his body with ectoplasm, adding a pot belly, muscles, a tail or extra eye, etc. if the character has the Disguise skill). This percentage applies primarily when trying to accurately imitate a specific person s identity. In most other cases, the disguise is successful in that it obscures the psychic s true identity. Problems & Limitations: An Ectoplasmic Disguise is especially effective from a distance, but does not hold up under close scrutiny. The ectoplasm always has a bit of a dull and pasty appearance, regardless of skin color. If punched, cut, scraped, etc., the ectoplasmic covering will tear away and, in a matter of seconds, noticeably reform to cover the tear/damage. The psychic must also concentrate on maintaining his disguise, which means his attention is divided and concentration hampered. While the disguise is maintained, the psychic suffers the following penalties: -4 on initiative and reduce all combat bonuses, attacks per melee, running speed and skill performance by half. To perform better, the character must relinquish some his control over the disguise, with notable results, like features obviously shifting, drooping or even melting. If the character is seriously injured, knocked unconscious or slain, the ectoplasm melts away, turns into floating globs and disappears into him in a matter of seconds.', NULL, 'import', 'Rifts Ultimate Edition', 'rifts');

-- printed p170
INSERT OR IGNORE INTO psionic_powers
  (name, category, isp, isp_note, "range", duration, saving_throw,
   description, min_tier, source, source_book, system)
VALUES ('Telekinetic Lift', 'Physical', 6, NULL, 'Self or touch', '2 melees per level of experience', NULL,
        'Rather than moving objects solely with the power of the mind, this use of telekinesis increases the character s ability to lift and carry heavy weights. The psychic creates a telekinetic field around the object and lifts both physically and mentally (via telekinesis). This enables the psychic to lift and carry weights 20% heavier than his P.S. normally allows. This use of telekinetics is limited exclusively to lifting and carrying heavy weights and cannot be used to hurl boulders and heavy objects as weapons, nor can it be used to augment the damage inflicted by a punch, kick or other physical attacks.', NULL, 'import', 'Rifts Ultimate Edition', 'rifts');

-- printed p170
INSERT OR IGNORE INTO psionic_powers
  (name, category, isp, isp_note, "range", duration, saving_throw,
   description, min_tier, source, source_book, system)
VALUES ('Telekinetic Push', 'Physical', 4, NULL, 'By touch or one foot (0.3 m) per level of experience', 'Instant', 'None',
        'The psychic can effectively create a telekinetic force that pushes away an attacker or anything within range (a door, chair, cart, statue, etc.). The pushing force has the rough equivalent of a P.S. 16 +1 per level of the psychic. The Telekinetic Push is roughly equal to a body block and does 1D4 S.D.C. or Hit Point damage, will knock most ordinary humans back two yards/meters and has a 01-60% chance of knocking the person off his feet (if so, that character loses initiative and one melee action). Characters weighing more than 200 pounds (90 kg) or who possess Robotic P.S. or Supernatural P.S. are only shoved a foot or two and there is only a 01-12% chance of being knocked off their feet. Inanimate objects weighing under 50 pounds (22.5 kg) are pushed or slid across the ground twice as far, roughly four yards/meters (12 feet/3.6 m). Sensitive Psionics', NULL, 'import', 'Rifts Ultimate Edition', 'rifts');

-- printed p173
INSERT OR IGNORE INTO psionic_powers
  (name, category, isp, isp_note, "range", duration, saving_throw,
   description, min_tier, source, source_book, system)
VALUES ('Intuitive Combat', 'Sensitive', 10, NULL, 'Self', 'Two melee rounds per level of experience', NULL,
        'This is a form of telepathy geared to give the psychic an advantage in melee combat. To put this ability in place, the psychic must concentrate for one melee round (15 seconds), putting himself in a Zen-like state of awareness. For the next two melee rounds, the Intuitive Combat sense makes the character one with his body and weapon, reacting quickly and efficiently with amazing reflex action, balance and grace. Mind Block, while this power is in use. He can cancel it with a thought. Bonuses: +3 on initiative, +1 to strike, +1 to parry, +4 to dodge, +4 to pull punch, +2 to roll with punch, fall or impact, and +2 to disarm. Cannot be caught by surprise, even by attacks from behind or from long-range, which means he can ry to parry or dodge all attacks leveled at him. +10% to abilities (balance, etc.) provided by the Acrobatics and/or Gymnastic skills, as well as +10% to Climb and Swim skills.', NULL, 'import', 'Rifts Ultimate Edition', 'rifts');

-- printed p174
INSERT OR IGNORE INTO psionic_powers
  (name, category, isp, isp_note, "range", duration, saving_throw,
   description, min_tier, source, source_book, system)
VALUES ('Mask I.S.P. & Psionics', 'Sensitive', 7, NULL, 'Self', '10 minutes per level of experience', NULL,
        'This is a psionic power that enables the character to completely mask all spiritual aspects of his psionic energy and powers. Even the aura is temporarily altered. As a result, other psychics, Dog Boys, PsiStalkers, and creatures who can Detect Psionics or See Aura will not sense psionics in a character who is masked. However, the masked psychic must block himself from the world, which means he cannot use any of his psionic senses or abilities, nor receive Empathic or Telepathic impressions until he lets the mask go.', NULL, 'import', 'Rifts Ultimate Edition', 'rifts');

-- printed p174
INSERT OR IGNORE INTO psionic_powers
  (name, category, isp, isp_note, "range", duration, saving_throw,
   description, min_tier, source, source_book, system)
VALUES ('Mask P.P.E.', 'Sensitive', 4, NULL, 'Self', 'Ten minutes per level of experience', NULL,
        'A psionic power that enables the character to completely mask all but 1D4 P.P.E. of his personal P.P.E. base. Characters who can sense magic energy or see aura will regard this character as having an insignificant amount of P.P.E. This power is especially good as protection against Psi-Stalkers and other P.P.E. vampires. Mystics can easily hide their magical powers through this psionic concealment.', NULL, 'import', 'Rifts Ultimate Edition', 'rifts');

-- printed p175
INSERT OR IGNORE INTO psionic_powers
  (name, category, isp, isp_note, "range", duration, saving_throw,
   description, min_tier, source, source_book, system)
VALUES ('Read Dimensional Portal', 'Sensitive', 6, NULL, 'Touch or one foot (0.3 m) per level of experience', 'One melee round per level of experience', 'Not applicable',
        'devices that can create a dimensional portal. This power allows the psychic to get impressions from the portal or dimension spanning device, which instills the character with the following information: Destination is relatively dangerous/hostile or safe to the psychic. This includes whether or not the environment can support human life. Whether there is a strong (or numerous) presence of the supernatural (i.e. Alien Intelligence, gods, demons, etc.) and whether that presence is evil. A psychic flash a brief vision of who was the last person or persons to use the portal, if any (may be none if it is a random Rift that hasn''t been used by any living force). Intuitively sense whether the portal or machine leads to any of the following dimensions: The Astral Plane, Xiticix home world, the Dreamstream, or to another location on Rifts Earth. If a mechanical gateway or device capable of dimensional travel/ opening a dimensional portal, whether it is a creation of magic or science, the psychic will get a basic idea of how to operate it in order to open or close a dimensional portal (similar to Object Read).', NULL, 'import', 'Rifts Ultimate Edition', 'rifts');

-- printed p175
INSERT OR IGNORE INTO psionic_powers
  (name, category, isp, isp_note, "range", duration, saving_throw,
   description, min_tier, source, source_book, system)
VALUES ('Remote Viewing', 'Sensitive', 10, NULL, 'Self', '2D6+6 second flash of insight or vision of current events', 'Special - a psychic who senses the intrusion may spend 1 I.S.P. and save vs psionic attack to block it',
        'body is trying to observe them and can try to resist it by concentrating (uses up one I.S.P.); standard save vs psionic attack (in this case, psionic intrusion). Failure means the psychic is seen via Remote Viewing. Success means the psychic trying to view is blocked, and he knows that the target has deliberately done so. Otherwise, the target of this power gets no impression from being viewed remotely and has no idea why he is being watched or by whom. To use this power, the psychic needs a photo or video image to focus on, even if he knows the person or place intimately. When focused on a particular person, the psychic can see in his mind what the person is doing at that moment for 2D6+6 seconds. The image appears as if the character were looking down through a skylight. He sees only a glimpse of things and may not remember all details. Likewise, he may not see other people outside his line of vision, because the focus is a particular person, not the entire room. If the target is moving, walking, or driving, the remote viewer will know this and follow along for a few seconds, although he may not have a clear idea of his surroundings, but enough of an impression to recognize it if he sees it personally. The character may also Remote View a specific place such as a small to medium room, a corner in a playground or field, a specific entrance to a building, a particular section of an alley, etc., but not an entire house, office building, stadium, street, etc. As before, he must have a photograph, video or frame of film to focus upon. For 2D6+6 seconds, the psychic will see whatever occurs in that small area of that particular place. In the alternative, the psychic can use Remote Viewing to catch glimpses/images that tell something about the subject of the viewing. In this instance, he must have 2-4 specific questions, such as, is so and so alive ... Then the image of the character smiling as he walks through the area appears, or flashes of a brutal attack, blood, and a falling body (indicating death), and so on, appear for an instant in answer to his query. In either case, the psychic cannot look at the same person or place via Remote Viewing again for another 24 hours.', NULL, 'import', 'Rifts Ultimate Edition', 'rifts');

-- printed p179
INSERT OR IGNORE INTO psionic_powers
  (name, category, isp, isp_note, "range", duration, saving_throw,
   description, min_tier, source, source_book, system)
VALUES ('Group Trance', 'Super', 15, NULL, 'All willing subjects within 20 feet (6 m) of the psychic, +10 feet (3 m) per level of experience', 'Two minutes per level of experience or until the trance is broken, whichever comes first', 'None for willing participants; those unwilling cannot be entranced',
        'feet (3 m) per level of experience. broken, whichever comes first. ticipate cannot be entranced. There are a couple of different applications for this power. The non-combat use is a sort of shared communication. Everybody entranced can share in the psionic experiences of the group leader, the character who is using the Group Trance power. First, the entire group of willing participants enters into a trance state. While entranced, the group is subtly linked to the character using the power. That psychic can then perform one or two other psychic communication abilities per melee round. These abilities are limited to a few forms of psionic communication (not Healing, Physical or Super-Psionic powers), including Clairvoyance, Empathy, Telepathy, Object Read, Presence Sense, Commune with Spirits. Remote Viewing, and Sixth Sense. The thoughts, visions/images, communications received by the lead psychic are simultaneously transmitted via the trance-link to all participants. They see, know or feel everything he does. The other use of this ability is to willingly pool the I.S.P. of the trance group to make it available to the lead psychic (the one who is using the Group Trance ability). Once every melee round, the psychic to whom they are linked can draw upon three I.S.P. points from each psychic in the trance group. I.S.P. cannot be drawn from characters who don''t have any. These I.S.P. can be used by the lead psychic any way he desires. The others linked to him see, feel and experience whatever he does, including his rationale, motives and emotions. In both instances, only the psychic group leader has any melee actions, and he is limited to two psionic actions/attacks while entranced. All those in the group are simply passive observers and secondary participants. All participants react calmly toward the events, emotions, and visions they experience while entranced. The moment the trance ends, they are back to normal and can respond as is appropriate. Only the lead psychic or the genuine fear of death can break the trance. All snap out of it even if only one person breaks the trance.', NULL, 'import', 'Rifts Ultimate Edition', 'rifts');

-- printed p181
INSERT OR IGNORE INTO psionic_powers
  (name, category, isp, isp_note, "range", duration, saving_throw,
   description, min_tier, source, source_book, system)
VALUES ('Psionic Invisibility', 'Super', 10, NULL, 'Line of sight or 100 foot (30.5 m) radius', 'One minute per level of experience', 'Potential victims are -2 to save; area effect',
        'I.S.P.: 10 Psionic Invisibility is the ability to remain undetected when in plain sight. This is accomplished via a telepathic impulse that convinces bystanders that the psychic is not a threat and insignificant beneath their notice. Those affected by the impulse are unable to see the character, and subconsciously avoid colliding with him; they don''t see him on a conscious level. Note: This invisibility works only if the character is passing through or hiding, and honestly has no intention of attacking or hurting anybody in the area. The slightest ill intent or act toward perpetrating violence instantly cancels the psionic influence. Individuals watching through video monitors and other sensory equipment can be similarly tricked into ignoring the psychic, but only if within his radius of influence. Those out of range will react appropriately, and once the psychic has been seen, that person is immune to his ability to seem invisible. Likewise, while a watch guard may not see or react to the psychic, he will be captured and recorded on film and by sensors. Video cameras, computers and similar devices are never fooled by this power; they are able to notice and record the character as normal (some may sound an alarm too).', NULL, 'import', 'Rifts Ultimate Edition', 'rifts');

-- printed p181
INSERT OR IGNORE INTO psionic_powers
  (name, category, isp, isp_note, "range", duration, saving_throw,
   description, min_tier, source, source_book, system)
VALUES ('Psychic Omni-Sight', 'Super', 15, NULL, '500 foot (152 m) radius', '5 minutes per level of experience', NULL,
        'An advanced form of extrasensory perception that allows the psychic to have a sort of controlled out of body experience. The psychic must spend one minute (four melee rounds) in meditation and enter into a trance state. While entranced, his spirit or essence seems to rise 10-20 feet (3-6 m) above his physical body (this is not visible to anybody but other psychic sensitives and those who can see the invisible, auras or spirits). From this vantage point, combined with heightened awareness, the psychic sees through his mind s eye, without having to use his normal vision or senses. Psychic Omni-Sight is incredible, enabling the psychic to see in all directions at once, to see radiation, thermal patterns, the invisible, and to literally see any movement, even of the wind! This power enables the psychic to guard or survey a campsite for signs of wayward group members or approaching dangers (maximum range 500 feet/152 m; this psionic vision is stopped/contained by walls and other obstacles). It can also be used to survey an area for things that might otherwise escape normal sight or take much longer to locate and identify. Special Bonuses & Abilities: Pinpoints the locations of electrical outlets, electronic bugs (spy and surveillance devices), electronic devices and other energy and heat sources, as well as bionic body parts and cybernetic implants close to the surface of the skin (not Bio-Systems or artificial internal organs). Such concealed or obscured items can be identified by their shape and heat pattern. Success Ratio: 40% +5% per level of experience. This ability can also help the psychic to locate secret compartments and trap doors. Success Ratio: 25% +5% per level of experience. See the infrared and ultraviolet spectrums of light. See heat signatures: can tell if an engine has been recently used or a weapon recently fired (within the last 15 minutes), follow recent footprints or vapor trails (within the last five minutes), see heat signature in darkness and so on. Hyper-sensitive to movement. The psychic can not be surprised by movement or attacks within the 500 foot (152 m) radius or confines of the area under psionic scrutiny (may be substantially smaller indoors; closed off by walls and doors). Omni-Sight, the psychic cannot take physical action, not even to speak, nor use most psionic powers unless he cancels/ends the ability. He can awaken the instant the psi-ability ends and leap into action. While entranced by Omni-Sight, the character can only use the following psionic powers: Empathy, Telepathy, See Aura, Empathic Transmission and Telekinesis. The number of psionic attacks/actions per melee round are half those normally available when not entranced.', NULL, 'import', 'Rifts Ultimate Edition', 'rifts');

-- printed p182
INSERT OR IGNORE INTO psionic_powers
  (name, category, isp, isp_note, "range", duration, saving_throw,
   description, min_tier, source, source_book, system)
VALUES ('Psychosomatic Disease', 'Super', 30, NULL, '10 feet (3 m) and verbal suggestion', '1D4 days per level of the psychic', 'Standard',
        'This power employs the principle of mind-over-matter and mind control by inducing the victim to believe he suffers from a particular disease. although no actual physical cause can be found. It is all in the victim''s mind. This is done in a similar way as Hypnotic Suggestion, requiring the psychic to suggest that the character looks ill or that a particular disease is in the area, as well as mention the name of a specific disease along with the most notable (and debilitating or frightening) symptoms. Within 2D6 minutes, the intended victim will begin to come down with those symptoms. He will suffer from the affliction with all its pain and penalties, until one of the following occurs: The psychic who caused the affliction removes it, the character is healed by a psychic healer, a successful magical or priestly Remove Curse spell or ritual is performed, or the Psychosomatic Disease runs its course (see duration above). In the meantime, the character will suffer from physical trauma and symptoms (fever, vomiting, coughing, convulsions, skin rashes, hives, etc.) associated with that disease, as well as emotional anguish. In most cases, the disease is debilitating for days, but sometimes it can be deadly, causing the victim to die from dehydration, starvation, injury, etc., brought on by the symptoms and/or fear of the psionic illness.', NULL, 'import', 'Rifts Ultimate Edition', 'rifts');

-- printed p183
INSERT OR IGNORE INTO psionic_powers
  (name, category, isp, isp_note, "range", duration, saving_throw,
   description, min_tier, source, source_book, system)
VALUES ('Telekinetic Acceleration Attack', 'Super', 10, '10 for S.D.C. damage, 20 for Mega-Damage', '50 feet (15 m) +10 feet (3 m) per level of experience; line of sight', 'Instant', NULL,
        'This power works on the same principle as the rail gun but uses telekinetic power rather than electromagnetic force. Rather than use Telekinesis to lift and move one or more objects, this Super-Psionic power causes a half dozen to a dozen small objects (coins, pencils, small stones, arrows, unloaded bullets, etc.) to hurl at an incredibly high velocity in a powerful (if short-range) burst of telekinetic energy. All items strike one target at tornado wind velocity. Damage: If 10 I.S.P. are expended the damage inflicted is 2D4x10 S.D.C. If 20 I.S.P. are expended. the damage is 3D6+4 Mega-Damage! The psychic must roll to strike at +1 to do so (no other bonuses apply except any O.C.C./R.C.C. psi-power bonus) and the target must be clearly visible. The psionic attack counts as one of the character s melee attacks.', NULL, 'import', 'Rifts Ultimate Edition', 'rifts');

-- printed p184
INSERT OR IGNORE INTO psionic_powers
  (name, category, isp, isp_note, "range", duration, saving_throw,
   description, min_tier, source, source_book, system)
VALUES ('Telemechanic Possession', 'Super', 50, NULL, 'Touch or 10 feet (3 m) per level of experience', 'Two minutes (8 melees) per level of experience', 'Special - non-intelligent machines cannot save; artificial intelligences need 15 or higher, sentient machines 12 or better',
        'ers of Object Read and Telemechanics. vs Telemechanic Possession. Artificial intelligences (robots like Skelebots) need a 15 or higher to save and sentient machines (like Archie-3) require a 12 or better to save. Artificial intelligences and sentient machines also get to save when being forced to do something that is contrary to their programming. Cybernetic and bionic devices attached to living tissue can NOT be possessed. Neither can magic items, including Rune Weapons and Techno-Wizard devices. This ability is identical to the psionic power, Mentally Possess Others, in every way, except that the psychic possesses a machine rather than another person. The character overrides the programming/controls of the machine, even in the case of sentient machines, and controls it like a living robot. Essentially, the possessing psychic is an immaterial pilot who controls the machine as he desires; computers, factory equipment, vehicles, robots, empty power armor, a toaster, etc. While the psychic possesses the machine, it responds to the character s thoughts and does whatever he desires. Of course, physical, mechanical limitations still apply. The machine needs a power source and cannot do anything it is not normally capable of doing. For example, the psychic may be able to take possession of an energy rifle and make it shoot (or not) seemingly of its own volition, but he cannot make the rifle aim, move or hop around. Likewise, if the device is unplugged, or runs out of fuel, the machine is deactivated with no ill effect to the psychic, except his possession comes to a premature end. Likewise, if it needs wheels to move, destroying the wheels will cripple it, etc. If the machine he possesses is destroyed while the psychic s essence is still inside it, the character loses one third of his Hit Points (or one third of his M.D.C. if a Mega-Damage creature) from the shock and pain from the destruction of his surrogate machine body. Furthermore, he is stunned for 1D4 minutes (reduce attacks per melee, speed, combat bonuses, and skill performance by half while stunned). During the period that the machine is possessed, the psychic s natural body falls into a coma-like state and is vulnerable to attack unless protected by others. While in mental possession of a simple machine, the psychic has only a vague awareness of his surroundings and can see, hear and feel things around him but as if in a cloud or haze. However, if the machine has optics and/or sensors, he is able to use them like his own natural eyes and senses. The machine, regardless of its capabilities and programming, has attacks and actions equal to those of the character possessing it.', NULL, 'import', 'Rifts Ultimate Edition', 'rifts');

-- RUE overrides the two costs below. Both were read twice and both readings
-- agree with each other and disagree with the catalog:
--   Commune with Spirits      checklist p164: 6   stat block p172: 6   catalog: 8
--   Sense Dimensional Anomaly checklist p164: 4   stat block p176: 4   catalog: 6
-- Guarded on the old value, so a row already corrected is left alone.
UPDATE psionic_powers SET isp = 6 WHERE name = 'Commune with Spirit' AND isp = 8;
UPDATE psionic_powers SET isp = 4 WHERE name = 'Sense Dimensional Anomaly' AND isp = 6;

-- Read the result back rather than trusting the exit code.
SELECT count(*) AS total_powers FROM psionic_powers;
SELECT count(*) AS rue_gap_rows FROM psionic_powers WHERE name IN (
  'Restore P.P.E.',
  'Stop Bleeding',
  'Ectoplasmic Disguise',
  'Telekinetic Lift',
  'Telekinetic Push',
  'Intuitive Combat',
  'Mask I.S.P. & Psionics',
  'Mask P.P.E.',
  'Read Dimensional Portal',
  'Remote Viewing',
  'Group Trance',
  'Psionic Invisibility',
  'Psychic Omni-Sight',
  'Psychosomatic Disease',
  'Telekinetic Acceleration Attack',
  'Telemechanic Possession');
SELECT name, isp FROM psionic_powers
 WHERE name IN ('Commune with Spirit', 'Sense Dimensional Anomaly');
SELECT count(*) AS with_isp_note FROM psionic_powers WHERE isp_note IS NOT NULL;

INSERT INTO data_script_runs (filename) VALUES ('add-rue-psionics-gap.sql');
