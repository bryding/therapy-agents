#!/usr/bin/env python3
"""Import an Apple Journal export folder into docs/journal/.

Usage: therapy import-journal <export-folder> [--dry-run]   (run inside a life repo)

Apple's export is a folder of one HTML file per entry (plus a resources/
media folder). Layout has varied between OS versions, so this walks the tree
for *.html, pulls the date from the filename or the document, extracts plain
text, and writes/appends to docs/journal/YYYY-MM-DD.md under a
"## Apple Journal" section. Media is never copied; photo filenames are listed.
Already-imported entries are skipped via a content hash recorded in
docs/journal/.imported.json.
"""
import hashlib, html, json, os, re, sys
from html.parser import HTMLParser

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import harness  # noqa: E402

ROOT = str(harness.find_root())
OUT = os.path.join(ROOT, "docs", "journal")
STATE = os.path.join(OUT, ".imported.json")
DATE_RE = re.compile(r"(\d{4})[-_/.](\d{2})[-_/.](\d{2})")
MONTHS = {m: i for i, m in enumerate(
    "january february march april may june july august september october november december".split(), 1)}
LONG_DATE_RE = re.compile(r"(january|february|march|april|may|june|july|august|september|october|november|december)\s+(\d{1,2}),?\s+(\d{4})", re.I)

class Text(HTMLParser):
    def __init__(self):
        super().__init__(); self.parts=[]; self.title=None; self.in_title=False
        self.media=[]; self.skip=0; self.times=[]
    def handle_starttag(self, tag, attrs):
        a=dict(attrs)
        if tag in ("script","style"): self.skip+=1
        if tag=="title": self.in_title=True
        if tag in ("p","div","br","li","h1","h2","h3","blockquote"): self.parts.append("\n")
        if tag in ("img","video","audio","source") and a.get("src"): self.media.append(os.path.basename(a["src"]))
        if tag=="time" and a.get("datetime"): self.times.append(a["datetime"])
        if tag=="meta" and a.get("name","").lower() in ("date","created","dcterms.created") and a.get("content"): self.times.append(a["content"])
    def handle_endtag(self, tag):
        if tag in ("script","style"): self.skip-=1
        if tag=="title": self.in_title=False
        if tag in ("p","div","li","h1","h2","h3","blockquote"): self.parts.append("\n")
    def handle_data(self, d):
        if self.skip: return
        if self.in_title: self.title=(self.title or "")+d
        else: self.parts.append(d)

def find_date(path, raw, parsed):
    for cand in [os.path.basename(path)] + parsed.times:
        m=DATE_RE.search(cand)
        if m: return "-".join(m.groups())
        m=LONG_DATE_RE.search(cand)
        if m: return f"{m.group(3)}-{MONTHS[m.group(1).lower()]:02d}-{int(m.group(2)):02d}"
    m=LONG_DATE_RE.search(raw)
    if m: return f"{m.group(3)}-{MONTHS[m.group(1).lower()]:02d}-{int(m.group(2)):02d}"
    return None

def main():
    if len(sys.argv)<2: print(__doc__); sys.exit(1)
    src=sys.argv[1]; dry="--dry-run" in sys.argv
    os.makedirs(OUT, exist_ok=True)
    state=json.load(open(STATE)) if os.path.exists(STATE) else {}
    files=sorted(p for d,_,fs in os.walk(src) for f in fs for p in [os.path.join(d,f)] if f.lower().endswith((".html",".htm")) and f.lower()!="index.html")
    if not files: print(f"No HTML entries found under {src}"); sys.exit(1)
    new=skipped=undated=0
    for p in files:
        raw=open(p, encoding="utf-8", errors="replace").read()
        t=Text(); t.feed(raw)
        body=re.sub(r"\n{3,}", "\n\n", html.unescape("".join(t.parts))).strip()
        body="\n".join(l.strip() for l in body.splitlines()).strip()
        # Apple export: header/title live in divs inside the first paragraph.
        hm=re.search(r'class=["\']pageHeader["\']>(.*?)</div>', raw, re.S)
        tm=re.search(r'class=["\']title["\']>(.*?)</div>', raw, re.S)
        if hm: t.times.append(html.unescape(hm.group(1)).strip()); body=body.replace(html.unescape(hm.group(1)).strip(),"",1).strip()
        if tm and not t.title:
            t.title=html.unescape(tm.group(1)).strip()
            if body.startswith(t.title): body=body[len(t.title):].strip()
        if not body and not t.media: continue
        h=hashlib.sha256(body.encode()).hexdigest()[:16]
        if h in state: skipped+=1; continue
        date=find_date(p, raw, t)
        if not date: undated+=1; date="undated"
        title=(t.title or "").strip()
        title="" if title.lower() in ("journal","untitled","") else title
        sec=f"\n## Apple Journal{(' - '+title) if title else ''}\n> source: apple-journal, file: {os.path.basename(p)}\n\n{body}\n"
        if t.media: sec+="\n_Media (not imported): "+", ".join(t.media)+"_\n"
        out=os.path.join(OUT, f"{date}.md")
        if body and body.rstrip()[-1:] not in ".!?)\"’”": print(f"WARNING: {os.path.basename(p)} may be truncated (ends mid-sentence)")
        if dry: print(f"[dry] {date} <- {os.path.basename(p)} ({len(body)} chars)")
        else:
            header="" if os.path.exists(out) else f"# {date}\n"
            with open(out,"a",encoding="utf-8") as f: f.write(header+sec)
            state[h]={"date":date,"file":os.path.basename(p)}
        new+=1
    if not dry: json.dump(state, open(STATE,"w"), indent=1)
    print(f"imported {new}, skipped {skipped} already-imported, undated {undated} (written to undated.md, fix by hand)")

if __name__=="__main__": main()
