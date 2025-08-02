# Configuración para Cloudflare Pages

Este proyecto es un **sitio web estático** generado con **Emacs org-mode** y **org-publish**.

## Deployment automático vía GitHub Actions

El proyecto está configurado para hacer **deployment automático** tanto a GitHub Pages como a Cloudflare Pages usando GitHub Actions.

### Secrets requeridos en GitHub

Para que el deployment automático funcione, necesitas configurar estos secrets en tu repositorio de GitHub:

#### 1. CLOUDFLARE_API_TOKEN
1. Ve a [Cloudflare Dashboard](https://dash.cloudflare.com/profile/api-tokens)
2. Crea un nuevo API Token con estos permisos:
   - **Cloudflare Pages:Edit** (para tu cuenta)
   - **Zone:Zone:Read** (para tu dominio, si usas dominio personalizado)
   - **Zone:DNS:Edit** (para tu dominio, si usas dominio personalizado)

#### 2. CLOUDFLARE_ACCOUNT_ID
1. Ve a [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. En la barra lateral derecha, copia tu "Account ID"

#### Configurar secrets en GitHub:
1. Ve a tu repositorio en GitHub
2. Settings > Secrets and variables > Actions
3. Crea estos Repository secrets:
   - `CLOUDFLARE_API_TOKEN`: El token generado en Cloudflare
   - `CLOUDFLARE_ACCOUNT_ID`: Tu Account ID de Cloudflare

## Crear proyecto en Cloudflare Pages

### Paso 1: Crear proyecto manualmente
1. Ve a [Cloudflare Dashboard](https://dash.cloudflare.com/) > **Workers & Pages**
2. Clic en **Create application** > **Pages** > **Upload assets**
3. Nombra tu proyecto: `disidencia-incontrolada`
4. **No conectes con Git** - el deployment se hará vía GitHub Actions

### Paso 2: Primera subida manual (opcional)
```bash
# Build local
bash build.sh

# Deploy inicial
wrangler pages deploy public_html --project-name=disidencia-incontrolada
```
No son necesarias variables especiales, pero puedes añadir:
- `ENVIRONMENT`: `production`

## Configuración en el repositorio

### Archivo `wrangler.toml`
```toml
name = "disidencia-incontrolada"
compatibility_date = "2024-08-01"

# Solo para deployment manual con Wrangler CLI
[assets]
directory = "./public_html"
not_found_handling = "404-page"

[vars]
ENVIRONMENT = "production"
```

### GitHub Actions Workflow
El archivo `.github/workflows/deploy.yml`:
- **Instala Emacs** automáticamente en Ubuntu
- **Ejecuta `build.sh`** para generar el sitio
- **Deploya a GitHub Pages** usando `peaceiris/actions-gh-pages`
- **Deploya a Cloudflare Pages** usando `cloudflare/wrangler-action`

## Proceso de deployment

### Automático (recomendado)
1. **Push a rama `main`** → GitHub Actions detecta cambios automáticamente
2. **Build automático** → GitHub Actions ejecuta `bash build.sh` en Ubuntu con Emacs
3. **Deploy dual automático** → Publica simultáneamente a:
   - GitHub Pages (`https://jllopis.github.io/disidencia.incontrolada.com`)
   - Cloudflare Pages (`https://disidencia-incontrolada.pages.dev`)

### Manual (opcional)
Para deployment manual únicamente a Cloudflare:
```bash
# Instalar Wrangler
npm install -g wrangler

# Build local (requiere Emacs instalado)
bash build.sh

# Deploy manual solo a Cloudflare
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

### Secrets no configurados
Si el deployment falla en GitHub Actions:
1. Verifica que `CLOUDFLARE_API_TOKEN` y `CLOUDFLARE_ACCOUNT_ID` estén configurados
2. Verifica que el API token tenga los permisos correctos
3. Revisa los logs de GitHub Actions para errores específicos

### Proyecto no existe en Cloudflare
Si obtienes error "Project not found":
1. Crea el proyecto manualmente en Cloudflare Dashboard
2. Asegúrate de que el nombre sea exactamente `disidencia-incontrolada`
3. Haz un deployment manual inicial si es necesario

### Errores de org-publish
- Verifica que `publish.el` esté en el repositorio
- Los archivos en `posts/` deben seguir estructura `YYYYMMDD/slug/index.org`
- Los archivos problemáticos (como `theindex.org`) ya están excluidos
