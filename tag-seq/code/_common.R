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

## Everything that differs between the two tissues is set here, so notebook 02
## is one document rendered once per tissue. Every output file is prefixed with
## the tissue name (liver-PCA.png, gonad-SIG-DEG-apeglm.csv, ...).
tissue_config <- function(tissue) {
  cfg <- switch(
    tissue,
    liver = list(
      exclude        = character(0),
      pca_xlim       = c(-100, 100)
    ),
    gonad = list(
      ## C05 and C17 are excluded. The recorded reason is that they clustered
      ## apart from the other gonad libraries by sample correlation; that output
      ## is not in this repository. They are also the two smallest gonad
      ## libraries by gene-assigned counts (Table S1). The exclusion is stated
      ## here rather than computed from a rule (submission checklist A5).
      exclude        = c("C05", "C17"),
      pca_xlim       = c(-150, 150)
    ),
    stop("unknown tissue: ", tissue, " (expected 'liver' or 'gonad')")
  )
  cfg$tissue <- tissue
  cfg$prefix <- tissue
  cfg$dir    <- file.path(PATHS$output, tissue)
  cfg
}

## Build an output path inside this tissue's results directory.
out_path <- function(cfg, ...) file.path(cfg$dir, paste0(...))

## Build a path in this tissue's alternatives/ subdirectory: outputs that every
## render regenerates but that are not tracked in git, because the manuscript
## does not use them directly -- the normal and ashr shrinkage tables, the
## normalised counts per significant gene, and the PCA pairs plot. Notebook 06
## reads the shrinkage tables from here into Tables S2 and S3, which are
## tracked and checked, so those estimates are still recorded and verified.
alt_path <- function(cfg, ...) {
  d <- file.path(cfg$dir, "alternatives")
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
  file.path(d, paste0(...))
}

# ---- sample identity --------------------------------------------------------

## Derive the sample ID used in the phenotype tables from a count-matrix column.
##
## prepDE.py names columns after the GTF files: "01B_S43_R1.gtf". The phenotype
## tables use "B01". The mapping is: take the token before the first underscore
## ("01B") and swap its number and tissue letter ("B01"). Samples are then
## matched by this ID, never by column position, so a count matrix whose columns
## come out in a different order cannot mislabel them.
sample_ids_from_columns <- function(cols) {
  tag <- sub("_.*$", "", sub("\\.gtf$", "", cols))
  bad <- !grepl("^[0-9]+[A-Za-z]$", tag)
  if (any(bad)) {
    stop("count matrix columns do not look like '<number><tissue letter>_...': ",
         paste(cols[bad], collapse = ", "))
  }
  sub("^([0-9]+)([A-Za-z])$", "\\2\\1", tag)
}

## Take the gene identifier from a StringTie row name.
##
## Row names are "gene-<id>|<id>": the identifier is a LOC number for genes
## with no assigned symbol ("gene-LOC115144855|LOC115144855") and a real symbol
## for the rest ("gene-arhgap8|arhgap8"). The part after the pipe is that
## identifier in both cases, and it is unique across all 37,942 genes, which is
## asserted.
gene_ids_from_rownames <- function(rn) {
  ids <- sub("^.*\\|", "", rn)
  if (anyDuplicated(ids)) {
    stop("gene identifiers are not unique: ",
         paste(unique(ids[duplicated(ids)])[1:5], collapse = ", "))
  }
  ids
}

# ---- data loading -----------------------------------------------------------

## Load the count matrix and phenotype table for one tissue, matched on sample
## ID rather than on column position, and return them already aligned.
load_counts <- function(cfg) {
  coldata <- read.csv(file.path(PATHS$data, paste0("treatments-", cfg$tissue, ".csv")),
                      sep = ",", header = TRUE, row.names = "ID")

  ## check.names = FALSE: the StringTie columns start with a digit
  ## ("01B_S43_R1.gtf"), and read.csv would otherwise silently rename them to
  ## "X01B_S43_R1.gtf".
  cts <- as.matrix(read.csv(
    file.path(PATHS$data, paste0("onerka_gene_count_matrix-", cfg$tissue, ".csv")),
    sep = ",", header = TRUE, row.names = "gene_id", check.names = FALSE))

  ids <- sample_ids_from_columns(colnames(cts))

  ## Every derived ID is unique, and the matrix and the phenotype table describe
  ## exactly the same samples.
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

  rownames(cts) <- gene_ids_from_rownames(rownames(cts))

  ## Excluded samples are dropped from both objects together.
  if (length(cfg$exclude)) {
    missing <- setdiff(cfg$exclude, rownames(coldata))
    if (length(missing)) stop("cannot exclude absent sample(s): ", paste(missing, collapse = ", "))
    keep    <- setdiff(rownames(coldata), cfg$exclude)
    coldata <- coldata[keep, , drop = FALSE]
    cts     <- cts[, keep, drop = FALSE]
  }

  ## Behavioural phenotype, observed at capture: territorial is compared with
  ## social, the reference, set explicitly so the sign of every fold change is
  ## fixed by this line rather than by alphabetical order.
  coldata$phenotype <- relevel(factor(coldata$phenotype), ref = "social")
  coldata$tissue <- factor(coldata$tissue)

  list(cts = cts, coldata = coldata)
}

## Per-gene annotation: description, NCBI GeneID and transcript length.
##
## Built from the NCBI feature table for assembly GCF_006149115.2, which covers
## 37,929 of the 37,942 genes in the count matrices. The description is the name
## of the gene's first mRNA with a name.
##
## Length is the median mRNA interval per gene. goseq's nullp() takes it as
## bias data; the test itself is hypergeometric (see 04), so the length enters
## the diagnostic plot but not the p-values.
load_gene_annotation <- function() {
  ft <- read.delim(file.path(PATHS$genome, "GCF_006149115.2_Oner_1.1_feature_table.txt"),
                   sep = "\t", quote = "", stringsAsFactors = FALSE, check.names = FALSE)
  names(ft)[1] <- "feature"

  m <- ft[ft$feature == "mRNA" & nzchar(ft$symbol), ]

  first_name <- tapply(m$name, m$symbol, function(x) {
    x <- x[nzchar(x)]
    if (length(x)) x[[1]] else NA_character_
  })
  gene_id <- tapply(m$GeneID, m$symbol, function(x) x[[1]])
  len     <- tapply(m$feature_interval_length, m$symbol,
                    function(x) stats::median(x, na.rm = TRUE))

  data.frame(gene        = names(first_name),
             GeneID      = as.integer(gene_id[names(first_name)]),
             description = unname(first_name),
             length      = as.numeric(len[names(first_name)]),
             stringsAsFactors = FALSE)
}

## Fit the DESeq2 model for one tissue and apply the reporting filter.
##
## Notebook 02 writes the result tables from this object and notebook 05 draws
## the manuscript figures from it, so both work from one definition of the
## model rather than two copies that could drift apart.
##
## social is the reference level (set in load_counts), so coefficient 2 is the
## territorial-vs-social effect, which is asserted.
## Genes are then kept if at least a third of samples have 10 or more counts.
## The filter is applied *after* DESeq(), so dispersions and size factors were
## estimated on the full matrix -- the order the committed results depend on.
fit_deseq <- function(dat) {
  dds <- DESeq2::DESeqDataSetFromMatrix(countData = dat$cts,
                                        colData   = dat$coldata,
                                        design    = ~ phenotype)
  dds <- DESeq2::DESeq(dds)
  stopifnot(identical(DESeq2::resultsNames(dds)[2], "phenotype_territorial_vs_social"))

  n_before <- nrow(dds)
  dds <- dds[rowSums(DESeq2::counts(dds) >= 10) >= ncol(dds) / 3, ]
  list(dds = dds, n_before = n_before)
}

## Kept for the notebooks that only need gene -> description.
load_feature_table <- function() {
  load_gene_annotation()[, c("gene", "description")]
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

## Phenotype colours, looked up per sample from coldata, so they follow the
## samples whatever the group sizes or column order.
##
## The hues are validated for colour-vision deficiency, not chosen by eye:
## blue and orange separate by OKLab delta E 24.7 under protanopia and 33.6 for
## normal vision, and both hold at least 3:1 contrast on a white page. Plots
## pair them with a second encoding (circle vs triangle) as well.
PHENOTYPE_COLOURS <- c(territorial = "#2a78d6", social = "#eb6834")
PHENOTYPE_SHAPES  <- c(territorial = 16, social = 17)

## Diverging ramp for z-scored expression heatmaps: green (low) through a
## neutral grey to purple (high). The poles were picked to stay distinct from
## both phenotype colours, since the heatmaps carry a phenotype bar beside
## them: every pair of the four clears delta E 10.9 under colour-vision
## deficiency and 22.3 for normal vision.
DIVERGING <- c(low = "#0f6b45", mid = "#f0efec", high = "#762a83")

phenotype_side_colours <- function(coldata) unname(PHENOTYPE_COLOURS[as.character(coldata$phenotype)])

# ---- KEGG ---------------------------------------------------------------------

## KEGG pathway membership is downloaded from the KEGG REST API at render time
## rather than kept in the repository. KEGG is not a public database: its API is
## provided for academic use by academic users, and it grants no right to
## redistribute its data (https://www.kegg.jp/kegg/legal.html). This is also why
## Bioconductor stopped updating its KEGG.db package.
##
## The two responses are saved under tag-seq/genome/, which git ignores for
## these files, and reused while they exist, so repeated local renders use the
## same copy. Set KEGG_REFRESH=1 to download afresh. A fresh checkout, including
## every CI run, downloads the current release, which may differ slightly from
## the one the committed results were computed from; kegg_one_SOURCE.txt records
## that release and the sha256 of its two responses, and check-reproduction.R
## accepts KEGG-derived tables that drift numerically as long as the set of
## enriched pathways is unchanged.
KEGG_FILES <- c(links = "kegg_one_gene2pathway.tsv", names = "kegg_one_pathways.tsv")
KEGG_URLS  <- c(links = "https://rest.kegg.jp/link/pathway/one",
                names = "https://rest.kegg.jp/list/pathway/one")

ensure_kegg <- function(refresh = identical(Sys.getenv("KEGG_REFRESH"), "1")) {
  paths <- setNames(file.path(PATHS$genome, KEGG_FILES), names(KEGG_FILES))
  record_path <- file.path(PATHS$genome, "kegg_one_RETRIEVED.txt")

  if (refresh || !all(file.exists(paths))) {
    for (k in names(paths)) {
      tmp <- tempfile()
      ok  <- tryCatch({
        utils::download.file(KEGG_URLS[[k]], tmp, quiet = TRUE, mode = "wb")
        file.size(tmp) > 0
      }, error = function(e) FALSE)
      if (!ok) stop("could not download ", KEGG_URLS[[k]], ". KEGG pathway data are ",
                    "fetched at render time and are not in the repository; check the ",
                    "network connection, or place the file at ", paths[[k]], ".")
      file.copy(tmp, paths[[k]], overwrite = TRUE)
    }
    info <- tryCatch(readLines("https://rest.kegg.jp/info/kegg", warn = FALSE),
                     error = function(e) character(0))
    release <- trimws(sub("^\\s*pathway\\s+[0-9]+\\s+", "",
                          grep("^\\s*pathway\\s", info, value = TRUE)[1]))
    writeLines(c(paste("retrieved:", format(Sys.time(), "%Y-%m-%d", tz = "UTC")),
                 paste("KEGG pathway release:", release)), record_path)
  }

  ## Compare with the copy the committed results were computed from.
  src <- readLines(file.path(PATHS$genome, "kegg_one_SOURCE.txt"), warn = FALSE)
  src <- grep("^[0-9a-f]{64}[[:space:]]+kegg_", src, value = TRUE)
  committed <- setNames(sub("[[:space:]].*$", "", src), sub("^[0-9a-f]{64}[[:space:]]+", "", src))
  current   <- vapply(paths, function(p) digest::digest(p, algo = "sha256", file = TRUE), "")
  matches   <- identical(unname(current), unname(committed[KEGG_FILES]))

  retrieved <- if (file.exists(record_path)) readLines(record_path, warn = FALSE) else "retrieval record missing"
  invisible(list(paths = paths, matches = matches, retrieved = retrieved,
                 current = current, committed = committed))
}

# ---- input integrity ---------------------------------------------------------

## Check the input files against CHECKSUMS.sha256, so that an input which
## changed without anyone noticing is reported: otherwise the committed results
## would silently stop corresponding to the committed inputs.
##
## A mismatch warns rather than stops. A deliberate data update should not block
## a render -- it should be loud, and then re-recorded:
##     shasum -a 256 $(awk '!/^#/ && NF {print $2}' CHECKSUMS.sha256) > CHECKSUMS.sha256
##
## Paths in the manifest are relative to the project root, which is where every
## chunk runs (execute-dir: project). Skipped with a message if the manifest or
## the digest package is absent, so no notebook gains a hard dependency on it.
verify_inputs <- function(manifest = "CHECKSUMS.sha256") {
  if (!file.exists(manifest)) {
    message("verify_inputs(): ", manifest, " not found; skipping integrity check")
    return(invisible(NULL))
  }
  if (!requireNamespace("digest", quietly = TRUE)) {
    message("verify_inputs(): package 'digest' not installed; skipping integrity check")
    return(invisible(NULL))
  }

  lines <- readLines(manifest, warn = FALSE)
  lines <- trimws(lines)
  lines <- lines[nzchar(lines) & !startsWith(lines, "#")]

  expected <- sub("^([0-9a-fA-F]+)[[:space:]]+[*]?(.*)$", "\\1", lines)
  paths    <- sub("^([0-9a-fA-F]+)[[:space:]]+[*]?(.*)$", "\\2", lines)

  missing  <- character(0)
  mismatch <- character(0)
  for (i in seq_along(paths)) {
    if (!file.exists(paths[i])) {
      missing <- c(missing, paths[i])
      next
    }
    got <- digest::digest(paths[i], algo = "sha256", file = TRUE)
    if (!identical(tolower(got), tolower(expected[i]))) {
      mismatch <- c(mismatch, paths[i])
    }
  }

  if (length(missing) > 0) {
    warning("input file(s) listed in ", manifest, " are missing: ",
            paste(missing, collapse = ", "), call. = FALSE)
  }
  if (length(mismatch) > 0) {
    warning("input file(s) do not match ", manifest, ": ",
            paste(mismatch, collapse = ", "),
            ". The analysis will still run, but the committed results no longer ",
            "correspond to these inputs.", call. = FALSE)
  }
  if (length(missing) == 0 && length(mismatch) == 0) {
    message("verify_inputs(): ", length(paths), " input files match ", manifest)
  }

  invisible(list(checked = paths, missing = missing, mismatch = mismatch))
}

## Runs whenever this file is sourced: at the top of notebooks 02-06 and of the
## manuscript.
verify_inputs()
