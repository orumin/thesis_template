TEX=platex
PANDOC=pandoc
BIBTEX=pbibtex
DVI2PDF=dvipdfmx
TEX_FLAGS= --shell-escape -kanji=utf8 -kanji-internal=utf8 -interaction=batchmode
# PANDOC_FLAGS について，Makefile 内で pbibtex を呼んでいるけど pandoc filter で参考文献の処理をしたかったらコメントを外す
PANDOC_FLAGS= --smart -t latex --filter pandoc-crossref #--filter pandoc-citeproc

TARGET=paper

COUNT=3

SOURCE = manuscript.tex

MDSCRIPTS = src/abstract.md src/contents.md

TEXFILES=$(MDSCRIPTS:.md=.tex)
DVIFILE=$(SOURCE:.tex=.dvi)
BIBFILES=cite/paper.bib
BIBSTYLES=sty/elsevier-vancouver.csl
REFSTYLES=sty/crossref_config.yaml

# Makefile 内で pbibtex を呼んでいるけど pandoc filter で参考文献の処理をしたかったら こっちも コメントを外す
PANDOC_FILTER_FLAGS= -M "crossrefYaml=$(REFSTYLES)" #--bibliography=$(BIBFILES) --csl=$(BIBSTYLES)

.SUFFIXES: .tex .md .pdf
.PHONY: all semi-clean clean preview

all: $(TARGET).pdf semi-clean

.md.tex:
	@cat $< \
	| $(PANDOC) --verbose $(PANDOC_FLAGS) $(PANDOC_FILTER_FLAGS) \
	| sed 's/.png/.pdf/g' \
	| sed 's/includegraphics/includegraphics[width=1.0\\columnwidth]/g' \
	| sed 's/\\cite/~\\cite/g' \
	| sed 's/\\textbackslash{}\,/\\\,/g' \
	| sed 's/\\textasciitilde{}\\ref{/~\\ref{/g' \
	| sed 's/\[htbp\]/[t]/g' \
	> $@

$(TARGET).pdf: $(TEXFILES)
	@for i in `seq 1 $(COUNT)`; \
	do \
		$(TEX) $(TEX_FLAGS) $(SOURCE); \
		if [ ! -e "$(SOURCE:.tex=.blg)" ]; then \
			$(BIBTEX) $(basename $(SOURCE)); \
		fi \
	done
	$(DVI2PDF) -o $(TARGET).pdf $(DVIFILE) 2> /dev/null

semi-clean:
	@rm -f *.aux *.log *.out *.lof *.toc *.bbl *.blg *.xml *.bcf *blx.bib *.spl

clean: semi-clean
	@rm -f $(TARGET).pdf $(DVIFILE) $(TEXFILES)

preview:
	@xdg-open $(TARGET).pdf 2> /dev/null
