# The heading shapes the menus use

Moved verbatim from `SKILL.md` → *The headings are not uniform, and that is
the argument*, which keeps the rule (read; do not pin shape with a check) and
the command that lists the menus.

**This table is a shape reference for the files it names. It is NOT the list of
menus**; a file missing from it is missing, not absent. The menu you are writing
is the row you will forget: **add it in the PR that creates the file.**

| file | prefix | level | shape |
|---|---|---|---|
| `BOOK-INGEST-AUDIT.md` | `F` | `###` | em dash on `F1`–`F4`, hyphen from `F5` on |
| `DOCS-AUDIT-2.md` | `D` | `###` | severity word: `### D1 — medium — …` |
| `MACHINE-AUDIT.md` | `M` | `###` | severity word: `### M1 — high — …` |
| `META-AUDIT.md` | `A` | `###` | severity word: `### A1 — medium — …`, **not in severity order** — it runs in its brief's order |
| `REPO-AUDIT.md` | `G` | `###` | severity word: `### G1 — high — …` |
| `DOCS-AUDIT.md` | `D` | `###` | severity **or status** word: `### D1 — low — …`, and `### D5 — WITHDRAWN — …` |
| `EFFICIENCY-AUDIT.md` | `F` | `###` | `### F1 — …` |
| `apps/character-creator/AUDIT.md` | `D`, `C`, `F` | `###` | severity word: `### D1 — low — …` |
| `apps/character-creator/CLASS-AUDIT.md` | `F`; `S` | `###`; **not a heading** | `### F17 — low — …`, and `- **S1 — …**` as BULLETS under `## Schema-can-now-express` |
| `apps/character-creator/INGESTION-AUDIT.md` | `F` | `###` | `### F1 — …` |
| `apps/character-creator/REBUILD-AUDIT.md` | `F` | `###` | `### F1 — …` |
| `apps/character-creator/REDESIGN-AUDIT.md` | `R`, `N` | `###` | severity word: `### R1 — high — …` |
| `apps/character-creator/RETRO-AUDIT.md` | `R` | `###` | severity word: `### R1 — high — …`. **Its `R` collides with `REDESIGN-AUDIT`'s**, so a bare `R3` names neither |
| `apps/character-creator/UI-AUDIT.md` | `F` | `###` | severity word: `### F1 — high — …` |
| `WORKSHOP-UI-AUDIT.md` | `W` | `###` | severity word: `### W1 — high — …`. **No other menu uses `W`**, chosen from a census so a bare number is unambiguous |
| `apps/media-vault/SHARE-AUDIT.md` | `V` | `##` | `## V1 — high — …`. **No other menu here uses `V`**, chosen so a bare number is unambiguous |
| `apps/media-vault/BULK-AUDIT.md` | `B` | `##` | `## B1 — …` |
| `apps/media-vault/ISBN-AUDIT.md` | `F` | `##` | `## F1 — …` |
| `HEALTH-AUDIT.md` | `F` | `###` | severity word, capitalised: `### F1 — Critical — …` |
| `SKILL-AUDIT.md` | `F`, `N` | `###` | `### F1 — …`, no severity word, and **every `###` is a finding** (`F38`, 2026-09-04). That file's own header names its sections. |
| `SHIP-PR-AUDIT.md` | `F` | `###` | `### F1 — …`, no severity word |
| `SETUP-v2-CHANGES.md` | **none** | `###` | `### 1. …` — bare numbers under `## Changes`, and the one menu whose filename does not say `AUDIT` |
