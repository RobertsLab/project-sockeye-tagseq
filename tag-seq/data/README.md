# tag-seq/data

What each tracked file is, and which notebook reads it. Written to close finding
E11: 39 MB of this repository was tracked input that no current notebook reads,
with nothing to say whether it was still needed.

| File | Size | Role | Read by |
|---|---|---|---|
| `onerka_gene_count_matrix-gonad.csv` | 4.0 MB | **input** — gene-level counts, 37,942 genes x 30 samples, from `prepDE.py` | `02` via `load_counts()` |
| `onerka_gene_count_matrix-liver.csv` | 3.7 MB | **input** — same, liver | `02` via `load_counts()` |
| `treatments-gonad.csv` | 605 B | **input** — sample to behavioural phenotype map (column `phenotype`), 15 territorial / 15 social | `02` via `load_counts()` |
| `treatments-liver.csv` | 605 B | **input** — same, liver | `02` via `load_counts()` |

The four input files are checksummed in `CHECKSUMS.sha256` and verified at the
start of every render.

## Moved out of the tree: the three provenance-only files

Three files that no notebook reads were tracked here until 2026-09-27
(submission checklist D3). They are the only record of what the upstream
pipeline produced besides the gene-level matrices above, so they were not
deleted: they were removed from the working tree and remain in the
repository's history, retrievable byte-for-byte from these commit-pinned
addresses.

| File | Size | sha256 | What it is |
|---|---|---|---|
| [`transcript_count_matrix-gonad.csv`](https://raw.githubusercontent.com/RobertsLab/project-sockeye-tagseq/97e1a1eafdef1e241aad325a3f4626cf30bf4f83/tag-seq/data/transcript_count_matrix-gonad.csv) | 6.4 MB | `fd46859a15f8112b46d30038ddbcb0d0c34f0d35ca2052ac6ec38646a006cb60` | transcript-level counts from the same `prepDE.py` run as the gonad gene matrix |
| [`transcript_count_matrix-liver.csv`](https://raw.githubusercontent.com/RobertsLab/project-sockeye-tagseq/97e1a1eafdef1e241aad325a3f4626cf30bf4f83/tag-seq/data/transcript_count_matrix-liver.csv) | 5.9 MB | `08a7b42360c1d1a07c0abf47bba0005dcdb26d231bd9695ce3112732e023283a` | same, liver |
| [`onerka_merged-liver.gtf`](https://raw.githubusercontent.com/RobertsLab/project-sockeye-tagseq/97e1a1eafdef1e241aad325a3f4626cf30bf4f83/tag-seq/data/onerka_merged-liver.gtf) | 21.5 MB | `cbcb5d67d3b642922e519ba1e6eb00cd40f3a3ea82046537a332fb79c322ddd9` | StringTie merged annotation the liver matrices were counted against; there is no gonad counterpart |

Each address was downloaded and checked against the sha256 above before the
files were removed. To restore one in place:

```bash
git checkout 97e1a1eafdef1e241aad325a3f4626cf30bf4f83 -- tag-seq/data/transcript_count_matrix-gonad.csv
```

**Still to do:** these are processed data, and belong with the raw reads in the
public deposit (checklist A3). A GEO submission takes count matrices alongside
FASTQs; the Gannet folder that holds the FASTQs
(<https://gannet.fish.washington.edu/panopea/berdahl-sockeye-salmon/>) does not
hold these files. When they are deposited, add the accession to this table.
