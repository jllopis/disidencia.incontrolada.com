#!/bin/bash

# Salir inmediatamente si un comando falla
set -euo pipefail

export TZ=Europe/Madrid

# Directorio de salida
OUTPUT_DIR="public_html"

echo "--- Limpiando el directorio de salida ---"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/css"
mkdir -p "$OUTPUT_DIR/img"
mkdir -p "$OUTPUT_DIR/posts"

# Verificar que emacs esté disponible
if ! command -v emacs &> /dev/null; then
    echo "❌ Error: emacs no está instalado"
    exit 1
fi

echo "--- Versión de Emacs:"
emacs --version

echo "--- Generando contenido estático..."
#emacs -batch --eval "(load-file \"publish.el\") (gimlab-build-and-publish)"
emacs -batch --eval "(progn (load-file \"publish.el\") (gimlab-build-and-publish))"

echo "--- Generación completada. Archivos en public_html:"
ls -la public_html/

echo "--- Build completado exitosamente!"
echo "Sitio generado en $OUTPUT_DIR/"
