#!/bin/bash

# Salir inmediatamente si un comando falla
set -e

# Directorio de salida
OUTPUT_DIR="public_html"

echo "--- Limpiando el directorio de salida ---"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/css"
mkdir -p "$OUTPUT_DIR/img"
mkdir -p "$OUTPUT_DIR/posts"

echo "--- Publicando con org-publish ---"
#emacs -batch --eval "(load-file \"publish.el\") (gimlab-build-and-publish)"
emacs -batch --eval "(progn (load-file \"publish.el\") (gimlab-build-and-publish))"

echo "--- Proceso completado ---"
echo "Sitio generado en $OUTPUT_DIR/"
