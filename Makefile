all: move rmd2md

move:
		cp inst/vign/crul_vignette.md vignettes;\
		cp inst/vign/async.md vignettes

rmd2md:
		cd vignettes;\
		mv crul_vignette.md crul_vignette.Rmd;\
		mv async.md async.Rmd
