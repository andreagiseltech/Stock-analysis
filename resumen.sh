#!/bin/bash

CSV_FILE="${1:-stock.csv}"

awk -F',' 'NR > 1 {
    print "[" $2 "]" $3 " (Talle: " $4 " - " $5 ") Cant: " $6
    total = total + $6
}
END {
    print "------------------------------------------------"
    print "TOTAL GENERAL DE UNIDADES: " total
}' "CSV_FILE" | head -n 15 
