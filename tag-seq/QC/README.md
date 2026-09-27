# tag-seq/QC

Read-quality evidence for the sequencing. Nothing here is read by the analysis
notebooks; it is the record a reader would check the libraries against.

## What is here

The gonad MultiQC reports and their data tables, copied on 2026-09-27 from the
project folder on Gannet, where they were produced in 2022:

| File | What it is | sha256 |
|---|---|---|
| [`multiqc_gonad/multiqc_report_untrimmed.html`](https://gannet.fish.washington.edu/panopea/berdahl-sockeye-salmon/multiqc_report.html) | FastQC on the untrimmed gonad reads, 30 libraries x 2 lanes; MultiQC v1.12, 2022-07-29 | `16e98d6e9d22a7b7…` |
| [`multiqc_gonad/multiqc_report_trimmed.html`](https://gannet.fish.washington.edu/panopea/berdahl-sockeye-salmon/multiqc_report_trimmed.html) | FastQC on the trimmed gonad reads, 30 libraries, lanes merged; 2022-08-08 | `1639104c231c7426…` |
| [`multiqc_gonad/multiqc_data/multiqc_general_stats.txt`](https://gannet.fish.washington.edu/panopea/berdahl-sockeye-salmon/multiqc_data/multiqc_general_stats.txt) | per-lane totals, duplication, GC and read length behind the untrimmed report | `76f753a21b8f8f4f…` |
| [`multiqc_gonad/multiqc_data/multiqc_fastqc.txt`](https://gannet.fish.washington.edu/panopea/berdahl-sockeye-salmon/multiqc_data/multiqc_fastqc.txt) | per-lane FastQC module results, same report | `e85b3d5ecbc5fdb6…` |
| [`multiqc_gonad/multiqc_data/multiqc_sources.txt`](https://gannet.fish.washington.edu/panopea/berdahl-sockeye-salmon/multiqc_data/multiqc_sources.txt) | the FastQC files MultiQC read, with their paths on Raven | `c10d844553b120df…` |
| [`multiqc_gonad/multiqc_data/multiqc_citations.txt`](https://gannet.fish.washington.edu/panopea/berdahl-sockeye-salmon/multiqc_data/multiqc_citations.txt) | citation MultiQC asks for | `01b7abc926d9e75a…` |

Both reports summarise FastQC only. The per-library FastQC pages are on Gannet,
not here: <https://gannet.fish.washington.edu/panopea/berdahl-sockeye-salmon/fastqc_reports/>.

Read from `multiqc_general_stats.txt`: the gonad reads are 101 bp, read 1 only,
from two sequencing lanes, with 5.49–12.09 million raw reads per library for
the 28 libraries analysed (median 7.53 million). The two excluded libraries
have 6.00 million (C05) and 4.12 million (C17).

## What is not here

- **Liver read QC.** No FastQC or MultiQC output for the liver libraries has
  been found; the Gannet folder holds only the gonad reports.
- **Alignment logs.** Notebook 01 names them `hisat2_alignment_{gonad,liver}.txt`,
  written in the project root on Raven. Neither is in this repository or in the
  Gannet folder, so per-sample alignment rates cannot be shown (submission
  checklist B3).
- **The sample-correlation evidence for excluding C05 and C17.** The exclusion
  was recorded as based on a MultiQC sample-correlation heatmap. Neither report
  here contains one: both are FastQC-only. What the repository can show is
  that C05 and C17 are the two smallest gonad libraries by gene-assigned
  counts (Supplementary Table S1). See submission checklist A5.

## Alignment rates, unverified

The manuscript's methods state mean overall HISAT2 alignment rates of 88.7%
(SD 2.2) for gonad and 86.5% (SD 0.8) for liver. They were recorded in this
directory in 2026 as "extracted from alignment logs on Raven", but those logs
are not available, and the record gave n = 15 per tissue where 30 libraries of
each were sequenced. Treat the figures as unverified until the logs are found
and a per-sample table is committed here.
