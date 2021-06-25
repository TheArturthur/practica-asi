#!/bin/bash

git log --no-merges --encoding="UTF-8" --reverse --date=format:"%a, %e de %B" --pretty=format:"\item \textbf{\underline{Fecha:} %ad, \underline{Autor:} %an}:\\\\\item[] %s\\\\" > includes/log.tex

sed -ir -e 's/\&/\\\&/g' -e 's/\ \+[[:digit:]]\{4\}//g' -e 's/ CU-y320tr//g' -e 's/ CU-y320tq//g' -e 's/ CU-y320tt//g' -e 's/ CU-y320tz//g' -e 's/ CU-y320tu//g' -e 's/Pérez Martín/Perez Martin/g' -e 's/TheArturthur/Arturo Vidal Peña/g' -e 's/asudara/Alfonso Sudara Padilla/g' includes/log.tex
rm includes/log.texr

latexmk -c -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make practica_asi.tex
