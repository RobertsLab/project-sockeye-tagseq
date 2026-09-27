# Supplementary tables

Supporting information for the manuscript. **Every file here is written by
`tag-seq/code/06-supplementary-tables.qmd`**; none is edited by hand.
`./render-all.sh` renders that notebook after 02, 04 and 05, whose outputs it
reads. The table legends are in the manuscript's Supporting information
section; this file defines the columns.

All files are comma-separated with a header row. Missing values are empty
fields. Logical columns are `TRUE` or `FALSE`. Fold changes are log2, and
positive values mean higher expression in territorial fish than in social
fish, the reference group.

## Table_S1_samples.csv

One row per library sequenced (60).

| Column | Meaning |
|---|---|
| `sample` | Library identifier: `B` liver, `C` gonad, then the fish number |
| `tissue` | `liver` or `gonad` |
| `phenotype` | Behavioural phenotype at capture: `territorial` or `social` |
| `included` | Whether the library was used in the analysis |
| `exclusion_reason` | Why it was excluded; empty if included |
| `library_size` | Total gene-assigned counts in the count matrix |
| `genes_detected` | Genes with at least 1 count |
| `genes_detected_10` | Genes with at least 10 counts |

Sex, maturity stage, body size and alignment rate will be added when they are
available (submission checklist A1, A2, A5).

## Table_S2_liver_differential_expression.csv, Table_S3_gonad_differential_expression.csv

One row per gene that received an adjusted p-value, sorted by adjusted p-value.

| Column | Meaning |
|---|---|
| `gene` | NCBI gene symbol for assembly GCF_006149115.2; `LOC` numbers for genes without an assigned name |
| `description` | NCBI gene description; empty for the few genes without one |
| `baseMean` | Mean of size-factor-normalised counts across samples |
| `log2FC_unshrunken`, `lfcSE_unshrunken` | Maximum-likelihood fold change and its standard error |
| `wald_stat` | Wald test statistic |
| `pvalue` | Wald test p-value |
| `padj` | Benjamini–Hochberg adjusted p-value, after independent filtering at alpha = 0.05 |
| `log2FC_apeglm`, `lfcSE_apeglm` | Fold change and standard error shrunk with apeglm; the estimates used in the main text |
| `log2FC_ashr`, `lfcSE_ashr` | Same, shrunk with ashr |
| `log2FC_normal`, `lfcSE_normal` | Same, shrunk with DESeq2's normal prior |
| `significant` | `padj < 0.05` |

Shrinkage changes fold-change estimates only; `pvalue` and `padj` are the same
whichever estimator is read.

## Table_S4_GO_enrichment.csv, Table_S5_KEGG_enrichment.csv

One row per category tested in each tissue, sorted within tissue by p-value.

| Column | Meaning |
|---|---|
| `tissue` | `liver` or `gonad` |
| `category` | GO term identifier, or KEGG pathway identifier for organism `one` |
| `term` | Term or pathway name |
| `ontology` | GO aspect: `BP` biological process, `CC` cellular component, `MF` molecular function (Table S4 only) |
| `de_genes` | Differentially expressed genes in the category |
| `category_genes` | Tested genes in the category |
| `pvalue` | One-sided hypergeometric p-value for over-representation |
| `FDR` | Benjamini–Hochberg adjusted across all categories tested in that tissue and annotation |
| `enriched` | `FDR < 0.05` |

## Table_S6_shared_genes.csv

One row per gene significant in both tissues, sorted by gonad fold change.

| Column | Meaning |
|---|---|
| `gene`, `description` | As in Tables S2 and S3 |
| `liver_log2FC`, `liver_padj` | apeglm fold change and adjusted p-value in liver |
| `gonad_log2FC`, `gonad_padj` | Same, in gonad |
| `same_direction` | Whether the fold changes have the same sign |

## Checking

`check-reproduction.R` compares these tables against their committed versions
on every render, with the same tolerances and significance-call rules as the
DESeq2 tables. They are joins of tables it already checks, but they are also
the only tracked record of the normal and ashr shrinkage estimates, whose own
tables are regenerated untracked (submission checklist D2), and they are what
readers of the paper download. Notebook 06 additionally asserts that its
source tables agree with one another before writing anything.
