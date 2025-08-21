#!/bin/bash
# Salir inmediatamente si un comando falla
set -euo pipefail

echo "--- Desplegando manualmente a Cloudflare Pages..."

# Construir primero
bash build.sh

# Desplegar usando wrangler
npx wrangler deploy public_html --name=disidencia-incontrolada

echo "--- Despliegue completado!"