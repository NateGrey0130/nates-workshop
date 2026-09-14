-- Heroes Unlimited's communications, surveillance, sensory, detection,
-- photographic and underwater equipment. Printed 214-216. Eighty-four rows.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-hu-gear-f-surveillance.sql
--
-- These three pages are the labelled-prose shape of 207-208 - a name, a colon,
-- prose, and inline Range:/Weight:/Cost: markers - with one photographic price
-- TABLE at the end of 216. A render of printed 214 at 205 dpi confirmed the
-- cache reads them accurately, figure for figure, so the transcription is from
-- the cache with renders used to settle the ambiguous entries rather than every
-- entry.
--
-- ===================================================================
-- HOW THE COUNT WAS CHECKED, AND WHAT IT FOUND
-- ===================================================================
--
-- A parser over these pages returned 53 entries against 63 `Cost` markers. That
-- ten-entry gap is the whole reason this file is transcribed rather than
-- generated, and every one of the ten was a real row:
--
--   * `Compact Commercial Wireless Microphone` ($70-$150) sits directly under
--     `Commercial Wireless Microphone` ($50-100) and was swallowed by it.
--   * `Sound Amplifier (high quality)` ($250) sits directly under
--     `Sound Amplifier` ($50) and was swallowed the same way.
--   * `Room Bug` carries TWO prices in one sentence - $100 homemade or $500 for
--     the police version - and is two rows here.
--   * `Video Wall Mount` prices its hand-held monitor separately at $450.
--   * `Field Strength Meter`, `Dosimeter`, `Standard Radar/Sonar Unit (large)`,
--     `Portable Laboratory`, `Portable Scan Dihilator` and
--     `Radar Signal Detector (military)` were each missed for their own reason -
--     a heading on its own line, a reading order the OCR reversed, or an entry
--     whose price is on the FOLLOWING page.
--
-- TWO ENTRIES SPAN A PAGE BREAK and are filed under the page carrying the price:
-- `Optics Band` begins on printed 213 and `Portable Laboratory` on 215.
--
-- ===================================================================
-- THREE HEADINGS THE BOOK PRINTS AS SINGLE WORDS
-- ===================================================================
--
-- Inside the ground-sensor group, printed 215 heads two rows simply `Heat` and
-- `Motion`. Those are legible in the group and meaningless out of it, so they
-- are stored as `Heat Sensor` and `Motion Sensor` with the printed form in the
-- description - the same treatment the STAVES rows got on printed 194.
-- `Tie Clasp` becomes `Tie Clasp Microphone` for the same reason.
--
-- `Listening (bugging) Device` is NOT a row. Printed 214 uses it as a heading
-- over the bugs that follow, giving an average range of 600ft and no price.
--
-- ===================================================================
-- TWO PRICES THE COLUMN CANNOT HOLD
-- ===================================================================
--
-- The two 35mm film rows are $2.50 and $4.50. `cost` is an INTEGER of dollars,
-- so both carry a NULL cost with the figure in cost_note - the same treatment
-- rope, the ninja rope ladder and the magazine clips got, and not the usual
-- meaning of a NULL cost, which the note says.
--
-- Guarded with INSERT OR IGNORE on a UNIQUE slug, so re-running is a no-op.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('optics-band-hu', 'Optics Band', 'heroes-unlimited', 'gear', NULL, 2800, NULL, '7ft', 0, 'A headband optical system used in research, micro-repairs and scientific study; its range is limited because it is designed for close work rather than long-distance or combat surveillance. Infrared and ultraviolet optics to 200ft (90m), a magnification lens to the 400th power, a night sight to 200ft (90m), and adjustable colour filters. The entry begins on printed 213 and its price is on 214.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('pocket-range-finder', 'Pocket Range Finder', 'heroes-unlimited', 'gear', NULL, 58, NULL, NULL, 0, 'An optical range finder: look through the viewfinder and adjust the focus knob until the image is clear, and the range in feet AND meters appears below the target.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('illuminating-peglight', 'Illuminating Peglight', 'heroes-unlimited', 'gear', NULL, 50, '$50 each', NULL, 0, 'Designed for military use as markers for routes and minefields. Emits beta light, which gives off no heat and no infrared emissions. Visible up to 150ft.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('field-radio-hu', 'Field Radio', 'heroes-unlimited', 'gear', 16, 1400, 'good availability', '60 miles (96km)', 0, 'A back-pack style transmitter and receiver with wide band long-range capability, frequency equalizer, field strength detector and scrambler.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('back-pack-radio', 'Back-Pack Radio', 'heroes-unlimited', 'gear', NULL, 925, NULL, '35 miles (56km)', 0, 'A Japanese updated version of the old PRC-25, the RKO-68. Built-in scrambler and up to 1500 channels, and it also receives commercial AM/FM, television sound and short-wave.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('belt-radio', 'Belt Radio', 'heroes-unlimited', 'gear', 2, 115, NULL, '2 to 3 miles', 0, 'A lightweight unit designed to work with the RKO-68. Scrambler equipped, up to 10 preset channels, complete with pouch and telephone-style handset. RKO-12.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('headset-receiver', 'Headset Receiver', 'heroes-unlimited', 'gear', NULL, 42, NULL, '2 miles', 0, 'A receiver-only unit that attaches easily to a helmet. Built-in scrambler.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('hand-held-communicator', 'Hand-Held Communicator', 'heroes-unlimited', 'gear', 0.375, 3200, '$3200 per single unit', '3 miles (4.8km)', 0, 'An enhanced walkie-talkie, the basic instrument issued to all military personnel and field operatives. A high-tech item available only to special branches of the military and to major scientific organizations. Printed weight 6 ounces (170grams).', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('ear-mike-radio-receiver-and-transmitter', 'Ear Mike Radio Receiver and Transmitter', 'heroes-unlimited', 'gear', NULL, 500, NULL, '1 mile', 0, 'Printed 214.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('keyhole-or-tube-microphones-hu', 'Keyhole or Tube Microphones', 'heroes-unlimited', 'gear', NULL, 170, NULL, 'transmits up to 1000ft (300m)', 0, 'Picks up sound from up to 10 meters away.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('contact-microphone-hu', 'Contact Microphone', 'heroes-unlimited', 'gear', NULL, 170, 'fair availability', NULL, 0, 'Printed 214.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('commercial-wireless-microphone', 'Commercial Wireless Microphone', 'heroes-unlimited', 'gear', NULL, 50, '$50-100', NULL, 0, 'The entertainment type. Printed 214.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('compact-commercial-wireless-microphone', 'Compact Commercial Wireless Microphone', 'heroes-unlimited', 'gear', NULL, 70, '$70-$150', NULL, 0, 'About the size of a pack of cigarettes. A SEPARATE entry from the Commercial Wireless Microphone above it, with its own price.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('wireless-microphone-hu', 'Wireless Microphone', 'heroes-unlimited', 'gear', NULL, 500, 'poor availability', 'picks up to 14ft, broadcasts up to 300ft', 0, 'A compact mic about the size and thickness of a box of matches.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('tracer-bug-hu', 'Tracer Bug', 'heroes-unlimited', 'gear', NULL, 140, 'fair availability', 'followed up to 8 miles (12km)', 0, 'Slipped into a vehicle, a pocket, a back pack or a brief case. Battery powered, with a limited life of 72 hours of constant transmission.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('bumper-beeper', 'Bumper Beeper', 'heroes-unlimited', 'gear', NULL, 1100, '$1100.00, and the price INCLUDES the receiver', 'up to five miles', 0, 'Attaches to an automobile bumper by magnetized clip, with a permanently mounted or detachable antenna. The receiver locates the beeper by the intensity of the signal.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('tie-clasp-microphone', 'Tie Clasp Microphone', 'heroes-unlimited', 'gear', NULL, 15, NULL, NULL, 0, 'Printed 214 heads this simply Tie Clasp, under the Listening (bugging) Device group whose average range is 600ft.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('electret-condenser-lavalier-mic', 'Electret Condenser Lavalier Mic.', 'heroes-unlimited', 'gear', NULL, 50, NULL, NULL, 0, 'Hangs around the neck or attaches to cloth. Battery operated or plugged in.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('broadcast-quality-tie-tack', 'Broadcast Quality Tie Tack', 'heroes-unlimited', 'gear', NULL, 160, NULL, NULL, 0, 'Printed 214.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('special-bugs', 'Special Bugs', 'heroes-unlimited', 'gear', NULL, 400, NULL, 'average 60ft', 0, 'A variety of sizes from postage stamp to martini-olive type, complete with mic, transmitter and amplifier.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('room-bug-homemade', 'Room Bug (homemade)', 'heroes-unlimited', 'gear', NULL, 100, '$100 homemade; printed 214 prices a police version of the same bug at $500', '1200ft', 0, 'Taps into the wall current and needs a capacitor.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('room-bug-police-version', 'Room Bug (police version)', 'heroes-unlimited', 'gear', NULL, 500, 'the police version of the $100 homemade bug on the same page', '1200ft', 0, 'Taps into the wall current and needs a capacitor.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('low-frequency-converter', 'Low-Frequency Converter', 'heroes-unlimited', 'gear', NULL, 190, NULL, NULL, 0, 'Blocks some frequencies and boosts others.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('test-transmitter', 'Test Transmitter', 'heroes-unlimited', 'gear', NULL, 65, NULL, NULL, 0, 'Printed 214.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('additional-transducer', 'Additional Transducer', 'heroes-unlimited', 'gear', NULL, 75, NULL, NULL, 0, 'Printed 214.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('telephone-induction-unit', 'Telephone Induction Unit', 'heroes-unlimited', 'gear', NULL, 65, NULL, NULL, 0, 'Printed 214.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('sound-amplifier', 'Sound Amplifier', 'heroes-unlimited', 'gear', NULL, 50, NULL, NULL, 0, 'Printed 214.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('sound-amplifier-high-quality', 'Sound Amplifier (high quality)', 'heroes-unlimited', 'gear', NULL, 250, NULL, NULL, 0, 'A SEPARATE entry from the $50 Sound Amplifier directly above it on printed 214.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('drop-in-cartridge', 'Drop in Cartridge', 'heroes-unlimited', 'gear', NULL, 320, NULL, NULL, 0, 'A telephone bug: the cartridge drops into a handset and carries its own receiver.', 'Revised Heroes Unlimited p.214');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('room-bug-mini-transmitter', 'Room Bug Mini-Transmitter', 'heroes-unlimited', 'gear', NULL, 240, NULL, NULL, 0, 'Looks like a telephone jack. Battery operated.', 'Revised Heroes Unlimited p.215');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('telephone-line-transmitter', 'Telephone Line Transmitter', 'heroes-unlimited', 'gear', NULL, 250, NULL, NULL, 0, 'Taps right into the telephone line and its power, so it needs no batteries and runs indefinitely. A slightly larger box than the mini-transmitter.', 'Revised Heroes Unlimited p.215');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('field-strength-meter', 'Field Strength Meter', 'heroes-unlimited', 'gear', NULL, 350, NULL, NULL, 0, 'A bug detector: picks up radio signals and registers them.', 'Revised Heroes Unlimited p.215');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('broadband-receiver', 'Broadband Receiver', 'heroes-unlimited', 'gear', NULL, 425, NULL, NULL, 0, 'A bug detector: causes feedback and howls when near a transmitter.', 'Revised Heroes Unlimited p.215');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('pocket-vibration-detector', 'Pocket Vibration Detector', 'heroes-unlimited', 'gear', NULL, 600, NULL, NULL, 0, 'Printed 215.', 'Revised Heroes Unlimited p.215');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('pocket-scrambler-hu', 'Pocket Scrambler', 'heroes-unlimited', 'gear', NULL, 1300, 'poor availability', NULL, 0, 'Distorts outgoing radio signals, preventing interception and interpretation by the enemy.', 'Revised Heroes Unlimited p.215');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('portable-telephone-scrambler', 'Portable Telephone Scrambler', 'heroes-unlimited', 'gear', NULL, 1400, NULL, NULL, 0, 'Converts normal speech into unintelligible gibberish over the line and back again, with 25 different scrambling codes. Fully transistorized, usable on any conventional phone, and supplied in an impact resistant carrying case.', 'Revised Heroes Unlimited p.215');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('video-briefcase', 'Video Briefcase', 'heroes-unlimited', 'gear', NULL, 3400, NULL, NULL, 0, 'An ordinary looking briefcase with a video unit and a back-up mini-cassette tape recorder.', 'Revised Heroes Unlimited p.215');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('video-wall-mount-hu', 'Video Wall Mount', 'heroes-unlimited', 'gear', NULL, 3200, 'Not available through the conventional market', NULL, 0, 'A small remote video camera. Printed 215 prices its hand-held monitor separately at $450.', 'Revised Heroes Unlimited p.215');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('video-wall-mount-hand-held-monitor', 'Video Wall Mount Hand-Held Monitor', 'heroes-unlimited', 'gear', NULL, 450, '$450; a hot commodity on the black market', NULL, 0, 'The monitor for the Video Wall Mount, priced separately on printed 215.', 'Revised Heroes Unlimited p.215');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('mini-telephoto-document-camera', 'Mini-Telephoto Document Camera', 'heroes-unlimited', 'gear', NULL, 350, NULL, NULL, 0, 'A tiny, easy to conceal camera only a little bigger than a disposable lighter.', 'Revised Heroes Unlimited p.215');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('dosimeter', 'Dosimeter', 'heroes-unlimited', 'gear', 1, 200, 'wide availability', '20ft (6.1m)', 0, 'Hand-held. Picks up and measures radiation levels.', 'Revised Heroes Unlimited p.215');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('ground-sensor-system', 'Ground Sensor System', 'heroes-unlimited', 'gear', NULL, 48500, 'poor availability', NULL, 0, 'Uses seismic and laser sensors. Generally limited to the military and to high-security installations.', 'Revised Heroes Unlimited p.215');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('heat-sensor-hu', 'Heat Sensor', 'heroes-unlimited', 'gear', 8, 1200, NULL, '250ft (76m)', 0, 'Special sensors pick up and measure heat emanations. Printed 215 heads this row simply Heat, among the ground sensor types; named in full here so it is legible out of that group.', 'Revised Heroes Unlimited p.215');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('microwave-fence-hu', 'Microwave Fence', 'heroes-unlimited', 'gear', NULL, 60000, 'poor availability', NULL, 0, 'Transmitter and receiver sensor posts emit a microwave barrier over an area of up to 14 miles (22km).', 'Revised Heroes Unlimited p.215');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('motion-sensor', 'Motion Sensor', 'heroes-unlimited', 'gear', 15, 400, 'fair availability', '60ft (27.4m)', 0, 'Detects movement and pinpoints location. Portable. Printed 215 heads this row simply Motion, among the ground sensor types.', 'Revised Heroes Unlimited p.215');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('motion-detector-signaler', 'Motion Detector Signaler', 'heroes-unlimited', 'gear', NULL, 1000, 'poor availability', NULL, 0, 'Virtually identical to the motion detector, but it does not emit any vibrations in the air.', 'Revised Heroes Unlimited p.215');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('mini-radar-sonar', 'Mini-Radar/Sonar', 'heroes-unlimited', 'gear', 18, 22500, 'fair availability', '5 miles (8km)', 0, 'Requires a radar signal unit and monitor. A trained operator with the sensory equipment skill can identify readings, pinpoint location and estimate rate of travel and direction at 65% proficiency. Portable.', 'Revised Heroes Unlimited p.215');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('standard-radar-sonar-unit-large', 'Standard Radar/Sonar Unit (large)', 'heroes-unlimited', 'gear', 260, 26000, NULL, '100 miles (160km)', 0, 'Printed 215.', 'Revised Heroes Unlimited p.215');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('ultraviolet-signaler-hu', 'Ultraviolet Signaler', 'heroes-unlimited', 'gear', NULL, 900, 'fair availability', NULL, 0, 'A strip of ultraviolet sensors and a transmitter strip adhered to a doorway or wall, creating a beam of invisible light across the area. When an intruder breaks the beam it sends a silent signal to a monitoring device or triggers a video unit.', 'Revised Heroes Unlimited p.215');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('portable-laboratory-hu', 'Portable Laboratory', 'heroes-unlimited', 'gear', 58, 42000, 'poor availability', NULL, 0, 'A portable unit holding a microscope in padded housing, a dozen specimen slides and a dozen trays with vials and test tubes, an incubation chamber the size of a VCR, four burners, an instrument tray, a refrigeration chamber, an airtight isolation chamber, a chemical cabinet of several dozen chemicals, and a centrifuge. The entry begins on printed 215 and its price is on 216.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('portable-scan-dihilator', 'Portable Scan Dihilator', 'heroes-unlimited', 'gear', NULL, 50000, 'about $50,000; poor availability, usually limited to scientific research and the military', NULL, 0, 'A comprehensive sensory device with full scanning: radar/sonar over a 5 mile area at 65% proficiency for a trained operator; dosimeter, radar detector, heat, infrared, ultraviolet, microwave and energy sensors that identify, locate and record; a long-range wide band radio with scrambler over a 40 mile radius; a detachable hand-held communicator to 3 miles; and a mini video camera with wide and narrow angle lenses, an audio-visual recorder on metal discs, lens filters, a telescopic lens and a tripod.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('amplified-sound-detector', 'Amplified Sound Detector', 'heroes-unlimited', 'gear', 2, 160, NULL, NULL, 0, 'A two-piece unit of headphones and a sound detector that resembles a very large flashlight, with a built-in parabolic dish for the sound mirror effect. TRIPLES the normal human range of hearing. Used by the security industry.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('bug-detector', 'Bug Detector', 'heroes-unlimited', 'gear', NULL, 350, NULL, NULL, 0, 'A small hand-held device that picks up radio signals from listening devices.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('letter-bomb-detector', 'Letter Bomb Detector', 'heroes-unlimited', 'gear', NULL, 700, NULL, NULL, 0, 'Examines letters in minutes, with an audio alarm that sounds when electrically conductive material is detected.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('portable-explosives-detector', 'Portable Explosives Detector', 'heroes-unlimited', 'gear', NULL, 1900, NULL, '3.5ft', 0, 'Responds to vapour from explosives such as dynamite, gelignite and T.N.T. An alarm lamp lights when an explosive is detected.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('radar-signal-detector-military', 'Radar Signal Detector (military)', 'heroes-unlimited', 'gear', NULL, 3000, NULL, '80ft effective, 4 miles maximum', 0, 'A mini radar receiver that fits in one hand. Small, lightweight and easy to conceal; recently developed for the U.S. Army.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('commercial-radar-detector', 'Commercial Radar Detector', 'heroes-unlimited', 'gear', NULL, 120, NULL, NULL, 0, 'Also known as the Fuzz Buster, for its use in detecting police radar scans.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('psychological-stress-evaluator', 'Psychological Stress Evaluator', 'heroes-unlimited', 'gear', NULL, 4000, NULL, NULL, 0, 'Used by law enforcement, private investigators, corporations, clinics and law firms. Functions like a polygraph but measures and records stress and anxiety WITHOUT attaching sensors, by monitoring the subject''s voice quality. Includes a tape recorder.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('polygraph-stress-machine', 'Polygraph Stress Machine', 'heroes-unlimited', 'gear', NULL, 2400, NULL, NULL, 0, 'Sensors attached to the skin monitor and record glandular changes, including sweat.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('polygraph-stress-monitor', 'Polygraph Stress Monitor', 'heroes-unlimited', 'gear', NULL, 4500, NULL, NULL, 0, 'Superior quality. Sensors on the skin and body record breathing, heart rate, blood pressure and skin resistance, fed into a chart recorder with three pens.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('35mm-camera', '35mm Camera', 'heroes-unlimited', 'gear', NULL, 250, NULL, NULL, 0, 'Printed 216, PHOTOGRAPHIC EQUIPMENT.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('camera-lens-28mm-f2-8', 'Camera Lens, 28mm F2.8', 'heroes-unlimited', 'gear', NULL, 80, NULL, NULL, 0, 'An extra lens for the 35mm camera, printed 216.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('camera-lens-135mm-f3-5', 'Camera Lens, 135mm F3.5', 'heroes-unlimited', 'gear', NULL, 80, NULL, NULL, 0, 'An extra lens for the 35mm camera, printed 216.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('camera-flash-average', 'Camera Flash (average)', 'heroes-unlimited', 'gear', NULL, 50, NULL, NULL, 0, 'Printed 216.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('35mm-film-black-and-white-36-exposure', '35mm Film, Black and White, 36 exposure', 'heroes-unlimited', 'gear', NULL, NULL, '$2.50 - BELOW THE RESOLUTION of an integer cost column, so it is recorded here rather than rounded', NULL, 0, 'Printed 216.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('35mm-film-color-36-exposure', '35mm Film, Color, 36 exposure', 'heroes-unlimited', 'gear', NULL, NULL, '$4.50 - below the resolution of an integer cost column', NULL, 0, 'Printed 216.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('super-8mm-sound-movie-camera', 'Super 8mm Sound Movie Camera', 'heroes-unlimited', 'gear', NULL, 525, NULL, NULL, 0, 'Printed 216.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('super-8mm-film', 'Super 8mm Film', 'heroes-unlimited', 'gear', NULL, 8, '$8.00 for approximately 15 minutes running time', NULL, 0, 'Printed 216.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('slide-projector', 'Slide Projector', 'heroes-unlimited', 'gear', NULL, 150, NULL, NULL, 0, 'Printed 216.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('projection-screen', 'Projection Screen', 'heroes-unlimited', 'gear', NULL, 50, NULL, NULL, 0, 'Printed 216.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('vhs-video-recorder', 'VHS Video Recorder', 'heroes-unlimited', 'gear', NULL, 500, NULL, NULL, 0, 'Printed 216.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('beta-video-recorder', 'Beta Video Recorder', 'heroes-unlimited', 'gear', NULL, 400, NULL, NULL, 0, 'Printed 216.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('video-camera-with-tripod', 'Video Camera with Tripod', 'heroes-unlimited', 'gear', NULL, 2000, NULL, NULL, 0, 'Printed 216.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('full-video-studio', 'Full Video Studio', 'heroes-unlimited', 'gear', NULL, 180000, '$180,000 for the BASIC system', NULL, 0, 'With editing, dubbing, optical enhancements and full film capabilities.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('color-camera-with-mike', 'Color Camera with Mike', 'heroes-unlimited', 'gear', NULL, 700, NULL, NULL, 0, 'Printed 216.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('videotape-cassette', 'Videotape Cassette', 'heroes-unlimited', 'gear', NULL, 10, NULL, NULL, 0, 'Printed 216.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('telescope-zoom-15-60x-power', 'Telescope, zoom 15-60X power', 'heroes-unlimited', 'gear', NULL, 190, NULL, NULL, 0, '1000-4000mm when attached to a 35mm camera.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('35mm-camera-adapter', '35mm Camera Adapter', 'heroes-unlimited', 'gear', NULL, 30, NULL, NULL, 0, 'Printed 216.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('mask-snorkel-and-fin-package', 'Mask, Snorkel and Fin Package', 'heroes-unlimited', 'gear', NULL, 110, NULL, NULL, 0, 'Printed 216, UNDERWATER EQUIPMENT.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('s-c-u-b-a-package', 'S.C.U.B.A. Package', 'heroes-unlimited', 'gear', NULL, 820, NULL, NULL, 0, 'An 80K cylinder with boot, datacom double console (PSI depth), regulator, wet suit, pack and power. OXYGEN CAPACITY 90 MINUTES.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('compact-s-c-u-b-a', 'Compact S.C.U.B.A.', 'heroes-unlimited', 'gear', NULL, 155, NULL, NULL, 0, 'A one unit, 2 cubic foot capacity air tank with the regulator mounted on top and a belt holder, 17 by 24 inches. Good for short dives or emergency air. OXYGEN CAPACITY 15 MINUTES.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('mini-s-c-u-b-a', 'Mini S.C.U.B.A.', 'heroes-unlimited', 'gear', NULL, 300, 'Not commercially available; espionage', NULL, 0, 'A tiny air tank and regulator measuring 5 by 2.5 inches. OXYGEN CAPACITY A MERE FOUR MINUTES.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('diver-s-watch', 'Diver''s Watch', 'heroes-unlimited', 'gear', NULL, 300, NULL, NULL, 0, 'Multifunctional digital and analog display, alarm, two time zones, timer, rotating bezel and sweep second hand.', 'Revised Heroes Unlimited p.216');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('dive-flasher', 'Dive Flasher', 'heroes-unlimited', 'gear', NULL, 30, NULL, NULL, 0, 'A waterproof beacon or rescue marker, waterproof to 150ft, 5 by 1.5 inches, running on one C battery.', 'Revised Heroes Unlimited p.216');

-- ASSERTIONS.

SELECT 'all eighty-four rows landed' AS assertion, count(*) AS got, 84 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.214',
    'Revised Heroes Unlimited p.215', 'Revised Heroes Unlimited p.216');

SELECT 'twenty-nine from printed 214' AS assertion, count(*) AS got, 29 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.214';
SELECT 'twenty from printed 215' AS assertion, count(*) AS got, 20 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.215';
SELECT 'thirty-five from printed 216' AS assertion, count(*) AS got, 35 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.216';

SELECT 'every one is Heroes Unlimited gear' AS assertion, count(*) AS got, 84 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.214',
    'Revised Heroes Unlimited p.215', 'Revised Heroes Unlimited p.216')
   AND system = 'heroes-unlimited' AND category = 'gear';

-- THE TEN THE PARSER MISSED. Each is named, because each is the reason this file
-- was transcribed rather than generated, and a future re-extraction that loses
-- one would otherwise look like a clean run.
SELECT 'the two microphones the parser merged are two rows' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE name IN ('Commercial Wireless Microphone', 'Compact Commercial Wireless Microphone')
   AND cost IN (50, 70);
SELECT 'the two sound amplifiers are two rows' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE name IN ('Sound Amplifier', 'Sound Amplifier (high quality)')
   AND cost IN (50, 250) AND source_book = 'Revised Heroes Unlimited p.214';
SELECT 'the room bug is two rows at its two prices' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE name IN ('Room Bug (homemade)', 'Room Bug (police version)')
   AND cost IN (100, 500);
SELECT 'the video wall mount and its monitor are two rows' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE name IN ('Video Wall Mount', 'Video Wall Mount Hand-Held Monitor')
   AND cost IN (3200, 450);
SELECT 'the six the parser missed outright are all here' AS assertion, count(*) AS got, 6 AS want
  FROM gear WHERE name IN ('Field Strength Meter', 'Dosimeter',
    'Standard Radar/Sonar Unit (large)', 'Portable Laboratory',
    'Portable Scan Dihilator', 'Radar Signal Detector (military)')
   AND system = 'heroes-unlimited';

-- The single-word headings, renamed so they read out of their group.
SELECT 'the ground sensors are named in full' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE name IN ('Heat Sensor', 'Motion Sensor')
   AND source_book = 'Revised Heroes Unlimited p.215' AND cost IN (1200, 400);

-- The section heading that is NOT an item. If a row ever appears under this
-- name, something read a heading as an entry.
SELECT 'the bugging-device heading is not a row' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE instr(name, 'Listening (bugging)') > 0;

-- EXACTLY TWO rows have no price, and they are the two sub-dollar film rows.
SELECT 'exactly two rows have no cost' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.214',
    'Revised Heroes Unlimited p.215', 'Revised Heroes Unlimited p.216')
   AND cost IS NULL;
SELECT 'and both are film, with the figure in the note' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE instr(name, '35mm Film') > 0 AND cost IS NULL
   AND (instr(cost_note, '2.50') > 0 OR instr(cost_note, '4.50') > 0);

-- TEXT CHECKS, because a previous batch passed every count while every string in
-- it was mangled.
SELECT 'the scan dihilator description survived' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Portable Scan Dihilator'
   AND instr(description, 'scanning') > 0 AND instr(description, 'scrambler') > 0;
SELECT 'and the sound detector kept its s letters' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Amplified Sound Detector'
   AND instr(description, 'parabolic dish') > 0;

INSERT INTO data_script_runs (filename) VALUES ('add-hu-gear-f-surveillance.sql');
