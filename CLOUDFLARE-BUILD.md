# Configuración para Cloudflare Pages

Este proyecto es un **sitio web estático** generado con **Emacs org-mode** y **org-publish**.

## Configuración del proyecto en Cloudflare Pages

### Paso 1: Crear proyecto en Cloudflare
1. Ve a [Cloudflare Dashboard](https://dash.cloudflare.com/) > **Workers & Pages**
2. Clic en **Create application** > **Pages** > **Connect to Git**
3. Selecciona tu repositorio GitHub: `jllopis/disidencia.incontrolada.com`
4. Autoriza la conexión si es necesario

### Paso 2: Configurar Build Settings
En la página de configuración del proyecto:

- **Project name**: `disidencia-incontrolada`
- **Production branch**: `main`
- **Build command**: `apt-get update && apt-get install -y emacs-nox && bash build.sh`
- **Build output directory**: `public_html`
- **Root directory**: `/` (dejar vacío)

### Paso 3: Variables de entorno (opcional)
No son necesarias variables especiales, pero puedes añadir:
- `ENVIRONMENT`: `production`

## Configuración en el repositorio

### Archivo `wrangler.toml`
```toml
name = "disidencia-incontrolada"
compatibility_date = "2024-08-01"

[build]
command = "apt-get update && apt-get install -y emacs-nox && bash build.sh"
cwd = "."
watch_dir = "."

[build.upload]
format = "directory"
dir = "public_html"

[vars]
ENVIRONMENT = "production"
```

### Script de build `build.sh`
El script se encarga de:
- Limpiar y preparar directorios de salida
- Ejecutar Emacs con org-publish
- Generar sitio estático en `public_html/`

**Nota**: La instalación de Emacs se maneja directamente en `wrangler.toml` para el entorno de Cloudflare Pages.

## Proceso de deployment

### Automático (recomendado)
1. **Push a rama `main`** → Cloudflare detecta cambios automáticamente
2. **Build automático** → Ejecuta `bash build.sh`
3. **Deploy automático** → Publica contenido de `public_html/`

### Manual (opcional)
Puedes usar Wrangler CLI localmente (requiere tener Emacs instalado):
```bash
# Instalar Wrangler
npm install -g wrangler

# Build local (asegurar que Emacs esté instalado)
bash build.sh

# Deploy manual
wrangler pages deploy public_html --project-name=disidencia-incontrolada
```

## Dominio personalizado

Para configurar `disidencia.incontrolada.com`:

1. **En Cloudflare Pages**:
   - Ve a tu proyecto > **Custom domains**
   - Clic **Set up a custom domain**
   - Introduce: `disidencia.incontrolada.com`

2. **En Cloudflare DNS**:
   - Ve a tu zona DNS `incontrolada.com`
   - Añade/modifica record:
     - **Type**: `CNAME`
     - **Name**: `disidencia`
     - **Target**: `disidencia-incontrolada.pages.dev`

## URLs del sitio

- **Cloudflare Pages**: `https://disidencia-incontrolada.pages.dev`
- **Dominio personalizado**: `https://disidencia.incontrolada.com`
- **GitHub Pages**: `https://jllopis.github.io/disidencia.incontrolada.com`

## Troubleshooting

### Build falla por falta de Emacs
La instalación de Emacs está configurada directamente en `wrangler.toml`. Si hay problemas:
1. Verifica que `build.sh` sea ejecutable (`chmod +x build.sh`)
2. Revisa los logs de build en Cloudflare Dashboard
3. La instalación usa `apt-get` (específico para el entorno Linux de Cloudflare Pages)
4. Si persisten errores, verifica que el comando de build en `wrangler.toml` sea correcto

### Errores de org-publish
- Verifica que `publish.el` esté en el repositorio
- Los archivos en `posts/` deben seguir estructura `YYYYMMDD/slug/index.org`
- Los archivos problemáticos (como `theindex.org`) ya están excluidos

### Preview vs Production
- **Preview deployments**: Se crean automáticamente para PRs y commits a otras ramas
- **Production deployments**: Solo para commits a rama `main`
