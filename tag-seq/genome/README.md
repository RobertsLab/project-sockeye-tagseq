# tag-seq/genome

Annotation resources for *Oncorhynchus nerka* assembly
[GCF_006149115.2 (Oner_1.1)](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_006149115.2/).

| File | Size | Role | Read by |
|---|---|---|---|
| `GCF_006149115.2_Oner_1.1_feature_table.txt` | 34 MB | **input** — gene symbols, descriptions, GeneIDs and mRNA intervals; source of both the annotation join and goseq's gene lengths | `02`, `04`, `05` and the manuscript, via `load_gene_annotation()` |
| `GCF_006149115.2_Oner_1.1_gene_ontology.gaf.gz` | 1.5 MB | **input** — NCBI GO annotation: 155,362 annotations over 32,629 genes and 6,937 terms | `04` |
| `kegg_one_SOURCE.txt` | 1 KB | provenance — the KEGG REST URLs, and the KEGG release and sha256 of the responses the committed results were computed from | `ensure_kegg()` |

The feature table and the GO annotation are checksummed in `CHECKSUMS.sha256`
and verified at the start of every render.

**KEGG pathway data are not in the repository.** KEGG's terms do not allow its
data to be redistributed, so `ensure_kegg()` in `tag-seq/code/_common.R`
downloads `kegg_one_gene2pathway.tsv` and `kegg_one_pathways.tsv` into this
directory on first use (git ignores them) and writes `kegg_one_RETRIEVED.txt`
with the date and KEGG release. They are reused while they exist; set
`KEGG_REFRESH=1` to download afresh. Notebook 04 and the manuscript read them.

The LOC-keyed annotation table used before 2026 is no longer in the tree; it
is superseded by the feature table. Where copies are, and how the two were
compared, is recorded in `REPRODUCIBILITY-PLAN.md`.
