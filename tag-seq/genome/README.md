# tag-seq/genome

Annotation resources for *Oncorhynchus nerka* assembly
[GCF_006149115.2 (Oner_1.1)](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_006149115.2/).

| File | Size | Role | Read by |
|---|---|---|---|
| `GCF_006149115.2_Oner_1.1_feature_table.txt` | 34 MB | **input** — gene symbols, descriptions, GeneIDs and mRNA intervals; source of both the annotation join and goseq's gene lengths | `02`, `04`, `05` and the manuscript, via `load_gene_annotation()` |
| `GCF_006149115.2_Oner_1.1_gene_ontology.gaf.gz` | 1.5 MB | **input** — NCBI GO annotation: 155,362 annotations over 32,629 genes and 6,937 terms | `04` |
| `kegg_one_gene2pathway.tsv` | 859 KB | **input** — KEGG gene-to-pathway map, organism `one` | `04` |
| `kegg_one_pathways.tsv` | 14 KB | **input** — KEGG pathway names | `04` |
| `kegg_one_SOURCE.txt` | 323 B | provenance — REST URLs and retrieval date for the two files above | humans |

All four input files are checksummed in `CHECKSUMS.sha256` and verified at the
start of every render.

The LOC-keyed annotation table used before 2026 is no longer in the tree; it
is superseded by the feature table. Where copies are, and how the two were
compared, is recorded in `REPRODUCIBILITY-PLAN.md`.
