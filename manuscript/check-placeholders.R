#!/usr/bin/env Rscript
#
# List every [[...]] placeholder left in the rendered manuscript.
#
#   Rscript manuscript/check-placeholders.R                 # report, exit 0
#   MANUSCRIPT_STRICT=1 Rscript manuscript/check-placeholders.R   # fail if any
#
# Reads the rendered Word file rather than manuscript.qmd, for two reasons:
# the source also contains R's own [[ indexing inside code chunks, which is
# not a placeholder; and a placeholder could in principle come from computed
# text, which only the rendered document shows. Word splits text into runs
# wherever formatting changes (a bold placeholder is several runs), so each
# paragraph's runs are joined before searching.
#
# Run by render-all.sh after the manuscript is rendered. The default only
# reports, because a working draft has placeholders by design until the
# authors fill them in. Set MANUSCRIPT_STRICT=1 for the build you submit.

docx <- if (length(commandArgs(TRUE))) commandArgs(TRUE)[1] else "manuscript/manuscript.docx"
if (!file.exists(docx)) stop(docx, " not found; render the manuscript first")

tmp <- tempfile()
utils::unzip(docx, files = "word/document.xml", exdir = tmp)
doc <- xml2::read_xml(file.path(tmp, "word", "document.xml"))
ns  <- xml2::xml_ns(doc)

paras <- xml2::xml_find_all(doc, "//w:body//w:p", ns)
text  <- vapply(paras, function(p)
  paste(xml2::xml_text(xml2::xml_find_all(p, ".//w:t", ns)), collapse = ""), "")

hits <- regmatches(text, gregexpr("\\[\\[[^]]*\\]\\]", text))
where <- rep(seq_along(hits), lengths(hits))
found <- unlist(hits)

if (length(found) == 0) {
  cat("Placeholders: none in", docx, "\n")
  quit(status = 0)
}

cat(sprintf("Placeholders: %d in %s\n", length(found), docx))
for (i in seq_along(found)) {
  txt <- gsub("\\s+", " ", found[i])
  if (nchar(txt) > 110) txt <- paste0(substr(txt, 1, 107), "...")
  cat(sprintf("  paragraph %4d: %s\n", where[i], txt))
}

if (identical(Sys.getenv("MANUSCRIPT_STRICT"), "1")) {
  cat("MANUSCRIPT_STRICT=1: failing because placeholders remain.\n")
  quit(status = 1)
}
cat("Draft mode: reported only. Set MANUSCRIPT_STRICT=1 to fail on these.\n")
