# Submission checklist — Molecular Ecology

What stands between the current state of this repository and a manuscript that
can be submitted to *Molecular Ecology*. Written 2026-09-26 from a review of the
code, the committed result tables, the CI history, the Quarto draft at
`manuscript/manuscript.qmd`, and the linked Google Doc (which contains only a
skeleton methods section and no site, behaviour, or discussion text).

Tick items off here as they close, and record where the evidence landed. The
companion document `REPRODUCIBILITY-PLAN.md` covers the analysis audit; this
one covers only what the journal and its reviewers will need.

**Baseline on 2026-09-26.** The render workflow is green on `main` (last run
2026-09-07, restoring `renv.lock` on a clean runner and reproducing every
DESeq2 table and significance call). The draft is ~3,900 words of body text
with numbers computed from the result tables at render time, 37 references,
one composite figure and four tables. The manuscript is *not* rendered by CI.

---

## A. Blocking — cannot submit without these

### A1. Sex of the fish, and whether it confounds phenotype

- [ ] Obtain sex and maturity stage for all 30 fish from the dissection
      records (the sample-attributes sheet linked in `README.md`, if it holds
      them; it could not be opened during this review).
- [ ] Reconcile with the marker-gene evidence. The draft states all gonads
      were ovarian, but no notebook computes the marker values it quotes
      (112–410 CPM for *foxl2*), and `amh` — a testis marker — is itself
      differentially expressed (log2FC −0.90, padj 0.032, baseMean 87) in
      `tag-seq/DESEQ_output/gonad/gonad-ALL-DEG-apeglm.csv`. Either put the
      marker-gene check into notebook 02 (or a new notebook) so the numbers are
      computed, or remove the inference and rely on the records.
- [ ] If sexes are mixed across phenotypes, re-fit the gonad model with sex as
      a covariate (`~ sex + phenotype`) and re-derive every downstream table. This
      could change the central result.
- [ ] If maturity stage or gonadosomatic index was recorded, test it as a
      covariate. The Discussion already concedes that territorial fish may
      simply be closer to spawning; reviewers will treat that as the default
      alternative explanation unless it is tested.

### A2. Field methods (only the Berdahl group can supply these)

- [ ] Collection site(s), water body, dates.
- [ ] Behavioural classification: the criteria that made a fish *territorial*
      or *social*, who scored it, observation duration, whether scoring
      preceded capture, and how the 15 + 15 were chosen from the fish
      observed.
- [ ] Capture and euthanasia method; time from capture to tissue preservation.
- [ ] Body length and mass per fish (supplementary table).
- [ ] Permits and animal-care approval (IACUC protocol number, collection
      permit numbers).
- [ ] Why brain and blood were not sequenced (draft says brain RNA yields were
      insufficient — confirm).

### A3. Raw data deposit

- [ ] Register a BioProject and BioSamples (30 fish, two tissues each).
- [ ] Deposit all 60 FASTQ files in SRA. Consider GEO instead, which takes the
      count matrices alongside the reads and issues one accession for both.
- [ ] Record accessions in `index.qmd`, `manuscript.qmd` (Data and code
      availability), and `README.md`.
- [ ] Reviewers must be able to reach the data at submission; keep the Gannet
      URL as a secondary location until the accession is public.

### A4. Code archive with a DOI

- [x] Add `LICENSE` (the repository currently has none; GitHub reports
      `license: None`). *(Done 2026-09-27, see D7.)*
- [ ] Add `CITATION.cff` with the author list and, once minted, the Zenodo DOI.
      *(File added and schema-valid 2026-09-27; the author list is incomplete
      and the DOI does not exist yet. Zenodo's GitHub integration reads this
      file for the release metadata, so complete the authors first.)*
- [x] Decide on the 33 MB of provenance-only files listed as an open decision
      in `tag-seq/data/README.md`, and on `Onerka_LOCID_gene_table.txt`
      (`tag-seq/genome/README.md`), before the archive is cut. *(Done in D3.)*
- [ ] Decide whether the vendored KEGG files
      (`tag-seq/genome/kegg_one_*.tsv`) may be redistributed. KEGG states it
      is not a public database, provides its API for academic use by academic
      users, and requires a licence for other use; the LICENSE therefore
      excludes them from every open licence. If redistribution is not
      acceptable, remove them from the repository and the archive and have
      notebook 04 fetch them at render time, recording the retrieval date.
- [ ] Tag a release and mint a Zenodo DOI. GitHub alone is not an acceptable
      archive for *Molecular Ecology*.

### A5. The C05 / C17 exclusion (audit findings R5, E9)

- [ ] Commit the MultiQC reports for both tissues into
      `tag-seq/QC/multiqc_gonad/` and `tag-seq/QC/multiqc_liver/` (currently
      placeholders), **or** compute the outlier criterion inside notebook 02
      (e.g. sample-correlation or PCA distance with a stated threshold) so the
      exclusion is derived rather than hardcoded in `tag-seq/code/_common.R`.
      *(Partly: the gonad MultiQC reports are now in `tag-seq/QC/multiqc_gonad/`,
      but they are FastQC-only and are not the correlation evidence. No liver
      QC has been found.)*
- [ ] Fix `tag-seq/QC/ALIGNMENT_SUMMARY.md`: it reports n=15 per tissue for
      matrices with 30 columns, and cites logs that are not in the repository.
      Commit per-sample alignment rates and library sizes as a supplementary
      table. *(The summary is replaced by `tag-seq/QC/README.md`, which marks
      the alignment rates unverified, and the manuscript now flags them with a
      placeholder. Library sizes are in Table S1. Per-sample alignment rates
      need the HISAT2 logs, `hisat2_alignment_{gonad,liver}.txt` on Raven.)*

Evidence found 2026-09-27 while building Table S1: C05 and C17 are the two
smallest gonad libraries, 1.97 and 2.14 million gene-assigned counts against
3.39–5.77 million for the other 28. That is a computable criterion the
exclusion could be stated in, and the manuscript now reports it as an
observation. It does not replace the MultiQC evidence the original decision
cited; either commit that, or adopt a library-size rule in notebook 02 and say
so.

Found 2026-09-27 on Gannet (`panopea/berdahl-sockeye-salmon/multiqc_report.html`
and `multiqc_data/`, July 2022): a FastQC-only MultiQC report on the untrimmed
gonad reads. It has no sample-correlation heatmap, so it is not the evidence
the exclusion was based on. Its raw read totals (both lanes) also show that
raw depth alone does not separate the excluded libraries: C17 is the lowest
(4.12 M reads) but C05 (6.00 M) has more than the retained C01 (5.49 M; the
other 28 range 5.49–12.09 M). C05 stands out only in gene-assigned counts,
which points to a lower assignment rate rather than shallow sequencing; a
library-size rule should say it is on gene-assigned counts.

### A6. Sequencing details

- [ ] Instrument, read length and run type (single-end assumed) from the GSAF
      job documents (JA22192 gonad, JA22330 liver; Dropbox links in
      `README.md`). Replace the placeholder in `manuscript.qmd`. *Partly
      known: the Gannet MultiQC report shows the gonad reads are 101 bp, R1
      only, from two lanes; liver is still unconfirmed.*
- [ ] Cutadapt, FastQC and MultiQC versions (notebook 01 lists the tools but
      not every version).

### A7. Front and back matter

- [ ] Author list, affiliations, corresponding author, ORCID for the
      corresponding author (required) and ideally all authors.
- [ ] Author contributions (CRediT).
- [ ] Funding and acknowledgements.
- [ ] Data Accessibility and Benefit-Sharing Statement in the journal's
      required form (data locations with accessions, code DOI, and the
      benefit-sharing sentence, which depends on where the fish were
      collected).
- [ ] Conflict of interest statement.

### A8. Length limits

- [ ] Abstract is 273 words; the limit is 250.
- [ ] Keywords: eight listed; reduce to six.

---

## B. Analysis changes to make before the numbers are frozen

### B1. Independent-filtering mismatch between unshrunken and shrunken tables

In `tag-seq/code/02-differential-expression.qmd` (chunk `contrasts`) the
unshrunken results are computed with `alpha = 0.05`, but the three
`lfcShrink()` calls omit `res =`, so they call `results()` internally with the
default `alpha = 0.1` and carry that padj. This is why the draft has a
Limitations paragraph explaining 66 versus 31 liver genes and 1,653 versus
1,630 gonad genes.

- [x] Pass the alpha-0.05 results object into each shrinkage call:
      `lfcShrink(dds, coef = 2, res = res_table, type = "apeglm")` (and the
      same for `normal` and `ashr`).
- [x] Re-render with `./render-all.sh`, review the diff in significant-gene
      counts, and commit the new baseline so `check-reproduction.R` passes.
- [x] Update every number in `index.qmd` that is typed rather than computed
      (the results tables there are hand-written), and delete the Limitations
      paragraph about the two conventions from `manuscript.qmd`.

Done 2026-09-26: liver 66 and gonad 1,653 significant genes, 5 KEGG and 36
GO terms enriched in gonad. Before/after detail in `REPRODUCIBILITY-PLAN.md`,
"One significance convention". `figures/figure_X` still shows the old counts
(C2).

### B2. Marker-gene and covariate work from A1

- [ ] Whatever A1 decides, the computation lives in a notebook and the
      manuscript reads its output. No hand-transcribed CPM values.

### B3. Questions salmonid reviewers will ask

- [ ] How multi-mapping reads were handled by HISAT2 given the salmonid
      whole-genome duplication (the two serum amyloid A-5 paralogues,
      `LOC115112426` and `LOC115112427`, are the headline result). State the
      HISAT2 `-k` setting and whether secondary alignments were counted by
      `prepDE.py`.
- [ ] Confirm nothing was lost in the RefSeq feature-table join (11 of 5,646
      liver and 12 of 18,935 gonad rows lack a description — say so).
- [ ] Per-sample sequencing depth, alignment rate and genes detected, as a
      supplementary table.

### B4. The pinned CRAN snapshot cannot restore the lockfile

Found while re-rendering for B1. `.Rprofile` pins CRAN to the 2024-04-24
Posit Package Manager snapshot, but `renv.lock` records many packages from a
2025-05-18 snapshot, and `nlme` 3.1-166 exists only in the later one. A restore
from the pinned snapshot alone fails; CI passes only because its runner adds
"latest" Package Manager as a fallback.

- [x] Either move the `.Rprofile` pin to 2025-05-18 or re-snapshot the
      lockfile against 2024-04-24, then confirm `renv::restore()` succeeds
      with no other repository configured.

Done 2026-09-27: pin moved to 2025-05-18 in both `.Rprofile` and `renv.lock`
(no version changed), CI's fallback repository removed, and a clean restore
with an empty cache installed all 184 locked versions. Detail in
`REPRODUCIBILITY-PLAN.md`, "The pinned snapshot now restores the lockfile".

---

## C. Manuscript revisions for this journal

### C1. Framing

*Molecular Ecology* publishes work that uses molecular tools to answer
questions in ecology, evolution and behaviour. The draft reads as a gene
inventory in places.

- [ ] Introduction: state explicit hypotheses with tissue-specific predictions
      (e.g. reproductive-investment hypothesis predicts gonadal translation
      and energy-metabolism differences; cost-of-aggression hypothesis
      predicts hepatic and gonadal stress/immune induction). Say which one the
      data favour.
- [ ] Discussion: cut gene-by-gene narration to the two gonadal programmes
      (biosynthetic/energetic; acute-phase), the vasotocin finding, the
      *amh* finding once A1 is resolved, and the maturation-stage confound.
- [ ] Move most of the Wallenius-versus-hypergeometric section to a short
      methods paragraph plus a supplementary note with the length-decile
      figure from notebook 04. It is a genuine methodological contribution
      for 3′-tag data but is currently a page of the Discussion.
- [ ] Verify the methods text against the lab notebook where the Google Doc
      and the draft disagree: Turbo DNase kit versus on-column DNase I; GCA
      versus GCF accession; StringTie 2.2.0 versus 2.2.1; "gill tissue" in the
      Google Doc is a typo.

### C2. Figures

`figures/figure_X.png` is exported from a hand-assembled PowerPoint file, uses
default ggplot styling, does not colour the volcanoes by significance, has no
heatmap colour legend, and is produced by no script (`figures/README.md`).

- [x] Add a figure notebook (e.g. `tag-seq/code/05-figures.qmd`, added to the
      render list and to `render-all.sh`) that builds the composite from the
      DESeq2 objects with `patchwork` or `cowplot`, so the figure tracks the
      data.
- [x] Figure 1: PCA, volcano (coloured by padj < 0.05, headline genes
      labelled), heatmap with legend; both tissues.
- [x] Figure 2: enrichment dot plot, KEGG and GO, gonad.
- [x] Figure 3: per-group normalised counts for the headline genes (two SAA-5
      paralogues, equistatin-like, *hspb11*, vasotocin-neurophysin VT1, *amh*,
      and the 11 genes shared between tissues).
- [x] Export at journal resolution (vector PDF/EPS, or TIFF ≥ 300 dpi) with a
      colour-blind-safe palette; check the current royalblue/red3 pairing.

Done 2026-09-27 in `tag-seq/code/05-figures.qmd`: vector PDF and 300 dpi PNG
at 170 mm, colours validated for colour-vision deficiency, treatment shown by
shape as well. Figure 3 B plots the shared genes as liver vs gonad fold changes
rather than as count panels, and labels only the genes the text names. The
manuscript now embeds all three figures and reads its PCA percentages from
`figures/source-data/`. Figure 2 duplicates the KEGG and GO tables, which C3
should move to the supplement.

### C3. Tables

- [x] Main text: at most two tables (KEGG pathways; top gonad genes). The
      35-row GO table and the 31-row liver table go to the supplement.
- [x] Supplementary tables: sample metadata and QC (A2, A5, B3); full DE
      tables per tissue (all shrinkage estimators); full GO and KEGG results;
      gene tables from `tag-seq/gene_tables/`.

Done 2026-09-27 in `tag-seq/code/06-supplementary-tables.qmd`, written to
`manuscript/supplementary/` as CSV (no Excel writer is in `renv.lock`, and
archives prefer CSV). S1 samples and QC; S2 and S3 liver and gonad DE for
every tested gene with all four estimators; S4 and S5 every tested GO term and
KEGG pathway, both tissues; S6 the 19 shared genes. Legends are in the
manuscript, column definitions in `manuscript/supplementary/README.md`. The
characterized/uncharacterized gene tables are not a separate table: the
`description` column of S2 and S3 carries the same information. S1 still
lacks sex, maturity, body size and alignment rate, which wait on A1, A2, A5.
The main text now has Table 1 (top gonad genes) and Table 2 (KEGG).

### C4. Mechanics

- [x] Add `manuscript/manuscript.qmd` to the render workflow so the docx is
      built and proven on every push.
- [x] Add a *Molecular Ecology* CSL file and set `csl:` in the YAML header.
- [x] Add a docx reference document with double spacing and continuous line
      numbers for review.
- [x] Check the reference list for coverage: sockeye-specific spawning
      behaviour (female nest competition), 3′-tag analysis practice, salmonid
      acute-phase/immune genes, and recent peripheral-tissue social-status
      transcriptomics.
- [x] Cover letter.
- [ ] Remove the `[[...]]` placeholders; grep the rendered docx for `[[`
      before submitting. *(The check exists: `manuscript/check-placeholders.R`,
      run by `render-all.sh`. It lists every placeholder in the rendered Word
      file, six at present, all waiting on A-items; run it with
      `MANUSCRIPT_STRICT=1` for the build you submit and it fails until they
      are gone.)*

Done 2026-09-27, except placeholder removal:

- `render-all.sh` now renders the manuscript to Word and HTML and the cover
  letter to Word, after the analysis; CI uploads all three as the `manuscript`
  artifact on every run.
- The Citation Style Language repository lists *Molecular Ecology* as a
  dependent of APA 7th edition, so `manuscript/apa.csl` is vendored and set as
  `csl:`.
- `manuscript/reference-manuscript.docx`: Times New Roman 12 pt, double
  spacing (tables single), continuous line numbers, page numbers, US Letter
  with 1-inch margins. Validated against the OOXML schema.
- References: added and cited Foote 1990 and Quinn & Foote 1994 (sockeye
  female and male spawning territoriality), Ma et al. 2019 (3′ vs
  whole-transcript RNA-seq; read counts independent of transcript length),
  Jørgensen et al. 2000 and Bayne & Gerwick 2001 (salmonid serum amyloid A and
  the fish acute-phase response), and Lea et al. 2018 (rank-associated immune
  gene expression in blood of wild baboons). Each was checked against Crossref
  or PubMed, with no correction or retraction notices, and against its abstract
  for the claim it supports. That check changed one sentence: the Discussion
  said serum amyloid A transcription rises "by orders of magnitude", a
  mammalian figure; in salmon hepatocytes the reported induction is about 2- to
  10-fold, so the sentence now states only what the salmonid evidence shows.
- Prause et al. 2025 (*amh* expression in dominant vs subordinate tilapia
  testes) is in `references.bib` but not yet cited; it belongs in the *amh*
  discussion that C1 adds once A1 settles sex.
- `manuscript/cover-letter.qmd`: a draft that reads its numbers from the result
  tables; editor, authors, reviewers, preprint status and competing interests
  are placeholders.

---

## D. Repository streamlining (do before the Zenodo release)

Added 2026-09-26 after a second pass over the repository layout. The
scaffolding — one entry point, numbered notebooks, tracked and checksummed
results, CI — is right. What follows is what a reviewer would meet on arrival
that gets in the way. Items D1 and D2 regenerate every result table, so do
them in the same pass as B1 and rebaseline `check-reproduction.R` once.

### D1. Naming that will confuse supplementary-table readers

- [x] Use one case for the per-tissue output prefixes (`liver-*` and
      `GONAD-*` today; `tissue_config()` in `tag-seq/code/_common.R`).
- [x] Rename the `treatment` column in the DE tables, which holds the tissue
      name (`annotate_genes()` in notebook 02), to `tissue`.
- [x] Rename the `DEGs_all-genes*` rows of `*-gene-counts.csv` to say
      "genes tested"; they are not DEG counts.
- [x] Rename `trt` to `phenotype` in `tag-seq/data/treatments-*.csv`, the
      DESeq2 design and the plots, and re-record the input checksums.

Done 2026-09-27. Gonad outputs are `gonad-*`, renamed with `git mv` so their
history follows. The DE and gene tables have a `tissue` column. The summary
rows are `genes_tested_*` and `significant_*`. `trt` is `phenotype`
everywhere: the input tables (checksums re-recorded), the model design and
term (`phenotype_territorial_vs_social`), the single-gene-count tables, the
plots and the colour constants. A full render, compared table by table with
the previous commit through the rename map, matched exactly on all 41 result
tables, and the supplementary tables came out byte-identical, so only names
changed. `treatments-*.csv` keeps its filename.

### D2. Track only the results the manuscript uses

`tag-seq/DESEQ_output/` holds 53 files and 44 MB: four shrinkage estimators,
each with all-genes, significant and per-gene-count tables, plus eight volcano
PNGs and two MA-plot formats per tissue. The manuscript uses apeglm only.

- [x] Keep the unshrunken and apeglm tables, the gene-count summary, the PCA,
      correlation heatmap and one volcano and heatmap per tissue.
- [x] Either stop writing the `normal` and `ashr` tables and the per-estimator
      single-gene-count tables, or write them to an untracked `alternatives/`
      subfolder. Say in notebook 02 that the estimators were compared and the
      significant sets were identical.
- [x] Drop the duplicate MA-plot format and the per-estimator volcano PNGs.
- [x] Rebaseline `check-reproduction.R` on the reduced set.

Done 2026-09-27. Tracked `tag-seq/DESEQ_output/` fell from 37 MB to 11 MB.
Each tissue keeps five tables (unshrunken and apeglm, all and significant
genes, and the summary counts) and five images (PCA, sample-correlation
heatmap, expression heatmap, apeglm volcano, MA plot as PNG). The normal and
ashr tables, one table of normalised counts per significant gene (the four
per-estimator copies were identical apart from row order), and the PCA pairs
plot are regenerated into `alternatives/`, which git ignores. Notebook 06
reads the normal and ashr tables from there, so their fold changes are still
published in Tables S2 and S3, and `check-reproduction.R` now checks
`manuscript/supplementary/` too, so they are still verified. Also removed:
a 2022 `gonad/MA_plots.png` that no code wrote.

### D3. Move the inputs nothing reads

Already recorded as open decisions in `tag-seq/data/README.md` and
`tag-seq/genome/README.md`; close them.

- [x] Move `transcript_count_matrix-{gonad,liver}.csv` and
      `onerka_merged-liver.gtf` (33 MB) to the Gannet project folder or into
      the SRA/GEO deposit, and record the URL in `tag-seq/data/README.md`.
- [x] Drop `Onerka_LOCID_gene_table.txt` (3.8 MB, superseded) and record in
      `tag-seq/genome/README.md` that the feature table is a strict superset.
- [x] Tracked content then falls from ~129 MB to ~55 MB. Git history keeps the
      old blobs; that is fine, Zenodo archives the tree.

Done 2026-09-27, with one change of plan. The transcript matrices and merged
GTF are not on Gannet, and writing to the lab server is not something to do
from an analysis session, so instead of a Gannet URL each file's record in
`tag-seq/data/README.md` is a commit-pinned GitHub address plus its sha256,
downloaded and checked before removal. They should still go into the GEO
deposit (A3). `Onerka_LOCID_gene_table.txt` is also on Gannet (with CRLF line
endings, otherwise identical), and the superset claim was re-verified: all
33,211 of its genes are in the feature table with matching descriptions.
Also fixed: `index.qmd` linked a Gannet address that returns 404.

### D4. Write the notebooks for a reader, not an auditor

The notebooks, the directory READMEs and `_common.R` carry the audit narrative
("finding R5", "replaces the .Rmd which…", what the 2023 code did wrong). That
record belongs in `REPRODUCIBILITY-PLAN.md`, which already holds it.

- [x] Rewrite the prose in notebooks 02–04 and `_common.R` to describe the
      analysis as it is; move each "finding" reference and each comparison
      with the deleted code into the plan document, keyed by finding number.
- [x] Same for `tag-seq/data/README.md`, `tag-seq/genome/README.md`,
      `tag-seq/sequences/README.md` and `figures/README.md`.
- [ ] Remove the callouts in `index.qmd` that mark the gonad counts as
      provisional and the raw data as undeposited — by resolving A3 and A5,
      not by deleting the text. *(Kept: A3 and A5 are still open. Both callouts
      now state current facts, including the library-size evidence, and point
      to A3 and A5 instead of to audit findings.)*

Done 2026-09-27, except the callouts. Notebooks 02–06, `_common.R` and the
four READMEs describe the analysis as it is; 39 passages of audit narrative
(17,000 characters) moved verbatim into `REPRODUCIBILITY-PLAN.md`, "Notes moved
from the notebooks and READMEs", each labelled with its finding. The
executable code of every edited file was compared line by line with the
previous commit and is unchanged. Two stale statements were corrected on the
way: the exclusion comment said a later phase had committed the MultiQC
evidence, which never happened, and the genome README said only notebook 04
reads the feature table.

### D5. Empty directories and lab logistics

- [x] `tag-seq/QC/`: commit the MultiQC reports and a per-sample alignment
      table (A5), or remove the placeholder directories. An empty tracked
      directory asserts content that is not there.
- [x] Move the sequencing logistics in `README.md` (shipping dates, GSAF
      quote, sample manifest, Dropbox links, GitHub issue links) to a
      `NOTES.md` or drop them from the public archive. Keep the Gannet URL.
- [x] Add a directory map to `README.md`: one line per top-level directory
      saying what it holds and which notebook reads or writes it.

Done 2026-09-27. `tag-seq/QC/` holds the gonad MultiQC reports and data tables
copied from Gannet with their checksums, and a README saying what QC evidence
is missing: liver read QC, the HISAT2 logs, and the correlation evidence for
the exclusion. The four empty placeholder directories are gone. The alignment
rates the manuscript quotes are marked unverified there and in the manuscript
(a new placeholder, so the check now lists seven). Logistics moved to
`NOTES.md`, which may not belong in a public archive; its Dropbox and Google
links are not all public. `README.md` has a directory map, and its stale
description of the render and the checker is corrected.

### D6. Figures and supplement as outputs

- [x] Replace `figures/figure_X.pptx` and its PNG export with the output of
      the figures notebook (C2). Delete the pptx once the scripted figure
      matches.
- [x] Have the same notebook write `manuscript/supplementary/` (tables S1–Sn
      from A5, B3, C3) so the supplement is regenerated with the results.
      *(Done in C3 by a separate notebook, `06-supplementary-tables.qmd`,
      rendered after the figures, rather than in notebook 05.)*
- [x] Add `manuscript/manuscript.qmd` to `render-all.sh` and to the render
      workflow (C4) so the docx and the supplement are built in CI.
      *(Done in C4.)*

Also 2026-09-27: the generated outputs are now deterministic, so a render
leaves the working tree clean. Every render used to rewrite the three figure
PDFs, whose only difference was the creation timestamp cairo writes (cairo
1.16 ignores SOURCE_DATE_EPOCH), and the PCA scores, which varied in the 13th
decimal. Notebook 05 now sets the PDF timestamp to the epoch in place, keeping
the file length and cross-reference offsets unchanged, and rounds the scores
to six decimals. Two consecutive renders gave byte-identical figure files, and
the PDFs parse under a strict parser.

### D7. Standard files

- [x] `LICENSE` (A4).
- [x] `CITATION.cff` (A4).
- [x] `tag-seq/` is an extra directory level left from when the repository
      held other work. Flattening it touches every path and every committed
      result location; do it only if the results are being regenerated anyway
      for B1 and D1–D2, and otherwise leave it. *(Left as it is: B1 and D1–D2
      are merged, so flattening now would mean another full rebaseline for
      no change in content.)*

Done 2026-09-27. `LICENSE` follows the pattern of recent RobertsLab
repositories (MIT for code, CC0 for data): MIT for code and documentation,
CC0 1.0 for the data and every result, no licence for the manuscript and cover
letter (the authors keep all rights pending publication, so nothing here
complicates a journal copyright agreement), and third-party files under their
own terms, each named: NCBI, GO (CC BY 4.0), KEGG (academic use, not
released), the CSL style (CC BY-SA 3.0), pandoc, renv, DAVID and MultiQC. The
licence choice is the authors' to confirm. `CITATION.cff` validates against
schema 1.2.0; it lists Steven Roberts (ORCID checked against the public
registry) and the GitHub user mattgeorgephd, and says what to add before the
Zenodo release.

---

## E. Housekeeping

- [ ] `project-sockeye-tagseq.Rproj` has an uncommitted `ProjectId` line added
      by RStudio; commit or discard.
- [ ] Update `index.qmd` and `README.md` once accessions and the DOI exist,
      and remove the "no archival accession yet" callouts.
- [ ] After the Zenodo release, record the DOI in `CITATION.cff`, the
      manuscript, and `README.md`.
