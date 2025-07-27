# Sistema Dinámico de Artículo Destacado

## ¿Cómo funciona?

El sistema automáticamente selecciona el artículo destacado siguiendo esta lógica:

### 1. **Prioridad por Tag "destacado"**
Si un artículo tiene el tag `destacado` o `featured` en su campo `#+TAGS:`, será seleccionado como artículo destacado.

```org
#+TAGS: destacado, filosofía, reflexión
```

### 2. **Alternativa: Campo FEATURED**
También puedes usar un campo específico:

```org
#+FEATURED: true
```

### 3. **Fallback: Último artículo**
Si ningún artículo tiene tags de destacado, se mostrará automáticamente el artículo más reciente.

## Archivos generados automáticamente

- `featured-post.html` - Contiene el HTML del artículo destacado
- `post-list.html` - Contiene la lista de todos los posts

## Metadatos requeridos en posts

Para que el sistema funcione correctamente, cada post debe tener:

```org
#+TITLE: Título del artículo
#+DESCRIPTION: Descripción para SEO y lista de posts
#+AUTHOR: Nombre del autor
#+DATE: 2025-07-27
#+TAGS: etiquetas, separadas, por, comas
```

## Imágenes

- Cada post debe tener una imagen con el mismo nombre: `nombre-post.png`
- Las imágenes se copian automáticamente al directorio `public_html/img/`

## Ejemplo de uso

1. Para destacar un artículo nuevo, añádele el tag `destacado`
2. Para quitar el destaque, simplemente quita el tag
3. Ejecuta `./build.sh` y el cambio se aplicará automáticamente

¡El sistema es completamente dinámico y no requiere editar `index.org`!
