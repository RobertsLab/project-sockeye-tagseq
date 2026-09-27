# figures

The manuscript figures. **Every file here is written by
`tag-seq/code/05-figures.qmd`**; none is edited by hand. `./render-all.sh`
renders that notebook after notebooks 02 and 04, whose tables it reads.

| File | What it shows |
|---|---|
| `fig1-overview.{pdf,png}` | Liver and gonad: PCA, volcano plots, heatmaps of the differentially expressed genes |
| `fig2-enrichment.{pdf,png}` | Gonad KEGG pathways and GO terms at FDR < 0.05 |
| `fig3-genes.{pdf,png}` | Normalised counts for the genes named in the text; liver vs gonad fold changes for genes significant in both |
| `source-data/pca-variance.csv` | Variance explained by PC1–PC5 per tissue; the manuscript reads its PCA percentages from here |
| `source-data/pca-scores.csv` | Sample scores on PC1–PC5, as plotted in Figure 1 A and D |
| `source-data/shared-genes.csv` | Liver and gonad fold changes for the genes in Figure 3 B |

The PDFs are vector files for submission; the heatmaps inside them are embedded
rasters, which keeps them small. The PNGs are 300 dpi and are what the
manuscript's HTML and Word renders embed. Both are sized for a 170 mm
double-column width with 7 pt text.

Colours are validated for colour-vision deficiency rather than chosen by eye;
the values and the validation results are recorded next to `TRT_COLOURS` and
`DIVERGING` in `tag-seq/code/_common.R`. Treatment is always shown by shape as
well as colour.

These files are tracked so the manuscript renders without re-running the
analysis. `check-reproduction.R` does not compare them: images differ in bytes
on every render, and the source-data tables are derived from the result tables
it already checks.

## History

This directory used to hold `figure_X.png`, exported from a hand-assembled
PowerPoint file (`figure_X.pptx`) that no script produced (finding E11). After
the independent-filtering fix of 2026-09-26 its heatmap panels showed gene sets
that no longer matched the results. Both files were removed when notebook 05
replaced them; they remain in the git history.
