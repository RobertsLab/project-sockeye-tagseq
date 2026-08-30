## Shared setup for the sockeye TagSeq notebooks.
##
## Sourced from the project root -- _quarto.yml sets execute-dir: project, so
## every path below is written once and means the same thing everywhere.

# ---- paths ------------------------------------------------------------------

PATHS <- list(
  data   = "tag-seq/data",
  genome = "tag-seq/genome",
  seqs   = "tag-seq/sequences",
  output = "tag-seq/DESEQ_output"
)

# ---- per-tissue configuration -----------------------------------------------

## Everything that differed between the two near-identical DESeq2 notebooks
## (finding E5) is collected here. The output file prefixes differ in case for
## historical reasons -- liver files are "liver-*", gonad files are "GONAD-*" --
## and are kept as they are so the committed results stay at the same paths.
tissue_config <- function(tissue) {
  cfg <- switch(
    tissue,
    liver = list(
      prefix         = "liver",   # liver-PCA.png, liver-SIG-DEG-apeglm.csv, ...
      heatmap_prefix = "liver",   # liver_heatmap_pval_genes_apeglm.png
      exclude        = character(0),
      pca_xlim       = c(-100, 100)
    ),
    gonad = list(
      prefix         = "GONAD",
      heatmap_prefix = "gonad",
      ## C05 and C17 were dropped on the basis of the MultiQC sample-correlation
      ## heatmap. In the .Rmd this was an uncommented pair of lines in gonad and
      ## the same pair commented out in liver, with no recorded criterion
      ## (finding R5). Phase 4 commits the MultiQC output that justifies it.
      exclude        = c("C05", "C17"),
      pca_xlim       = c(-150, 150)
    ),
    stop("unknown tissue: ", tissue, " (expected 'liver' or 'gonad')")
  )
  cfg$tissue <- tissue
  cfg$dir    <- file.path(PATHS$output, tissue)
  cfg
}

## Build an output path inside this tissue's results directory.
out_path <- function(cfg, ...) file.path(cfg$dir, paste0(...))

# ---- sample identity --------------------------------------------------------

## Derive the treatment-table sample ID from a StringTie count-matrix column.
##
## prepDE.py names columns after the GTF files: "01B_S43_R1.gtf". The treatment
## tables use "B01". The mapping is: take the token before the first underscore
## ("01B") and swap its number and tissue letter ("B01").
##
## The .Rmd did this positionally -- colnames(cts) <- row.names(trt_list) -- and
## then "checked" the result with all(colnames(cts) %in% rownames(coldata)),
## which is unconditionally TRUE after the rename (finding R1). Any prepDE.py
## re-run that emitted columns in a different order would have silently
## mislabelled every sample.
sample_ids_from_columns <- function(cols) {
  tag <- sub("_.*$", "", sub("\\.gtf$", "", cols))
  bad <- !grepl("^[0-9]+[A-Za-z]$", tag)
  if (any(bad)) {
    stop("count matrix columns do not look like '<number><tissue letter>_...': ",
         paste(cols[bad], collapse = ", "))
  }
  sub("^([0-9]+)([A-Za-z])$", "\\2\\1", tag)
}

## Reduce StringTie row names to the LOC identifier used everywhere downstream.
##
## "gene-LOC115144855|LOC115144855" -> "LOC115144855". Rows with no LOC id
## become "LOCNA", which is the origin of the LOCNA class the gene tables
## filter on. This reproduces the .Rmd loop exactly, vectorised.
loc_ids_from_rownames <- function(rn) {
  parts <- strsplit(rn, split = "LOC", fixed = TRUE)
  paste0("LOC", vapply(parts,
                       function(x) if (length(x) >= 3L) x[[3L]] else NA_character_,
                       character(1)))
}

# ---- data loading -----------------------------------------------------------

## Load the count matrix and treatment table for one tissue, matched on sample
## ID rather than on column position, and return them already aligned.
load_counts <- function(cfg) {
  coldata <- read.csv(file.path(PATHS$data, paste0("treatments-", cfg$tissue, ".csv")),
                      sep = ",", header = TRUE, row.names = "ID")

  ## check.names = FALSE: the StringTie columns start with a digit
  ## ("01B_S43_R1.gtf"), and read.csv would otherwise silently rename them to
  ## "X01B_S43_R1.gtf". The .Rmd never noticed because it overwrote the column
  ## names positionally before ever reading them.
  cts <- as.matrix(read.csv(
    file.path(PATHS$data, paste0("onerka_gene_count_matrix-", cfg$tissue, ".csv")),
    sep = ",", header = TRUE, row.names = "gene_id", check.names = FALSE))

  ids <- sample_ids_from_columns(colnames(cts))

  ## The three assertions the old tautological check should have been.
  if (anyDuplicated(ids)) {
    stop("duplicate sample IDs derived from count matrix columns: ",
         paste(unique(ids[duplicated(ids)]), collapse = ", "))
  }
  if (!setequal(ids, rownames(coldata))) {
    stop("count matrix and treatment table do not describe the same samples.\n",
         "  only in counts:     ", paste(setdiff(ids, rownames(coldata)), collapse = ", "), "\n",
         "  only in treatments: ", paste(setdiff(rownames(coldata), ids), collapse = ", "))
  }
  colnames(cts) <- ids
  cts <- cts[, rownames(coldata), drop = FALSE]   # align by name, not by luck
  stopifnot(identical(colnames(cts), rownames(coldata)))

  rownames(cts) <- loc_ids_from_rownames(rownames(cts))

  ## Excluded samples are dropped from both objects together.
  if (length(cfg$exclude)) {
    missing <- setdiff(cfg$exclude, rownames(coldata))
    if (length(missing)) stop("cannot exclude absent sample(s): ", paste(missing, collapse = ", "))
    keep    <- setdiff(rownames(coldata), cfg$exclude)
    coldata <- coldata[keep, , drop = FALSE]
    cts     <- cts[, keep, drop = FALSE]
  }

  ## territorial is the treatment, social is the reference. Made explicit so the
  ## sign of every log2FoldChange no longer depends on "social" happening to
  ## sort before "territorial" alphabetically (finding R3).
  coldata$trt    <- relevel(factor(coldata$trt), ref = "social")
  coldata$tissue <- factor(coldata$tissue)

  list(cts = cts, coldata = coldata)
}

## Gene ID -> description, used to annotate every results table.
load_feature_table <- function() {
  ft <- read.delim(file.path(PATHS$genome, "Onerka_LOCID_gene_table.txt"), header = TRUE)
  colnames(ft) <- c("gene", "description")
  dplyr::distinct(ft, gene, .keep_all = TRUE)
}

# ---- plotting ---------------------------------------------------------------

my_theme <- ggplot2::theme(
  line             = ggplot2::element_line(linewidth = 1.5),
  rect             = ggplot2::element_rect(linewidth = 1.5),
  text             = ggplot2::element_text(size = 14, colour = "black"),
  panel.background = ggplot2::element_blank(),
  panel.grid.major = ggplot2::element_blank(),
  panel.grid.minor = ggplot2::element_blank(),
  axis.text.x      = ggplot2::element_text(size = 16, colour = "black"),
  axis.text.y      = ggplot2::element_text(size = 16, colour = "black"),
  axis.title.x     = ggplot2::element_text(margin = ggplot2::margin(t = 10)),
  axis.title.y     = ggplot2::element_text(margin = ggplot2::margin(r = 10)),
  axis.ticks.x     = ggplot2::element_line(colour = "black"),
  axis.ticks.y     = ggplot2::element_line(colour = "black"),
  panel.border     = ggplot2::element_rect(colour = "black", fill = NA, linewidth = 1.5),
  legend.key       = ggplot2::element_blank()
)

## Treatment colours, derived from coldata rather than hardcoded run lengths.
## The .Rmd wrote rep("royalblue1", 15) / rep("red3", 15) for liver and 14 / 14
## for gonad, assuming both the group sizes and the column order (finding R4).
TRT_COLOURS <- c(territorial = "royalblue1", social = "red3")

trt_side_colours <- function(coldata) unname(TRT_COLOURS[as.character(coldata$trt)])
