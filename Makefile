TEX=platex
PANDOC=pandoc
BIBTEX=pbibtex
DVI2PDF=dvipdfmx
TEX_FLAGS= --shell-escape -kanji=utf8 -kanji-internal=utf8 -interaction=batchmode

TARGET=paper

COUNT=3

SOURCE = manuscript.tex

MDSCRIPTS = src/abstract.md src/contents.md

TEXFILES=$(MDSCRIPTS:.md=.tex)
DVIFILE=$(SOURCE:.tex=.dvi)
BIBFILES=cite/paper.bib
REFSTYLES=sty/crossref_config.yaml

PANDOC_FLAGS= --smart -f markdown+pipe_tables -t latex --filter pandoc-crossref --natbib

PANDOC_FILTER_FLAGS= -M "crossrefYaml=$(REFSTYLES)"

.SUFFIXES: .tex .md .pdf
.PHONY: all semi-clean clean preview

all: $(TARGET).pdf semi-clean

.md.tex:
	@cat $< \
	| $(PANDOC) --verbose $(PANDOC_FLAGS) $(PANDOC_FILTER_FLAGS) \
	| sed 's/.png/.pdf/g' \
	| sed 's/includegraphics/includegraphics[width=1.0\\columnwidth]/g' \
	| sed 's/\[htbp\]/[t]/g' \
	> $@

$(TARGET).pdf: $(TEXFILES)
	@cd tex && for i in `seq 1 $(COUNT)`; \
	do \
		$(TEX) $(TEX_FLAGS) $(SOURCE); \
		if [ ! -e "$(SOURCE:.tex=.blg)" ]; then \
			$(BIBTEX) $(basename $(SOURCE)); \
		fi \
	done
	cd tex && $(DVI2PDF) -o ../$(TARGET).pdf $(DVIFILE) 2> /dev/null

semi-clean:
	@cd tex && rm -f *.aux *.log *.out *.lof *.toc *.bbl *.blg *.xml *.bcf *blx.bib *.spl

clean: semi-clean
	@rm -f $(TARGET).pdf $(DVIFILE) $(TEXFILES)

preview:
	@xdg-open $(TARGET).pdf 2> /dev/null
