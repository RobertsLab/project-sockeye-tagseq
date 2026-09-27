# tag-seq/data

The analysis inputs: what each file is, and which notebook reads it.

| File | Size | Role | Read by |
|---|---|---|---|
| `onerka_gene_count_matrix-gonad.csv` | 4.0 MB | **input** — gene-level counts, 37,942 genes x 30 samples, from `prepDE.py` | `02` via `load_counts()` |
| `onerka_gene_count_matrix-liver.csv` | 3.7 MB | **input** — same, liver | `02` via `load_counts()` |
| `treatments-gonad.csv` | 605 B | **input** — sample to behavioural phenotype map (column `phenotype`), 15 territorial / 15 social | `02` via `load_counts()` |
| `treatments-liver.csv` | 605 B | **input** — same, liver | `02` via `load_counts()` |

The four input files are checksummed in `CHECKSUMS.sha256` and verified at the
start of every render.

## Other upstream outputs, kept outside the working tree

Three further outputs of the upstream pipeline are not read by any notebook
and are not in the working tree. They are in the repository's history,
retrievable byte for byte from these commit-pinned addresses.

| File | Size | sha256 | What it is |
|---|---|---|---|
| [`transcript_count_matrix-gonad.csv`](https://raw.githubusercontent.com/RobertsLab/project-sockeye-tagseq/97e1a1eafdef1e241aad325a3f4626cf30bf4f83/tag-seq/data/transcript_count_matrix-gonad.csv) | 6.4 MB | `fd46859a15f8112b46d30038ddbcb0d0c34f0d35ca2052ac6ec38646a006cb60` | transcript-level counts from the same `prepDE.py` run as the gonad gene matrix |
| [`transcript_count_matrix-liver.csv`](https://raw.githubusercontent.com/RobertsLab/project-sockeye-tagseq/97e1a1eafdef1e241aad325a3f4626cf30bf4f83/tag-seq/data/transcript_count_matrix-liver.csv) | 5.9 MB | `08a7b42360c1d1a07c0abf47bba0005dcdb26d231bd9695ce3112732e023283a` | same, liver |
| [`onerka_merged-liver.gtf`](https://raw.githubusercontent.com/RobertsLab/project-sockeye-tagseq/97e1a1eafdef1e241aad325a3f4626cf30bf4f83/tag-seq/data/onerka_merged-liver.gtf) | 21.5 MB | `cbcb5d67d3b642922e519ba1e6eb00cd40f3a3ea82046537a332fb79c322ddd9` | StringTie merged annotation the liver matrices were counted against; there is no gonad counterpart |

Each address has been checked against the sha256 above. To restore one in
place:

```bash
git checkout 97e1a1eafdef1e241aad325a3f4626cf30bf4f83 -- tag-seq/data/transcript_count_matrix-gonad.csv
```

These are processed data and belong with the raw reads in the public deposit
(submission checklist A3); the Gannet folder that holds the FASTQs
(<https://gannet.fish.washington.edu/panopea/berdahl-sockeye-salmon/>) does not
hold them. When they are deposited, add the accession to this table.
