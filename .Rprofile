source("renv/activate.R")

# renv/activate.R restores the repositories recorded in renv.lock, so this must
# come *after* it -- and it must amend the CRAN entry rather than replace the
# whole vector, which would drop the Bioconductor 3.18 repositories.
#
# CRAN is pinned to a dated Posit Package Manager snapshot, and it must be the
# same snapshot renv.lock names as its CRAN repository. That snapshot has to
# supply every CRAN package version in the lockfile, either as its current
# version or from its Archive; renv::restore() looks in both. 2025-05-18 does:
# 137 of the 146 locked CRAN packages are current there and the other 9 (MASS,
# Matrix, XML, lattice, mgcv, nlme, nnet, renv, survival) are in its Archive.
#
# The pin was previously 2024-04-24, chosen to be contemporary with
# Bioconductor 3.18. But the lockfile had been snapshotted with packages from
# 2025-05-18, so 77 locked versions were newer than anything that snapshot
# held, and a restore from it alone failed on nlme 3.1-166. CI only passed
# because its runner added "latest" Package Manager as a fallback repository
# (submission checklist B4, REPRODUCIBILITY-PLAN.md).
#
# A date is still the point: it makes "which CRAN" a recorded fact rather than
# "whatever was current the day you ran it". It does not constrain versions
# already in the lockfile, but it does govern anything newly installed, and
# some packages current in 2025-05-18 require R >= 4.4 or 4.5. If an
# renv::install() fails that way, install the last version that supports
# R 4.3 explicitly (renv::install("pkg@x.y.z")) rather than moving the date.
# If you deliberately move this project to a newer R, change this date, the
# CRAN URL in renv.lock and the Bioconductor version together, then re-snapshot.
local({
  repos <- getOption("repos")
  repos["CRAN"] <- "https://packagemanager.posit.co/cran/2025-05-18"
  options(repos = repos)
})
