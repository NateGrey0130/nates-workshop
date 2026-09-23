"""Extract the Ultimate Powers Book's power listings into the gitignored
.cache/msh/, for Marvel Heroes' full-text table. Nothing this writes is ever
committed: this repository is public and the text is TSR's.

    python scripts/msh-extract.py "<path to TSR6876 Ultimate Powers Book PDF>"

Writes:
  .cache/msh/powers-full.json   every power's printed header, page and text
  .cache/msh/power-text.sql     the data script d1-apply loads into msh_power_text

and then applies it with:

    node scripts/d1-apply.mjs --remote .cache/msh/power-text.sql

WHY IT FINDS HEADERS BY NAME, IN ORDER. The listings print each power as
"CODE/Name:", but seven headers misprint their own code - "D20/True Sight" is
DT20, "MC/4Diminution" is MC4, a bare "MC/Machine Animation" is MC9,
"T17/Telereformation" is T18 - and many lines start with a code that is only a
cross-reference ("The nemesis is MC4/Diminution"). So the walk takes the codes
in the order apps/marvel-heroes/data/power-tables.json gives them and, for
each, finds the next header line after the previous power whose name matches.
The code a power is stored under comes from the roll tables, never from the
header, and the printed header is kept alongside it.

The text is folded to ASCII (quotes, dashes, ellipses) because d1-apply
refuses non-ASCII in executable SQL. The pymupdf text layer is clean for prose;
it is not used for any table.
"""
import json, os, re, sys, unicodedata

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CACHE = os.environ.get("WORKSHOP_MSH_CACHE") or os.path.join(ROOT, ".cache", "msh")
TABLES = os.path.join(ROOT, "apps", "marvel-heroes", "data", "power-tables.json")
FIRST_PDF_PAGE, LAST_PDF_PAGE = 20, 102        # printed pages 18-100
PRINTED_OFFSET = 2                              # printed page = PDF page - 2

# The sixteen section headings, as the table of contents (p.1) names them. A
# pattern like "... Powers" also matches prose lines, and did.
SECTION_HEADINGS = {"Defense Powers", "Detection Powers", "Energy Control Powers", "Energy Emission Powers",
                    "Fighting Powers", "Illusory Powers", "Life Control Powers", "Magical Powers",
                    "Matter Control Powers", "Matter Conversion Powers", "Matter Creation Powers",
                    "Mental Enhancement Powers", "Physical Enhancement Powers", "Physical Enhancement",
                    "Power Control Powers",
                    "Self-Alteration Powers", "Travel Powers"}

FOLD = {"‘": "'", "’": "'", "“": '"', "”": '"', "–": "-", "—": " - ",
        "…": "...", " ": " ", "�": "-", "­": ""}

def ascii_fold(s):
    s = "".join(FOLD.get(ch, ch) for ch in s)
    s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode("ascii")
    return s

def words(s):
    return re.findall(r"[a-z0-9]+", s.lower())

def main(pdf):
    import pymupdf
    doc = pymupdf.open(pdf)
    lines = []  # (printed page, text)
    for i in range(FIRST_PDF_PAGE - 1, LAST_PDF_PAGE):
        for ln in doc[i].get_text().split("\n"):
            lines.append((i + 1 - PRINTED_OFFSET, ascii_fold(ln).rstrip()))
    tables = json.load(open(TABLES))["tables"]
    order = [p for rows in tables.values() for p in rows]

    header = re.compile(r"^\s*([A-Za-z]{0,3}\s*/?\s*\d{0,2}\s*/?)\s*([A-Z][^:]{1,70}):")
    found, pos = [], 0
    for p in order:
        want = words(p["name"])[:2]
        hit = None
        for j in range(pos, len(lines)):
            # A header's name can wrap onto the next line before its colon.
            text = lines[j][1] if ":" in lines[j][1] else lines[j][1] + " " + (lines[j + 1][1] if j + 1 < len(lines) else "")
            m = header.match(text)
            if not m:
                continue
            # Either the header prints this power's code, or (for the seven
            # that misprint it) its name opens with the table's name. The
            # table and the header word some names differently - "Resist:
            # Emotion" is headed "Resistance to Emotion Attacks" - which is
            # why the code is tried first.
            printed = re.sub(r"\s", "", m.group(1))
            if printed == p["code"] + "/" or words(m.group(2))[:len(want)] == want:
                hit = (j, m)
                break
        if hit is None:
            sys.exit(f"no header found for {p['code']} {p['name']} after line {pos}")
        j, m = hit
        found.append({"code": p["code"], "name": p["name"], "printed_header": (m.group(1) + m.group(2)).strip(),
                      "page": lines[j][0], "start": j, "head_len": len(m.group(0))})
        pos = j + 1

    # Each class opens with a heading line ("Magical Powers") and sometimes an
    # introduction before its first power - the Magic section's is a page of
    # rules. Without these cuts the heading and the introduction ride on the
    # end of the previous class's last power.
    headings = {}
    first_of = {}
    for f in found:
        first_of.setdefault(re.match(r"[A-Za-z]+", f["code"]).group(0), f["start"])
    for cls, start in first_of.items():
        prev = max([f["start"] for f in found if f["start"] < start] or [-1])
        for j in range(prev + 1, start):
            if lines[j][1].strip() in SECTION_HEADINGS:
                headings[cls] = j
                break
    cuts = sorted(headings.values())

    out = {}
    for k, f in enumerate(found):
        end = found[k + 1]["start"] if k + 1 < len(found) else len(lines)
        end = min([c for c in cuts if f["start"] < c < end] or [end])
        chunk = [lines[f["start"]][1][f["head_len"]:]] + [t for _, t in lines[f["start"] + 1:end]]
        body = "\n".join(chunk)
        body = re.sub(r"-\n(?=[a-z])", "", body)                 # rejoin hyphenated words
        body = re.sub(r"(?m)^\s*\d{1,3}\s*$", "", body)           # folios
        body = re.sub(r"(?m)^[A-Z][A-Z \-]{3,}$", "", body)       # running heads (DETECTION)
        body = re.sub(r"\s*\n\s*", " ", body).strip()
        out[f["code"]] = {"name": f["name"], "printed_header": f["printed_header"], "page": f["page"], "body": body}

    # Class introductions, stored under the bare class code ("MG") so the power
    # browser can show a section's own rules above its powers.
    for cls, j in headings.items():
        intro = " ".join(t for _, t in lines[j + 1:first_of[cls]])
        intro = re.sub(r"\s+", " ", re.sub(r"-\s(?=[a-z])", "", intro)).strip()
        if len(intro) >= 80:
            out[cls] = {"name": lines[j][1].strip(), "printed_header": lines[j][1].strip(),
                        "page": lines[j][0], "body": intro, "intro": True}

    # The book's index (printed pp.101-102) against the roll tables: the same
    # codes, every one once. The walk above trusts the tables' code order, so
    # this is the check that the tables themselves are the whole list.
    index = {}
    for i in (102, 103):
        for ln in doc[i].get_text().split("\n"):
            m = re.match(r"^(.+?)\s*(?:\.\s*)+\s*([A-Za-z]{1,3}\d{1,2})\s*$", ascii_fold(ln))
            if m:
                index[m.group(2)] = m.group(1).strip()
    table_codes = {p["code"] for p in order}
    if set(index) != table_codes:
        sys.exit("the index and the roll tables disagree: only in the index %s, only in the tables %s"
                 % (sorted(set(index) - table_codes), sorted(table_codes - set(index))))
    print(f"the index names the same {len(index)} codes as the roll tables")

    os.makedirs(CACHE, exist_ok=True)
    with open(os.path.join(CACHE, "powers-full.json"), "w", encoding="ascii", newline="\n") as fh:
        json.dump(out, fh, indent=1)

    def q(s):
        return "'" + s.replace("'", "''") + "'"
    sql = ["-- msh_power_text: the Ultimate Powers Book's power listings, for Marvel Heroes.",
           "-- GENERATED by scripts/msh-extract.py into the gitignored .cache/msh/. NEVER COMMIT:",
           "-- this is the book's own text and the repository is public.",
           "--",
           "--   node scripts/d1-apply.mjs --remote .cache/msh/power-text.sql",
           "",
           "DELETE FROM msh_power_text;"]
    for code, e in out.items():
        sql.append("INSERT INTO msh_power_text (code, name, page, body) VALUES (%s, %s, %d, %s);"
                   % (q(code), q(e["name"]), e["page"], q(e["body"])))
    sql += ["", "SELECT 'every power has its text' AS assertion, count(*) AS got, %d AS want FROM msh_power_text;" % len(out),
            "SELECT 'and none of it is empty' AS assertion, count(*) AS got, 0 AS want FROM msh_power_text WHERE length(body) < 40;", ""]
    with open(os.path.join(CACHE, "power-text.sql"), "w", encoding="ascii", newline="\n") as fh:
        fh.write("\n".join(sql))
    short = [c for c, e in out.items() if len(e["body"]) < 200]
    misprinted = [c for c, e in out.items() if not e["printed_header"].replace(" ", "").startswith(c + "/")]
    print(f"{len(out)} powers -> {CACHE}")
    print("header code differs from the table's:", ", ".join(f"{c} ({out[c]['printed_header'][:24]})" for c in misprinted))
    print("under 200 characters (read these):", ", ".join(short) or "none")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(sys.argv[1])
