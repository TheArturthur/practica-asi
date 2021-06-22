#!/bin/bash

tree -n -I vm -o secciones/estructura_ficheros.tex ..

sed -ir -e '/^$/d' -e 's/^\.\..*/\\begin\{verbatim\}/' -e 's/^[[:digit:]][[:digit:]]*.*/\\end\{verbatim\}/g' -e 's/[├│└]/\|/g' -e 's/──/--/g' secciones/estructura_ficheros.tex

rm ../.gitGraph/* includes/graph.png
git graph -n cdr -f png -c
yes | cp -f ../.gitGraph/*.png includes/graph.png

git log --no-merges --encoding="UTF-8" --reverse --date=format:"%a, %e de %B" --pretty=format:"\item \textbf{\underline{\textit{Commit:}} \#%h, \underline{Fecha:} %ad, \underline{Autor:} %an}\\\\\item[] %s\\\\" > includes/log.tex

sed -ir -e 's/\&/\\\&/g' -e 's/\ \+[[:digit:]]\{4\}//g' -e 's/ CU-y320tz//g' -e 's/Pérez Martín/Perez Martin/g' -e 's/TheArturthur/Arturo Vidal Peña/g' -e 's/asudara/Alfonso Sudara Padilla/g' includes/log.tex

latexmk -c -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make practica_asi.tex
#rm includes/.log