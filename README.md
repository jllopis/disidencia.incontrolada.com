# Blog Profesional de Filosofía

## 📋 Descripción

Blog estático profesional generado con **Emacs org-publish**, diseñado para publicar artículos de filosofía con un diseño moderno, responsive y mantenible.

## ✨ Características

- **🎨 Diseño Moderno**: CSS responsive con tipografía profesional
- **📱 Mobile-First**: Optimizado para todos los dispositivos
- **⚡ Generación Automática**: Sistema de build completamente automatizado
- **🏷️ Posts Destacados**: Selección automática del último post con tag "destacado"
- **📊 SEO Optimizado**: Meta tags, Open Graph y estructura semántica
- **🔄 Sistema de Backups**: Protección automática de contenido original
- **📚 Documentación Completa**: Guías detalladas para uso y mantenimiento

## 🛠️ Tecnologías

- **Emacs org-mode**: Generación de contenido
- **org-publish**: Sistema de publicación estática
- **CSS3**: Estilos modernos y responsive
- **Bash**: Scripts de automatización
- **Git**: Control de versiones

## 🚀 Uso Rápido

### Construcción del Sitio
```bash
./build.sh
```

### Estructura del Proyecto
```
├── posts/              # Artículos del blog (.org)
├── css/               # Estilos (style.css)
├── img/               # Imágenes y assets
├── docs/              # Documentación
├── templates/         # Plantillas para nuevos posts
├── backups/           # Respaldos automáticos
├── publish.el         # Configuración org-publish
└── build.sh           # Script de construcción
```

### Crear un Nuevo Post

1. **Usar la plantilla**:
   ```bash
   cp templates/post-template.org posts/mi-nuevo-post.org
   ```

2. **Editar el contenido** en `posts/mi-nuevo-post.org`

3. **Añadir imagen** (opcional): `posts/mi-nuevo-post.png`

4. **Construir el sitio**:
   ```bash
   ./build.sh
   ```

## 📖 Estructura de Posts

Cada post debe seguir esta estructura:

```org
#+OPTIONS: toc:nil num:nil title:nil author:nil creator:nil html-postamble:nil html-preamble:nil
#+HTML_HEAD: <title>Título del Post</title>
#+HTML_HEAD: <link rel="stylesheet" type="text/css" href="../css/style.css" />
#+TITLE: Título del Post
#+DESCRIPTION: Descripción SEO del post
#+AUTHOR: Tu Nombre
#+DATE: 2025-07-26
#+TAGS: destacado, filosofía, etiquetas

#+HTML: <h1 class="site-title">Mi Blog de Filosofía</h1>
#+HTML: <div class="navigation"><p><a href="../index.html">Inicio</a> <a href="../about.html">Sobre Mí</a></p></div>
#+HTML: <div class="post-header-section">
#+HTML:   <h1 class="post-title">Título del Post</h1>
#+HTML:   <div class="post-meta">
#+HTML:     <span class="post-author">Tu Nombre</span>
#+HTML:     <span class="post-date">2025-07-26</span>
#+HTML:   </div>
#+HTML:   <img src="../img/nombre-imagen.png" alt="Imagen del artículo" class="post-header-image">
#+HTML: </div>

* Contenido del Post

Tu contenido aquí...

#+HTML: <div class="sidebar-section">
#+HTML:   <h3>Categorías</h3>
#+HTML:   <ul class="categories-list">
#+HTML:     <li><a href="#">Categoría 1 <span class="category-count">2</span></a></li>
#+HTML:   </ul>
#+HTML: </div>

#+HTML: <div class="footer"><p>Copyright © 2025 Tu Nombre. Creado con Emacs y org-mode.</p></div>
```

## 🏷️ Sistema de Posts Destacados

- **Tag "destacado"**: El último post con este tag aparece prominentemente en la home
- **Automático**: Se actualiza cada vez que ejecutas `./build.sh`
- **Flexible**: Simplemente añade o quita el tag según necesites

## 📁 Documentación Completa

- `docs/README-SISTEMA-COMPLETO.md`: Guía completa del sistema
- `docs/FEATURED-SYSTEM.md`: Cómo funciona el sistema de posts destacados
- `docs/SISTEMA-TEMPLATES-AUTOMATICO.md`: Sistema completo de templates y gestión de borradores

## 🔒 Seguridad y Backups

- **Backups automáticos**: Los posts originales se respaldan antes de cualquier procesamiento
- **No destructivo**: El sistema nunca modifica archivos originales
- **Versionado**: Uso de Git para control de versiones completo

## 🎯 Características Técnicas

- **Responsive Design**: Mobile-first con breakpoints optimizados
- **Accesibilidad**: Estructura semántica y navegación por teclado
- **Performance**: CSS optimizado y imágenes eficientes
- **SEO**: Meta tags, Open Graph, estructura de headings correcta
- **Mantenibilidad**: Código limpio y bien documentado

## Recomendación para imágenes de posts

Para que las imágenes de las entradas se vean perfectamente alineadas y sin espacios vacíos, utiliza imágenes con una relación de aspecto **5:4** (por ejemplo, 1000x800px, 500x400px, etc.).

- El diseño del blog recorta y escala automáticamente las imágenes, pero si la imagen original es muy panorámica o vertical, puede haber recortes inesperados o zonas sin cubrir.
- Para un resultado profesional y consistente, ajusta tus imágenes a 5:4 antes de subirlas.
- El CSS relevante es:

```css
.post-list-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
    object-position: center center;
    display: block;
}
```

Esto asegura que la imagen ocupe todo el espacio asignado en la lista de posts, igual que en blogs profesionales como el de la APA.

## 📝 Licencia

Este proyecto está bajo licencia MIT - ver el archivo LICENSE para detalles.

## 👤 Autor

**Joan Llopis** - [jllopis@gimlab.net](mailto:jllopis@gimlab.net)

---

*Generado con ❤️ usando Emacs org-mode*
