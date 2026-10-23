
#!/bin/bash

# ==============================================================================
# SCRIPT DINÁMICO DE AUDITORÍA E INTEGRIDAD DE DATOS (CLI)
# Autor: Andrea Gisel Barrios
# ==============================================================================

echo "=================================================="
echo " INICIANDO AUDITORIA DINÁMICA DE INTEGRIDAD"
echo "=================================================="

# 1. Detectar automáticamente cualquier archivo .csv en el directorio actual
CSV_FILE=$(ls *.csv 2>/dev/null | head -n 1)

if [ -z "$CSV_FILE" ]; then
    echo "[!] Error: No se encontró ningún archivo CSV en la carpeta actual."
    exit 1
fi

echo "[+] Archivo detectado para auditoría: $CSV_FILE"
echo "--------------------------------------------------"

# 2. Detector de espacios invisibles (leading/trailing spaces)
echo "[*] Buscando espacios en blanco sospechosos..."
ESPACIOS=$(grep -n '^[[:space:]]\|[[:space:]],\|, [[:space:]]' "$CSV_FILE")

if [ -n "$ESPACIOS" ]; then
    echo "[!] ¡Alerta! Se encontraron celdas con espacios en blanco erróneos:"
    echo "$ESPACIOS"
else
    echo "[ok] Excelente: No se detectaron espacios invisibles al inicio de los campos."
fi

echo "--------------------------------------------------"

# 3. Métricas y conteo total de líneas
TOTAL_FILAS=$(wc -l < "$CSV_FILE")
echo "[+] Total de líneas en el archivo (incluyendo cabecera): $TOTAL_FILAS"

echo "=================================================="
echo " AUDITORÍA COMPLETADA CON ÉXITO"
echo "=================================================="
