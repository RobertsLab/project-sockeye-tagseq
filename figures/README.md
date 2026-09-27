# figures

**Manuscript-only. Not produced by any script in this repository** (finding E11).

| File | Size | Provenance |
|---|---|---|
| `figure_X.png` | 846 KB | exported from `figure_X.pptx` |
| `figure_X.pptx` | 1.5 MB | hand-assembled; no producing code |

Every figure the analysis generates is written by the notebooks into
`tag-seq/DESEQ_output/<tissue>/` (PCA, heatmaps, volcano and MA plots) or
`tag-seq/GO_output/<tissue>/`. This directory is a hand-built manuscript
composite, and the `.pptx` is its only source.

**Open decision:** if any panel of `figure_X` is a rendered result, regenerate
that panel from a notebook chunk so it tracks the data. Otherwise this note is
the resolution — it is a figure, not a result, and the repository does not claim
to reproduce it.

**Stale since 2026-09-26.** The independent-filtering fix (see
`REPRODUCIBILITY-PLAN.md`, "One significance convention") changed the number of
significant genes from 31 to 66 in liver and from 1,630 to 1,653 in gonad.
Panels C and F of `figure_X` are heatmaps of those genes and still show the old
sets and the old `n`; the volcano panels B and E are drawn from the same tables.
The manuscript caption carries a placeholder saying so. Regenerate the figure
from a notebook (submission checklist C2 and D6) rather than re-exporting the
`.pptx`.
