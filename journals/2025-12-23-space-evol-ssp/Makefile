#!/usr/bin/env -S make -f

MAKEFLAGS += -Rr --warn-undefined-variables
SHELL != which bash
.SHELLFLAGS := -euo pipefail -c

_WS := $(or ) $(or )
_comma := ,
.RECIPEPREFIX := $(_WS)

.ONESHELL:
.DELETE_ON_ERROR:
.PHONY: phony
self := $(firstword $(MAKEFILE_LIST))

install = install --backup=t /dev/stdin $@

main := ssp fsdb-cte
main: phony $(main:%=out/%.yml)
out/%.yml: %.md cmd/mdq.sh | out; < $< m4 -P | $(lastword $^) md2yml | $(install)
cmd/mdq.sh: mdq.yml | cmd; baj.sh yml2sh $< | $(install)

mdq := ~/.cargo/bin/mdq
mdq: phony $(mdq)
$(mdq):; cargo install --git https://github.com/yshavit/mdq

cmd out:; mkdir -p $@
