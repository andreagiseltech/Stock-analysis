
#!/bin/bash

# ==============================================================================
# SCRIPT DINÁMICO DE RESUMEN DE STOCK (CLI)
# Autor: Andrea Gisel Barrios
# ==============================================================================

echo "=================================================="
echo " GENERANDO RESUMEN DE INVENTARIO"
echo "=================================================="

# 1. Detectar automáticamente el archivo CSV en la carpeta actual
CSV_FILE=$(ls *.csv 2>/dev/null | head -n 1)

if [ -z "$CSV_FILE" ]; then
    echo "[!] Error: No se encontró ningún archivo CSV en la carpeta actual."
    exit 1
fi

echo "[+] Archivo analizado: $CSV_FILE"
echo "--------------------------------------------------"

# 2. Procesamiento de ejemplo con awk (asegurate de usar $CSV_FILE y no comillas raras)
echo "[*] Procesando datos del inventario..."

# Acá podés dejar tus comandos habituales usando "$CSV_FILE" para que lea bien el archivo
awk -F',' '{print $1, $2}' "$CSV_FILE" | head -n 10

echo "--------------------------------------------------"
echo " RESUMEN FINALIZADO CON ÉXITO"
echo "=================================================="
