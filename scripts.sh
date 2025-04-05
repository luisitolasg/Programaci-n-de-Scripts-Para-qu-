#!/bin/bash

# Archivo CSV
archivo_csv="Datos.csv"

# Inicializar variables
declare -A ventas_por_mes
declare -A ventas_por_producto
declare -A clientes_frecuentes

monto_total_anual=0

# Leer archivo CSV
while IFS=',' read -r producto mes cantidad_vendida monto_total cliente; do
    # Limpiar valores para evitar caracteres especiales o espacios adicionales
    producto=$(echo "$producto" | xargs)
    mes=$(echo "$mes" | xargs)
    cantidad_vendida=$(echo "$cantidad_vendida" | xargs)
    monto_total=$(echo "$monto_total" | xargs)
    cliente=$(echo "$cliente" | xargs)

    # Mensaje de depuración para verificar cada fila procesada
    echo "Procesando fila: producto='$producto', mes='$mes', cantidad_vendida='$cantidad_vendida', monto_total='$monto_total', cliente='$cliente'"

    # Ignorar la cabecera del archivo
    if [[ $producto == "Producto" ]]; then
        continue
    fi

    # Verificar que las columnas numéricas sean válidas
    if ! [[ $cantidad_vendida =~ ^[0-9]+$ ]] || ! [[ $monto_total =~ ^[0-9]+$ ]]; then
        echo "Advertencia: datos no numéricos encontrados. Saltando esta fila."
        continue
    fi

    # Procesar datos
    ventas_por_mes[$mes]=$((ventas_por_mes[$mes] + monto_total))
    ventas_por_producto[$producto]=$((ventas_por_producto[$producto] + cantidad_vendida))
    clientes_frecuentes[$cliente]=$((clientes_frecuentes[$cliente] + 1))
    monto_total_anual=$((monto_total_anual + monto_total))
done < "$archivo_csv"

# Determinar producto más vendido
producto_mas_vendido=$(for producto in "${!ventas_por_producto[@]}"; do
    echo "$producto ${ventas_por_producto[$producto]}"
done | sort -k2 -nr | head -n1 | awk '{print $1}')

# Determinar cliente más frecuente
cliente_mas_frecuente=$(for cliente in "${!clientes_frecuentes[@]}"; do
    echo "$cliente ${clientes_frecuentes[$cliente]}"
done | sort -k2 -nr | head -n1 | awk '{print $1}')

# Crear reporte
echo "Reporte de Ventas" > reporte.txt
echo "=================" >> reporte.txt
echo "Total de ventas por mes:" >> reporte.txt
for mes in "${!ventas_por_mes[@]}"; do
    echo "Mes $mes: ${ventas_por_mes[$mes]}" >> reporte.txt
done
echo "Producto más vendido: $producto_mas_vendido" >> reporte.txt
echo "Monto total anual: $monto_total_anual" >> reporte.txt
echo "Cliente más frecuente: $cliente_mas_frecuente" >> reporte.txt