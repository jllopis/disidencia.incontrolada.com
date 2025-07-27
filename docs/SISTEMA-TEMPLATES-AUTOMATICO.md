# Sistema de Templates y Gestión de Borradores

## 📝 **Resumen del Sistema Completo**

Se ha implementado un sistema integral que **elimina toda la repetición de código HTML** en los archivos `.org` de los posts y proporciona **gestión profesional de borradores**, manteniendo solo el contenido esencial y un workflow de publicación robusto.

## ✨ **Beneficios Principales**

### 🎯 **Para Escritores:**
- **Posts más limpios**: Solo contenido, sin HTML repetitivo
- **Enfoque en escritura**: Sintaxis org-mode pura
- **Menos errores**: No hay HTML manual que pueda romperse
- **Más rápido**: Crear posts nuevos es instantáneo
- **Control de visibilidad**: Sistema de borradores con tags
- **Sin enlaces rotos**: Borradores no aparecen hasta estar listos

### 🔧 **Para Desarrolladores:**
- **DRY**: No Repeat Yourself - HTML centralizado
- **Mantenible**: Cambios en template afectan todos los posts
- **Consistente**: Estructura garantizada en todos los posts
- **Flexible**: Fácil modificar diseño global
- **Robusto**: Sistema de exclusión dinámico de borradores

## 📋 **Antes vs Después**

### ❌ **ANTES** (Repetitivo y Complejo):
```org
#+HTML: <h1 class="site-title">Mi Blog de Filosofía</h1>
#+HTML: <div class="navigation">...</div>
#+HTML: <div class="post-header-section">
#+HTML:   <h1 class="post-title">Título</h1>
#+HTML:   <div class="post-meta">...</div>
#+HTML:   <img src="..." class="post-header-image">
#+HTML: </div>

* Contenido del post

#+HTML: <div class="sidebar-section">...</div>
#+HTML: <div class="footer">...</div>
```

### ✅ **AHORA** (Limpio y Simple):
```org
#+TITLE: Título del Post
#+DESCRIPTION: Descripción SEO
#+AUTHOR: Joan Llopis
#+DATE: 2025-07-26
#+TAGS: etiqueta1, etiqueta2
#+OPTIONS: toc:nil

* Contenido del post

Solo org-mode puro, ¡sin HTML!
```

**Para borradores, simplemente añadir el tag:**
```org
#+TAGS: borrador, etiqueta1, etiqueta2
```

## 🛠️ **Cómo Funciona**

### 🔄 **Flujo Automático:**
1. **Escribes** el post en sintaxis org-mode pura
2. **org-publish** procesa el contenido usando `:filter-body`
3. **Filter automático** (`gimlab-post-body-filter`) añade template completo
4. **Sistema de exclusión** omite automáticamente archivos con tag `borrador`
5. **Resultado**: HTML completo y estructurado solo para posts publicados

### 🎨 **Template Automático Incluye:**
- ✅ Header del sitio con título y navegación
- ✅ Metadata del post (autor, fecha) extraída automáticamente
- ✅ Imagen de cabecera (detectada por nombre de archivo)
- ✅ Sidebar con categorías (generadas automáticamente sin borradores)
- ✅ Footer del sitio
- ✅ Layout responsivo con CSS Grid

## 📖 **Uso Práctico**

### 1️⃣ **Crear Nuevo Post:**
```bash
# Usar template base (recomendado)
cp templates/post-template.org posts/mi-nuevo-post.org

# O crear desde cero con metadatos mínimos
```

### 2️⃣ **Editar Solo lo Esencial:**
```org
#+TITLE: Mi Nuevo Post
#+DESCRIPTION: Descripción para SEO
#+AUTHOR: Joan Llopis
#+DATE: 2025-07-26
#+TAGS: filosofía, reflexión
#+OPTIONS: toc:nil

* Mi contenido aquí

Escribo solo el contenido, ¡sin preocuparme por HTML!
```

### 📁 **Estructura de Archivos:**
```
posts/
├── mi-nuevo-post.org        # Post en org-mode puro
├── mi-nuevo-post.png        # Imagen (opcional, autodetectada)
├── borrador-ejemplo.org     # Borrador (tag 'borrador')
└── ...

templates/
└── post-template.org        # Template base para nuevos posts

public_html/posts/           # Solo posts publicados
├── mi-nuevo-post.html       # ✅ Publicado
└── ...                      # ❌ borrador-ejemplo.html NO existe
```

### 3️⃣ **Añadir Imagen (Opcional):**
- Guarda imagen como: `posts/mi-nuevo-post.png`
- Se detecta y añade automáticamente

### 4️⃣ **Generar Sitio:**
```bash
emacs --batch --load publish.el
# o usar el script de conveniencia:
./build.sh
```

## 🔒 **Sistema de Borradores**

### **Workflow de Borradores:**
1. **Crear borrador**: Añadir tag `borrador` en `#+TAGS:`
2. **El sistema automáticamente**:
   - ❌ NO publica el archivo HTML
   - ❌ NO aparece en sitemap
   - ❌ NO aparece en lista de posts de la home
   - ❌ NO incluye sus categorías en el sidebar
3. **Publicar**: Quitar tag `borrador` → aparece automáticamente

### **Ejemplo de Borrador:**
```org
#+TITLE: Mi Post en Desarrollo
#+AUTHOR: Joan Llopis
#+DATE: 2025-07-26
#+TAGS: borrador, filosofía, ideas
```

### **Ejemplo Publicado:**
```org
#+TITLE: Mi Post Terminado
#+AUTHOR: Joan Llopis  
#+DATE: 2025-07-26
#+TAGS: filosofía, ideas, publicado
```

## 🔧 **Configuración Técnica**

### **Implementación con org-publish:**
```elisp
;; En publish.el - Configuración del proyecto
(setq org-publish-project-alist
  '(("gimlab-blog-posts"
     ;; ... otras configuraciones ...
     :filter-body (gimlab-post-body-filter)  ; ← Filtro automático
     :exclude ,(gimlab-generate-exclude-pattern) ; ← Exclusión dinámica
     )))
```

### **Filter de Templates:**
- **`:filter-body`**: Configuración en `org-publish-project-alist`
- **`gimlab-post-body-filter()`**: Función que aplica template
- **Solo posts**: Se aplica únicamente a archivos en `/posts/`
- **Preserva resto**: Páginas normales (`index.org`, `about.org`) sin cambios

### **Sistema de Exclusión de Borradores:**
```elisp
;; Funciones del sistema de borradores
(defun gimlab-get-draft-files ())           ; Detecta archivos con tag 'borrador'
(defun gimlab-generate-exclude-pattern ())  ; Genera regex dinámico
```

- **Detección dinámica**: Escanea tags en tiempo de publicación
- **Exclusión múltiple**: Publicación + sitemap + listas + categorías
- **Patrón regex**: Generado automáticamente para org-publish
- **Sin configuración manual**: Todo automático

### **Detección Automática:**
- **Imágenes**: `reflexiones-modernas.org` → busca `reflexiones-modernas.png/jpg`
- **Metadata**: Extraída de headers org-mode (`#+TITLE:`, `#+AUTHOR:`, etc.)
- **Categorías**: Generadas desde `#+TAGS:` de todos los posts (excluyendo borradores)
- **Lista de posts**: Regenerada automáticamente con formato visual completo

### **Funciones Principales Implementadas:**
```elisp
;; Sistema de Templates
gimlab-post-body-filter()          ; Aplica template automáticamente
gimlab-find-header-image()         ; Detecta imágenes por nombre
gimlab-extract-categories()        ; Genera categorías desde tags
gimlab-generate-categories-html()  ; HTML del sidebar

;; Sistema de Borradores  
gimlab-get-draft-files()           ; Detecta archivos con tag 'borrador'
gimlab-generate-exclude-pattern()  ; Genera regex de exclusión
gimlab-generate-post-list-html()   ; Lista de posts sin borradores

;; Regeneración Automática
;; post-list.html se regenera en cada publicación
```

## 🎯 **Resultado Final**

### **Para el Usuario:**
- Escribir posts es más fácil y rápido
- Menos código que mantener
- Imposible romper la estructura del sitio
- Enfoque 100% en el contenido
- **Control de borradores**: Tag simple para controlar visibilidad

### **Para el Sitio:**
- Diseño completamente uniforme
- Estructura garantizada
- Cambios globales en un solo lugar
- Mantenimiento simplificado
- **Sin enlaces rotos**: Borradores no aparecen en listas hasta estar listos

## 🔧 **Funciones Implementadas**

### **Flujo de Publicación Completo:**
```bash
# 1. Ejecutar publicación
emacs --batch --load publish.el

# 2. El sistema automáticamente:
# - Detecta archivos con tag 'borrador'
# - Genera patrón de exclusión dinámico  
# - Aplica templates solo a posts publicados
# - Regenera post-list.html con formato completo
# - Actualiza categorías excluyendo tags de borradores
# - Publica solo archivos sin tag 'borrador'
```

### **Características Avanzadas:**
- **Post destacado dinámico**: Home muestra post más reciente o marcado como "destacado"
- **Metadatos SEO**: Open Graph y meta tags automáticos
- **CSS responsivo**: Diseño adaptativo para móviles y desktop
- **Navegación preparada**: Sistema de anterior/siguiente posts
- **Fallback de imágenes**: Usa `banner.png` si no encuentra imagen específica

## 🚀 **Próximas Mejoras Posibles**

- **Auto-categorías**: Generar categorías desde contenido
- **Auto-resumen**: Extraer description automáticamente  
- **Auto-tags**: Sugerir tags según contenido
- **Múltiples templates**: Para diferentes tipos de post
- **Programación de publicación**: Posts con fecha futura
- **Auto-backup**: Copia de seguridad automática de borradores

## 📊 **Estado Actual del Sistema**

### ✅ **Implementado y Funcionando:**
- Sistema de templates automático completo
- Exclusión robusta de borradores por tags
- Regeneración automática de listas
- Detección automática de imágenes
- Sidebar de categorías dinámico
- Workflow profesional de publicación

### 🔄 **Proceso de Publicación Actual:**
1. Escribir post en sintaxis org-mode pura
2. Opcional: añadir tag `borrador` para mantener privado
3. Ejecutar `emacs --batch --load publish.el`
4. Sistema automáticamente:
   - Aplica template a todos los posts
   - Excluye borradores de todas las listas
   - Regenera `post-list.html` con formato completo
   - Actualiza sitemap y categorías

## 🔄 **Migración y Compatibilidad**

### **Diferencias Técnicas con Versiones Anteriores:**
- **Antes**: `org-export-filter-body-functions` (global)
- **Ahora**: `:filter-body` en configuración org-publish (específico del proyecto)
- **Ventaja**: Mayor control y aislamiento del filtro

### **Archivos Afectados en la Migración:**
```
✅ Fusionado: docs/SISTEMA-TEMPLATES.md → docs/SISTEMA-TEMPLATES-AUTOMATICO.md
✅ Actualizado: README.md (referencias corregidas)
✅ Implementado: Sistema de borradores completo
✅ Mejorado: Regeneración automática de listas
```

---

*Este sistema unificado mantiene la flexibilidad de org-mode mientras automatiza completamente la estructura HTML repetitiva y proporciona un workflow profesional de gestión de borradores.*
