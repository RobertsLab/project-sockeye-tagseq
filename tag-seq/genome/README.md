# tag-seq/genome

Annotation resources for *Oncorhynchus nerka* assembly
[GCF_006149115.2 (Oner_1.1)](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_006149115.2/).
Written to close finding E11.

| File | Size | Role | Read by |
|---|---|---|---|
| `GCF_006149115.2_Oner_1.1_feature_table.txt` | 34 MB | **input** — gene symbols, descriptions, GeneIDs and mRNA intervals; source of both the annotation join and goseq's gene lengths | `04` via `load_gene_annotation()` |
| `GCF_006149115.2_Oner_1.1_gene_ontology.gaf.gz` | 1.5 MB | **input** — NCBI GO annotation: 155,362 annotations over 32,629 genes and 6,937 terms | `04` |
| `kegg_one_gene2pathway.tsv` | 859 KB | **input** — KEGG gene-to-pathway map, organism `one` | `04` |
| `kegg_one_pathways.tsv` | 14 KB | **input** — KEGG pathway names | `04` |
| `kegg_one_SOURCE.txt` | 323 B | provenance — REST URLs and retrieval date for the two files above | humans |

All four input files are checksummed in `CHECKSUMS.sha256` and verified at the
start of every render.

## Removed: Onerka_LOCID_gene_table.txt

The pre-2026 annotation table, removed from the tree on 2026-09-27 (submission
checklist D3). No notebook read it.

It is keyed entirely by LOC identifiers, so it can never annotate a
symbol-named gene, which is what produced the fabricated `LOCNA.*` identifiers
of finding R8. The feature table above replaces it and is a strict superset,
re-verified before removal: all 33,211 genes in the LOC table are in the
feature table, and every one of their descriptions matches one of that gene's
mRNA names there. The only differences are CSV quoting and which transcript
variant's name was taken (", transcript variant X1" against "X2").

Two copies remain:

| Copy | sha256 |
|---|---|
| [commit-pinned, as tracked here](https://raw.githubusercontent.com/RobertsLab/project-sockeye-tagseq/97e1a1eafdef1e241aad325a3f4626cf30bf4f83/tag-seq/genome/Onerka_LOCID_gene_table.txt) | `931450449975391ce6135c0e06ed5d146ed783447769c2e35dae17fe21f5dd32` |
| [Gannet](https://gannet.fish.washington.edu/panopea/berdahl-sockeye-salmon/genome/Onerka_LOCID_gene_table.txt) | `e60dbd4b9dbc3c0e06bfad3e71fe416ac2020ea9acb44236f39f8458953ffea5` |

The Gannet copy has Windows (CRLF) line endings and is otherwise identical;
that is the only reason the checksums differ.
