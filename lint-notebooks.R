#!/usr/bin/env Rscript
##
## lint-notebooks.R -- parse every notebook without running it.
##
## This exists because of a real failure. `01-upstream-alignment.qmd` carried 24
## chunk headers written as ```{bash, eval: false}, which mixes Rmd syntax
## (eval=FALSE) with Quarto syntax (#| eval: false) and is neither. knitr parsed
## the whole string as the chunk LABEL, so the eval option was silently ignored
## and all 24 chunks shared one label -- a hard error. The render died on the
## first notebook, and we only found out 35 minutes into CI, after renv had
## restored 184 packages.
##
## Knitting with eval = FALSE needs no analysis packages and no data, so it runs
## in seconds on a bare R. Anything that makes a notebook unparseable -- a
## malformed chunk header, a duplicate label, an unclosed fence, bad YAML -- is
## caught here instead of there.
##
## Usage: Rscript lint-notebooks.R
## Exit 0 = every notebook parses. Exit 1 = at least one does not.

suppressWarnings(suppressMessages({
  ok_pkg <- requireNamespace("knitr", quietly = TRUE)
}))
if (!ok_pkg) {
  cat("lint-notebooks.R: knitr is not installed; cannot lint.\n")
  quit(status = 1)
}

files <- c("index.qmd",
           list.files("tag-seq/code", pattern = "[.]qmd$", full.names = TRUE))
files <- files[file.exists(files)]
if (!length(files)) {
  cat("lint-notebooks.R: found no notebooks to lint.\n")
  quit(status = 1)
}

cat("Notebook lint (parse only, nothing is executed)\n")
cat("----------------------------------------------\n")

failures <- character(0)
for (f in files) {
  ## eval = FALSE everywhere: we are testing that the document can be parsed,
  ## not that the analysis runs. Chunk labels, fences and YAML are all checked
  ## by the parse regardless.
  res <- tryCatch({
    old <- knitr::opts_chunk$get(c("eval", "echo"))
    knitr::opts_chunk$set(eval = FALSE, echo = TRUE)
    on.exit(knitr::opts_chunk$set(old), add = TRUE)
    out <- tempfile(fileext = ".md")
    knitr::knit(f, output = out, quiet = TRUE)
    n <- length(grep("^```", readLines(out, warn = FALSE)))
    sprintf("OK (%d fenced blocks)", n %/% 2)
  }, error = function(e) paste("FAIL:", conditionMessage(e)))

  cat(sprintf("  %-45s %s\n", f, res))
  if (grepl("^FAIL", res)) failures <- c(failures, f)
}

## A chunk header that knitr swallows into the label is not an error, but it is
## always a mistake: the options in it are being ignored. Catch that shape too.
cat("\nChunk headers with Rmd-style inline options (options would be ignored):\n")
suspect <- character(0)
for (f in files) {
  lines <- readLines(f, warn = FALSE)
  hdr <- grep("^```\\{[a-zA-Z]+[ ,]+[^}]*:", lines)
  if (length(hdr)) {
    suspect <- c(suspect, f)
    for (i in hdr) cat(sprintf("  %s:%d  %s\n", f, i, lines[i]))
  }
}
if (!length(suspect)) cat("  none\n")

if (length(failures) || length(suspect)) {
  cat("\nNotebook lint: FAIL\n")
  if (length(failures)) cat("  unparseable:", paste(failures, collapse = ", "), "\n")
  if (length(suspect))  cat("  malformed chunk headers:", paste(suspect, collapse = ", "), "\n")
  cat("Use `#| option: value` lines inside the chunk, or Rmd's `option=value`\n")
  cat("in the header -- never `option: value` in the header.\n")
  quit(status = 1)
}

cat("\nNotebook lint: PASS -- every notebook parses and no chunk header hides an option.\n")
quit(status = 0)
