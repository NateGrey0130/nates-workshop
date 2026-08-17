// A starting point for writing a class by hand.
//
// A classic script, like derive.js and picker.js, because import.js is one.
// Exposes one global: `classTemplate(kind, { name, id, system })`.
//
// WHY BOTH KINDS. An RCC and an OCC are genuinely different shapes — a race
// rolls its attributes from racial dice and usually has M.D.C., a character
// class has attribute MINIMUMS and hit points. One template covering both would
// be half wrong whichever you were writing, and you would delete the other half
// every time.
//
// Everything here parses as-is: create one, hit Re-check, and it comes back
// clean. That matters more than it sounds — a template that fails validation on
// arrival teaches you nothing about which of your own edits broke it.
//
// The comments are the point. The fiddly parts (`variants`, `bonuses`, skill
// choice-groups, gear choices) are exactly what nobody remembers the shape of,
// and they are the reason writing a class by hand is worth supporting at all.

(function (global) {
  // id, name, system, source_book and category are the parser's required set,
  // so all five are asked for up front rather than left blank — a template that
  // fails validation the moment it is created teaches you nothing about which
  // of your own edits broke it.
  const shared = ({ id, name, system, sourceBook }) => `id: ${id}
name: ${name}
system: ${system}                 # rifts | palladium-fantasy
source_book: "${sourceBook}"`;

  const skillsBlock = `skills:
  occ_skills:                     # skills every character of this class gets
    - { name: "Basic Math", base: 60, per_level: 5 }
    # A choice-group instead of a name means "pick N of these":
    # - { choose: 2, from: ["Pilot: Hovercycle", "Pilot: Truck"], base: 45, per_level: 5 }
    # Or "any N from these categories":
    # - { choose: 2, categories: ["Pilot"], base: 45, per_level: 5 }
  occ_related_skills:             # chosen at creation from the listed categories
    count: 6
    categories: ["Physical", "Technical"]
    # schedule: [{ level: 3, count: 1 }]   # extra picks at later levels
  secondary_skills:
    count: 2                      # any category, base % only, no per-level gain`;

  const equipmentBlock = `equipment_starting:
  - { item_id: "back-pack", qty: 1 }        # slug from the gear catalog
  # When the book says "one energy pistol of choice", enumerate the options
  # rather than inventing a placeholder item that no book entry will match:
  # - { choose: 1, label: "energy pistol", qty: 1,
  #     from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol"] }`;

  // Numbers the app adds up, as opposed to the prose blocks below it, which are
  // shown and never acted on. A conditional bonus ("+2 to strike when flying")
  // belongs in prose — this block is applied unconditionally.
  const bonusesBlock = `bonuses:
  # attributes: { PS: 2 }                   # IQ ME MA PS PP PE PB Spd
  # combat: { attacks: 1, strike: 2 }
  # saves: { spell_magic: 2 }
  # at_level:
  #   - { level: 5, combat: { attacks: 1 } }`;

  const tailBlock = `special_abilities:
  - name: ""
    description: ""
level_progression:                # display-only wording; use bonuses for numbers
  - level: 2
    grants: ["+1 attack per melee"]
restrictions: []                  # things the class may not do
side_effects: ""                  # drawback mechanics, display only
extraction_notes: ""              # anything left unresolved, for a human`;

  const body = (name) => `
## Lore

Who ${name} are, in the book's voice. Shown to the player when they pick the class.

## GM Notes

Anything the GM should know and the player should not. Hidden from players.
`;

  function occ(o) {
    return `---
${shared(o)}
category: occ
attribute_requirements:           # minimums enforced at creation; omit if none
  IQ: 10
hit_points_base: "P.E. + 1d6 per level"
sdc_base: 20
ppe_base: "2d6"
starting_money: "2d6x10"          # gold (Palladium) or credits (Rifts); coin only
${skillsBlock}
${equipmentBlock}
${bonusesBlock}
# psionics:
#   type: minor                   # minor | major | master
#   isp_base: "1d6+ME"
# magic:
#   type: "innate"
#   spells_starting: 4
#   spell_levels_allowed: [1, 2]
${tailBlock}
---
${body(o.name)}`;
  }

  function rcc(o) {
    return `---
${shared(o)}
category: rcc
attribute_dice:                   # a race ROLLS its attributes from these
  IQ: "3d6"
  ME: "3d6"
  MA: "3d6"
  PS: "3d6"
  PP: "3d6"
  PE: "3d6"
  PB: "3d6"
  Spd: "3d6"
mdc_base: "1d4x100"               # M.D.C. beings use this instead of hp/sdc
ppe_base: "2d6"
starting_money: "2d6x10"          # gold (Palladium) or credits (Rifts); coin only
# Stages of the same creature — a hatchling and an adult. Each overrides only
# attribute_dice, attribute_requirements, the pool bases and bonuses; skills,
# abilities and lore stay shared. Delete this block if the class has one form.
# variants:
#   - id: hatchling
#     name: "${o.name} Hatchling"
#   - id: adult
#     name: "Adult ${o.name}"
#     attribute_dice: { PS: "4d6+30" }
#     mdc_base: "1d6x1000"
#     bonuses:
#       attributes: { PS: 4 }
#       combat: { attacks: 3 }
${skillsBlock}
${equipmentBlock}
${bonusesBlock}
natural_abilities:
  - name: ""
    description: ""
${tailBlock}
---
${body(o.name)}`;
  }

  global.classTemplate = function classTemplate(kind, opts) {
    return kind === 'rcc' ? rcc(opts) : occ(opts);
  };
})(globalThis);
