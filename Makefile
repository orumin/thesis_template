TEX=platex
BIBTEX=pbibtex
DVI2PDF=dvipdfmx
DVICONCAT=dviconcat
TEX_FLAGS= -interaction=batchmode -kanji=utf8 -kanji-internal=utf8

TARGET=thesis

COUNT=3

SOURCES = manuscript.tex

MDSCRIPT = src/contents.md src/eabstract.md src/jabstract.md

BIBFILES = cite/paper.bib

DVIFILES=$(SOURCES:.tex=.dvi)

all: convertmd dvi2pdf clean

convertmd: $(MDSCRIPT)
	@for MD in $(MDSCRIPT); do \
	  cat $${MD} \
	  | sed 's/.png/.eps/g' \
	  | pandoc -t latex \
	  | sed 's/includegraphics/includegraphics[width=1.0\\columnwidth]/g' \
	  | sed 's/\[htbp\]/[H]/g' \
	  | sed 's/\\label{\(.*\)}}/} \
\\label{\1}/g' \
	  > $${MD%.md}.tex; \
	done


dvi2pdf: $(DVIFILES)
	${DVICONCAT} $^ -o ${TARGET}.dvi
	${DVI2PDF} ${TARGET}.dvi 2> /dev/null

.tex.dvi: convertmd
	@for i in `seq 1 $(COUNT)`; \
	do \
		${TEX} ${TEX_FLAGS} $<; \
		if [ $< = 'manuscript.tex' ] && [ ! -e 'manuscript.blg' ]; then \
			${BIBTEX} $(basename $<); \
		fi \
	done

clean:
	@rm -f *.dvi *.aux *.log *.out *.lof *.toc *.bbl *.blg *.xml *.bcf *blx.bib

all-clean: clean
	@rm -f ${TARGET}.pdf src/*.tex

preview:
	@xdg-open ${TARGET}.pdf 2> /dev/null
