
#!/bin/bash
# ==============================================================================
# Script de Auditoría de Integridad de Datasets y Diagnóstico de Filas Corruptas
# Autor: Andrea Barrios
# Descripción: Analiza estructura, separadores, métricas generales y detecta
# errores de formato o inconsistencias en filas específicas.
# ==============================================================================

# Configuración de archivos
CSV_FILE="${1:-data/raw/stock.csv}"
DB_FILE="stock.db"
REPORT_FILE="reports/informe_auditoria_diagnostico.txt"

# Crear directorio de reportes si no existe
mkdir -p reports

echo "=================================================="
echo " INICIANDO AUDITORÍA DE INTEGRIDAD DE DATOS "
echo "=================================================="
echo "Analizando archivo: $CSV_FILE"
echo ""

# 1. Detección automática del separador (Coma o Punto y Coma)
PRIMERA_FILA=$(head -n 1 "$CSV_FILE")
IFSS_COMAS=$(echo "$PRIMERA_FILA" | awk -F',' '{print NF}')
IFSS_PUNTOS=$(echo "$PRIMERA_FILA" | awk -F';' '{print NF}')

if [ "$IFSS_COMAS" -gt "$IFSS_PUNTOS" ]; then
    SEPARADOR=","
    CANT_COLUMNAS=$IFSS_COMAS
else
    SEPARADOR=";"
    CANT_COLUMNAS=$IFSS_PUNTOS
fi

# 2. Conteo de filas
TOTAL_FILAS=$(wc -l < "$CSV_FILE")
FILAS_DATOS=$((TOTAL_FILAS - 1))

# 3. Detección de filas con número incorrecto de columnas (Errores de Pegado / Formato)
FILAS_CORRUPTAS=$(awk -F"$SEPARADOR" -v cols="$CANT_COLUMNAS" 'NF != cols {print NR}' "$CSV_FILE")

# 4. Cálculo de unidades y registros desde SQLite (si la base está disponible)
MÉTRICAS_SQL=""
if [ -f "$DB_FILE" ]; then
    MÉTRICAS_SQL=$(sqlite3 -header -column "$DB_FILE" "SELECT COUNT(*) AS total_registros_db, SUM(Cantidad) AS total_unidades FROM bar;")
fi

# 5. Generación del Informe de Salida (.txt)
{
    echo "================================================================="
    echo " INFORME DE AUDITORÍA Y DIAGNÓSTICO DE INTEGRIDAD "
    echo "================================================================="
    echo "Fecha de informe : $(date +'%Y-%m-%d %H:%M:%S')"
    echo "Archivo auditado : $CSV_FILE"
    echo "Formato / Delim. : '$SEPARADOR' (Campos/Columnas esperados: $CANT_COLUMNAS)"
    echo "Cantidad de filas: $TOTAL_FILAS (Encabezado + $FILAS_DATOS registros)"
    echo "-----------------------------------------------------------------"
    echo "MÉTRICAS GENERALES DE INVENTARIO (SQLite):"
    echo "$MÉTRICAS_SQL"
    echo "-----------------------------------------------------------------"
    echo "ANÁLISIS DE ANOMALÍAS Y ERRORES:"
    
    if [ -z "$FILAS_CORRUPTAS" ]; then
        echo "✔ No se detectaron inconsistencias en la cantidad de columnas."
    else
        echo "⚠️ ALERTA: Se encontraron filas con número de columnas/separadores desalineados:"
        echo "$FILAS_CORRUPTAS" | while read -r line_num; do
            echo " -> Error en Fila #$line_num"
        done
    fi
    echo ""
    echo "================================================================="
    echo " DETALLE EN FORMATO 'LINE' DE LA FILA ESPECÍFICA DE CONSULTA / ERROR "
    echo "================================================================="
    
    # Inspección de la fila 1586 en el CSV (o las filas detectadas con error)
    TARGET_ROW=${2:-1586}
    echo "--- Inspección física del archivo CSV (Fila $TARGET_ROW) ---"
    sed -n "${TARGET_ROW}p" "$CSV_FILE"
    echo ""
    
    if [ -f "$DB_FILE" ]; then
        echo "--- Detalle vertical en formato LINE (SQLite - Registro correspondiente aprox.) ---"
        # Muestra el registro 1585 de la tabla (descontando encabezado)
        OFFSET=$((TARGET_ROW - 2))
        if [ $OFFSET -ge 0 ]; then
            sqlite3 -line "$DB_FILE" "SELECT * FROM bar LIMIT 1 OFFSET $OFFSET;"
        fi
    fi
    echo "================================================================="
} > "$REPORT_FILE"

echo "✔ Auditoría completada."
echo "📄 Informe de diagnóstico guardado en: $REPORT_FILE"
echo ""
echo "--- VISTA PREVIA DEL INFORME ---"
cat "$REPORT_FILE"
