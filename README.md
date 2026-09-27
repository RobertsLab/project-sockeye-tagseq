# Berdahl sockeye salmon TagSeq

Gonad and liver gene expression in adult sockeye salmon (*Oncorhynchus nerka*)
classified at capture as territorial or social, measured by 3′-tag RNA
sequencing (TagSeq). This repository holds the complete analysis, from gene
count matrices to the manuscript's numbers, figures and supplementary tables,
and re-runs it from a clean environment on every change.

## Reproducing the analysis

```bash
# First-time setup, from R in the project root:
#   renv::restore()

# Then, from the shell in the project root:
./render-all.sh
```

`./render-all.sh` is the entry point, **not** `quarto render`.
`02-differential-expression.qmd` is parameterised by tissue and defaults to
liver, so a bare `quarto render` regenerates the liver results only and leaves
the gonad results untouched. The script renders it once per tissue, then
notebooks 03–06, the landing page, the manuscript and the cover letter.

The result tables, figures and supplementary tables are tracked in git, so a
render followed by

```bash
Rscript check-reproduction.R
```

is the reproduction test. That script compares every tracked result table,
including the supplementary tables, against its committed version, ignoring
the two differences a re-render is expected to produce — image bytes, and
`apeglm` fold changes in the third decimal, since its shrinkage is an iterative
fit sensitive to the package version — and failing on any changed row, column,
or significance call at 0.05. `git diff --stat` gives the raw view.

Rendered HTML goes to `docs/`, which is gitignored; the `render` GitHub Action
publishes it to Pages on every push to `main`. That Action is the real
reproducibility test: it restores `renv.lock` on a machine that has never seen
the project, renders, and runs the check above. A green run means the analysis
still reproduces from a clean checkout. It also uploads the rendered manuscript
and cover letter as the `manuscript` artifact.

The upstream steps (alignment and assembly) are documented in
`tag-seq/code/01-upstream-alignment.qmd` with `eval: false` — they are meant to
run on Raven with access to Gannet storage, not on a laptop.

Input integrity is recorded in `CHECKSUMS.sha256` and checked at the start of
every render (a mismatch warns, it does not stop). Verify by hand with
`shasum -c CHECKSUMS.sha256`.

### What each notebook does

| Notebook | Reads | Writes |
|---|---|---|
| `01-upstream-alignment.qmd` | FASTQs on Gannet | count matrices (on Raven; `eval: false` here) |
| `02-differential-expression.qmd` | `tag-seq/data/` | `tag-seq/DESEQ_output/<tissue>/` |
| `03-gene-tables.qmd` | `*-SIG-DEG-apeglm.csv` | `tag-seq/gene_tables/` |
| `04-enrichment.qmd` | `*-ALL-DEG-apeglm.csv`, GAF, KEGG | `tag-seq/GO_output/<tissue>/` |
| `05-figures.qmd` | count matrices, `*-apeglm.csv`, enrichment tables | `figures/` |
| `06-supplementary-tables.qmd` | count matrices, all DE and enrichment tables | `manuscript/supplementary/` |

## Directory map

| Directory | What it holds | Written by | Read by |
|---|---|---|---|
| `tag-seq/data/` | Gene count matrices and phenotype tables, the analysis inputs | counts: upstream pipeline (01, on Raven); phenotypes: by hand | 02, 05, 06, manuscript |
| `tag-seq/genome/` | NCBI feature table, GO annotation and KEGG maps for assembly GCF_006149115.2 | downloaded; retrieval recorded | 02, 04, 05, manuscript |
| `tag-seq/sequences/` | Genome sequence lengths for the upstream pipeline | 01 | 01 |
| `tag-seq/code/` | The notebooks 01–06 and their shared helpers, `_common.R` | — | `render-all.sh` |
| `tag-seq/DESEQ_output/` | Differential-expression tables and diagnostic plots per tissue; `alternatives/` inside each is regenerated and untracked | 02 | 03–06, manuscript, cover letter |
| `tag-seq/gene_tables/` | Significant genes split by annotation status | 03 | — |
| `tag-seq/GO_output/` | GO and KEGG over-representation results per tissue | 04 | 05, 06, manuscript |
| `tag-seq/QC/` | Gonad read-quality reports copied from Gannet, and what QC evidence is missing | copied by hand; see its README | — |
| `figures/` | Manuscript Figures 1–3 (PDF and PNG) and their source data | 05 | manuscript |
| `manuscript/` | Manuscript and cover letter sources, citation style, Word template, bibliography | by hand | `render-all.sh` |
| `manuscript/supplementary/` | Supplementary Tables S1–S6 and their column dictionary | 06 | manuscript |
| `archive/` | Superseded material kept for reference: the original upstream shell transcript and the 2023 DAVID output | — | nothing |
| `renv/` | The environment bootstrap for `renv.lock` | renv | R at start-up |

Each data directory has a README saying what every file is and which notebook
reads it.

## Data

Raw reads (FASTQ) and the gonad FastQC and MultiQC reports are on Gannet:
<https://gannet.fish.washington.edu/panopea/berdahl-sockeye-salmon/>. They do not
yet have an archival accession (see `SUBMISSION-CHECKLIST.md`, A3).

## Further documents

- `REPRODUCIBILITY-PLAN.md` — the audit of the original analysis, what was
  changed and why, and the notes moved out of the notebooks.
- `SUBMISSION-CHECKLIST.md` — what still stands between this repository and a
  *Molecular Ecology* submission.
- `NOTES.md` — lab logistics: sample shipping, the sequencing quote and
  manifests, related lab-notebook issues and working documents.
