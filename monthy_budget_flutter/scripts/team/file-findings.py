#!/usr/bin/env python3
"""Turn critic findings into GitHub issues, once each.

Runs ONCE per critic run, after every dimension tester has finished, because
de-duplication needs to see all findings together. Two testers looking at the
same screen from different angles routinely notice the same defect; filing them
separately would give the curator two issues describing one bug.

De-duplication is deliberately mechanical (token overlap on the title) rather
than model-driven: it must be predictable and debuggable. It errs towards
filing — a duplicate that slips through is cheap, because closing duplicates is
already part of the curator's job, whereas a real defect silently dropped here
is invisible forever.

Usage:
  file-findings.py --repo owner/name --branch main --run-id ID --run-dir DIR
                   verdict1.json [verdict2.json ...]
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

# Words that carry no distinguishing signal in this project's issue titles.
STOPWORDS = {
    "a", "o", "as", "os", "de", "da", "do", "das", "dos", "e", "em", "no", "na",
    "nos", "nas", "um", "uma", "para", "por", "com", "sem", "que", "se", "ao",
    "the", "of", "in", "on", "to", "is", "are", "and", "not", "app", "ecra",
    "ecran", "screen", "when", "quando", "nao", "está", "esta",
}

VALID_SEVERITY = {"blocker", "major", "minor"}
VALID_DIMENSIONS = {
    "functional", "layout", "design", "ux", "a11y", "i18n", "perf", "console",
    "data",
}


def tokens(text: str) -> set[str]:
    words = re.findall(r"[a-z0-9]+", (text or "").lower())
    return {w for w in words if len(w) > 2 and w not in STOPWORDS}


def similar(a: str, b: str, threshold: float = 0.6) -> bool:
    """Jaccard-ish overlap, normalised by the SHORTER title.

    Normalising by the shorter side matters: a terse existing title like
    "Totais errados no dashboard" should still match a verbose new finding that
    contains it, which plain Jaccard would miss because the union is large.
    """
    ta, tb = tokens(a), tokens(b)
    if not ta or not tb:
        return False
    overlap = len(ta & tb)
    return overlap / min(len(ta), len(tb)) >= threshold


def gh(args: list[str], check: bool = True) -> str:
    proc = subprocess.run(
        ["gh", *args], capture_output=True, text=True, timeout=120
    )
    if check and proc.returncode != 0:
        raise RuntimeError(f"gh {' '.join(args)} failed: {proc.stderr.strip()}")
    return proc.stdout.strip()


def open_issue_titles(repo: str) -> list[tuple[int, str]]:
    raw = gh([
        "issue", "list", "--repo", repo, "--state", "all", "--limit", "400",
        "--json", "number,title,state",
    ])
    try:
        data = json.loads(raw or "[]")
    except json.JSONDecodeError:
        return []
    # Closed issues are included on purpose: re-filing something that was just
    # closed as "not a defect" is worse than missing it, and the curator can
    # always reopen.
    return [(d["number"], d["title"]) for d in data]


def build_body(f: dict, dim: str, branch: str, run_id: str) -> str:
    def block(title: str, value) -> str:
        if not value:
            return ""
        if isinstance(value, list):
            body = "\n".join(f"{i}. {v}" for i, v in enumerate(value, 1))
        else:
            body = str(value)
        return f"\n## {title}\n\n{body}\n"

    parts = [
        "> Encontrado automaticamente pelo QA critic. "
        "Ainda **não foi analisado** — o curator escreve a seguir a causa raiz, "
        "o plano de correção e os critérios de aceitação.\n",
        block("O que está mal", f.get("what_is_wrong")),
        block("Como reproduzir", f.get("how_to_reproduce")),
        block("Esperado", f.get("expected")),
        block("Observado", f.get("actual")),
        block("Prova", f.get("evidence")),
        "\n---\n",
        f"- Dimensão: `{dim}`\n"
        f"- Ecrã: `{f.get('screen') or 'n/d'}`\n"
        f"- Severidade: `{f.get('severity') or 'minor'}`\n"
        f"- Confiança do tester: `{f.get('confidence') or 'medium'}`\n"
        f"- Testado em: branch `{branch}`\n"
        f"- Corrida do critic: `{run_id}`\n",
    ]
    return "".join(p for p in parts if p)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", required=True)
    ap.add_argument("--branch", default="main")
    ap.add_argument("--run-id", default="")
    ap.add_argument("--run-dir", default="")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--max-issues", type=int, default=25,
                    help="safety cap per run, so a confused tester cannot spam "
                         "the tracker with hundreds of issues")
    ap.add_argument("verdicts", nargs="+")
    args = ap.parse_args()

    # ── Collect ────────────────────────────────────────────────────────────
    findings: list[tuple[str, dict]] = []
    for path in args.verdicts:
        p = Path(path)
        if not p.is_file():
            print(f"  aviso: veredicto ausente {path}")
            continue
        try:
            data = json.loads(p.read_text())
        except json.JSONDecodeError as exc:
            print(f"  aviso: veredicto ilegível {path}: {exc}")
            continue
        dim = str(data.get("dimension") or p.stem.replace("critic-", ""))
        if dim not in VALID_DIMENSIONS:
            dim = p.stem.replace("critic-", "")
        for f in data.get("findings") or []:
            if isinstance(f, dict) and (f.get("title") or "").strip():
                findings.append((dim, f))

    print(f"findings recolhidos: {len(findings)}")
    if not findings:
        return 0

    # A blocker saying "the app never booted" invalidates everything else in
    # the run, so it must be the only thing filed — otherwise the tracker fills
    # with symptoms of one broken build.
    boot_blockers = [
        (d, f) for d, f in findings
        if f.get("severity") == "blocker"
        and re.search(r"não arranc|nao arranc|did not boot|bootedIntoApp|login",
                      f"{f.get('title','')} {f.get('what_is_wrong','')}", re.I)
    ]
    if boot_blockers:
        print("build não arrancou: a arquivar só esse blocker")
        findings = boot_blockers[:1]

    # Worst first, so the safety cap keeps what matters.
    order = {"blocker": 0, "major": 1, "minor": 2}
    findings.sort(key=lambda t: order.get(t[1].get("severity", "minor"), 3))

    existing = open_issue_titles(args.repo)
    print(f"issues existentes considerados: {len(existing)}")

    filed: list[str] = []
    skipped_dup = 0
    accepted_titles: list[str] = []

    for dim, f in findings:
        title = " ".join(str(f["title"]).split())[:240]

        dup = next((n for n, t in existing if similar(title, t)), None)
        if dup:
            print(f"  dup de #{dup}: {title[:70]}")
            skipped_dup += 1
            continue
        if any(similar(title, t) for t in accepted_titles):
            print(f"  dup dentro da corrida: {title[:70]}")
            skipped_dup += 1
            continue

        if len(filed) >= args.max_issues:
            print(f"  limite de {args.max_issues} issues atingido — "
                  f"restantes não arquivados nesta corrida")
            break

        severity = f.get("severity") if f.get("severity") in VALID_SEVERITY else "minor"
        labels = ["critic", "qa:triage", f"sev:{severity}"]
        if dim in VALID_DIMENSIONS:
            labels.append(f"dim:{dim}")

        body = build_body(f, dim, args.branch, args.run_id)

        if args.dry_run:
            print(f"  [dry-run] criaria: {title}  labels={labels}")
            accepted_titles.append(title)
            continue

        try:
            url = gh([
                "issue", "create", "--repo", args.repo,
                "--title", title, "--body", body,
                "--label", ",".join(labels),
            ])
            print(f"  criado: {url}  [{severity}/{dim}]")
            filed.append(url)
            accepted_titles.append(title)
        except Exception as exc:  # noqa: BLE001 - keep filing the rest
            print(f"  ERRO ao criar issue '{title[:60]}': {exc}")

    print(f"\nresumo: {len(filed)} issue(s) criado(s), {skipped_dup} duplicado(s) ignorado(s)")
    if args.run_dir:
        summary = Path(args.run_dir) / "filed.json"
        summary.write_text(json.dumps(
            {"filed": filed, "duplicates_skipped": skipped_dup}, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
