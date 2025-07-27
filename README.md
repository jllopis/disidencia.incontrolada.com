# Disidencia Incontrolada

## Descripción

Blog generado con **Emacs org-publish**, diseñado para publicar artículos de poco interés, con un diseño moderno, responsive y mantenible.

Puede servir de modelo para quien quiera publicar un blog de manera sencilla a partir de [org-mode](https://orgmode.org/org.html) y un poquito de `elisp`para añadir funcionalidad.

## Características

- **Diseño Moderno**: CSS responsive con tipografía profesional
- **Mobile-First**: Optimizado para todos los dispositivos
- **Generación Automática**: Sistema de build completamente automatizado
- **Posts Destacados**: Selección automática del último post con tag "destacado"
- **SEO Optimizado**: Meta tags, Open Graph y estructura semántica
- **Sistema de Backups**: Protección automática de contenido original
- **Documentación Completa**: Guías detalladas para uso y mantenimiento

## Tecnologías

- **Emacs org-mode**: Generación de contenido
- **org-publish**: Sistema de publicación estática
- **Emacs Lisp**: Personalización de la generación
- **CSS3**: Estilos modernos y responsive
- **Bash**: Scripts de automatización
- **Git**: Control de versiones

## Uso Rápido

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
├── publish.el         # Configuración org-publish
└── build.sh           # Script de construcción
```

### Crear un Nuevo Post

1. **Usar la plantilla**:
   ```bash
   cp templates/post-template.org posts/mi-nuevo-post.org
   ```

2. **Editar el contenido** en `posts/mi-nuevo-post.org`

3. **Añadir imagen**:
La imagen se muestra con el artículo y debe estar presente en el directorio `img/`. Por convenio, toma el mismo nombre que el post con la extensión del tipo de imagen.

En el ejemplo sería `img/mi-nuevo-post.png`

4. **Construir el sitio**:
   ```bash
   ./build.sh
   ```

5. **Publicar**:

Como se utiliza Github Pages, existe el fichero `.github/workflows/deploy.yml`que contiene las instrucciones para el despliegue en github. Esto se realiza del modo habitual: `git push`😊

## Estructura de Posts

Cada post debe seguir esta estructura (`templates/post-template.org`):

```org
#+OPTIONS: toc:nil num:nil title:nil author:nil creator:nil html-postamble:nil html-preamble:nil
#+HTML_HEAD: <title>Título del Post</title>
#+HTML_HEAD: <link rel="stylesheet" type="text/css" href="../css/style.css" />
#+TITLE: Título del Post
#+DESCRIPTION: Descripción SEO del post
#+AUTHOR: Tu Nombre
#+DATE: 2025-07-26
#+TAGS: destacado, filosofía, etiquetas

#+COMMENT: RELACIÓN DE ASPECTO DE IMÁGENES
#+COMMENT: Para una visualización perfecta en la lista de posts, usa imágenes con relación de aspecto 5:4 (ejemplo: 1000x800px, 500x400px, etc.).
#+COMMENT: El CSS fuerza el recorte y escalado, pero la relación 5:4 evita espacios vacíos o recortes indeseados.

* Introducción

Aquí va el contenido principal del post. Puedes usar todas las funcionalidades de org-mode:

- Listas
- *Texto en negrita*
- /Texto en cursiva/
- =Código inline=

** Subsección

Puedes añadir subsecciones para organizar mejor el contenido.

* Conclusiones

Resumen final del artículo.

#+BEGIN_COMMENT
INSTRUCCIONES PARA USAR ESTE TEMPLATE:

1. Copia este archivo: cp templates/post-template.org posts/mi-nuevo-post.org
2. Edita el TITLE, DESCRIPTION, AUTHOR, DATE y TAGS
3. Si tienes una imagen, nómbrala igual que el archivo: mi-nuevo-post.png
4. Escribe tu contenido usando sintaxis org-mode
5. Ejecuta ./build.sh para generar el sitio

El template automáticamente añadirá:
- Header del sitio y navegación
- Metadata del post (autor, fecha)
- Imagen de cabecera (si existe)
- Sidebar con categorías
- Footer del sitio

#+END_COMMENT
```

## Sistema de Posts Destacados

- **Tag "destacado"**: El último post con este tag aparece prominentemente en la home
- **Automático**: Se actualiza cada vez que ejecutas `./build.sh` desde la función implementada en `publish.el`
- **Flexible**: Simplemente añade o quita el tag según necesites

## Documentación Completa

- `docs/README-SISTEMA-COMPLETO.md`: Guía completa del sistema
- `docs/FEATURED-SYSTEM.md`: Cómo funciona el sistema de posts destacados
- `docs/SISTEMA-TEMPLATES-AUTOMATICO.md`: Sistema completo de templates y gestión de borradores

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

## Licencia

Este proyecto está bajo licencia MIT - ver el archivo LICENSE para detalles.

## Autor

- **Joan Llopis**
- **LLM**

---

*Generado con ❤️ usando Emacs org-mode*
