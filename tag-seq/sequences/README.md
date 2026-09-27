# tag-seq/sequences

Derived genome tracks for the upstream (FASTQ to count matrix) half of the
pipeline, which runs on Raven. Nothing here is read by notebooks 02-06.

| File | Size | Role |
|---|---|---|
| `GCF_006149115.2_Oner_1.1_genomic-sequence-lengths.txt` | 556 KB | `bedtools -faidx` input for the mRNA feature track step in `01-upstream-alignment.qmd` |

## Not tracked: GCF_006149115.2_Oner_1.1_mRNA.gff

The mRNA feature track StringTie takes as `-G` is a derived intermediate. The
"Generate mRNA feature track" chunk of `01-upstream-alignment.qmd` writes it on
Raven from the genomic GFF. Nothing downstream needs it: goseq's gene lengths
come from `genome/GCF_006149115.2_Oner_1.1_feature_table.txt`.
