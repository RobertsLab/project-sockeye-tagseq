# Berdahl-sockeye-salmon

## Reproducibility

This repository has been rebuilt as a fully reproducible Quarto project (phases 0-4, see 
`REPRODUCIBILITY-PLAN.md`). To render the analysis:

```bash
# First-time setup: restore R environment
renv::restore()

# Render the analysis (R and downstream steps only; upstream FASTQ processing requires Raven)
quarto render
```

The upstream steps (alignment and assembly) are documented in `tag-seq/code/01-upstream-alignment.qmd` 
with `eval: false` — they are meant to run on Raven with access to Gannet storage, not on a laptop.

For more details, see `REPRODUCIBILITY-PLAN.md`.

---

### Locations
1. [Gannet folder](https://gannet.fish.washington.edu/panopea/berdahl-sockeye-salmon/)
2. [Manuscript](https://docs.google.com/document/d/19xcEKJfSdz6b7KGZAEr76w9NrCF5RPQ99FFtRt-G-wI/edit?usp=sharing)

### Github issues:
1. [Sam's initial experiments w/ RNA extraction](https://github.com/RobertsLab/resources/issues/1307)
2. [Matt & Sam - issues with RNA extractions](https://github.com/RobertsLab/resources/issues/1410)
3. [GSAF sequencing results](https://github.com/RobertsLab/resources/issues/1501)

### Sequencing:
1. Salmon samples shipped to UT Austin GSAF on 5/24. Received 5/25. Assigned Job number JA22192.
2. Sample list and plate map available [here](https://www.dropbox.com/s/snq453edfxeor6t/Berdahl_sockeye_salmon.xlsx?dl=0)
3. Quote available [here](https://www.dropbox.com/s/znk1cikjtrj9v6n/GSAF_Quote_Job_JA22192_2022-05-09.pdf?dl=0)
4. GSAF sample manifest available [here](https://www.dropbox.com/s/9yuso7jhkazikrt/GSAF%20Sample%20Manifest_Job%23JA22192_2022-05-12.pdf?dl=0)

### Pertinent Documents
1. Sample attributes [list](https://docs.google.com/spreadsheets/d/1HVCK9HVTzWEkBT5vnbK97zJvnE4Amco5NPkmf_W9yVw/edit?usp=sharing)
