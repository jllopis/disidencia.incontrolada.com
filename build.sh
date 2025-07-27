#!/bin/bash

# Salir inmediatamente si un comando falla
set -e

# Directorio de salida
OUTPUT_DIR="public_html"

echo "--- Limpiando el directorio de salida ---"
rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR
mkdir -p $OUTPUT_DIR/css
mkdir -p $OUTPUT_DIR/img
mkdir -p $OUTPUT_DIR/posts

echo "--- Copiando archivos estáticos ---"
# Copiar CSS
cp css/style.css $OUTPUT_DIR/css/

# Copiar todas las imágenes
for img in img/*.{png,jpg,jpeg,gif,webp,svg}; do
    if [ -f "$img" ]; then
        cp "$img" "$OUTPUT_DIR/img/"
        echo "Copiado: $img"
    fi
done

# Copiar imágenes de posts
for img in posts/*.{png,jpg,jpeg,gif,webp,svg}; do
    if [ -f "$img" ]; then
        img_name=$(basename "$img")
        cp "$img" "$OUTPUT_DIR/img/$img_name"
        echo "Copiado: $img a $OUTPUT_DIR/img/$img_name"
    fi
done

echo "--- Generando contenido dinámico ---"
emacs -batch -l publish.el

echo "--- Publicando con org-publish ---"
emacs -batch --eval "
(require 'org)
(require 'ox-publish)

(setq org-publish-project-alist
      '((\"gimlab-blog-posts\"
         :base-directory \"posts/\"
         :base-extension \"org\"
         :publishing-directory \"public_html/posts/\"
         :recursive t
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :auto-preamble t
         :section-numbers nil
         :with-toc nil
         :html-head \"<link rel=\\\"stylesheet\\\" href=\\\"../css/style.css\\\" type=\\\"text/css\\\" />\"
         :auto-sitemap t
         :sitemap-filename \"sitemap.org\"
         :sitemap-title \"Sitemap\"
         )

        (\"gimlab-static-pages\"
         :base-directory \".\"
         :base-extension \"org\"
         :publishing-directory \"public_html/\"
         :recursive nil
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :auto-preamble t
         :section-numbers nil
         :with-toc nil
         :html-head \"<link rel=\\\"stylesheet\\\" href=\\\"css/style.css\\\" type=\\\"text/css\\\" />\"
         :exclude \"posts/.*|README\\.org\"
         )

        (\"gimlab-blog\" :components (\"gimlab-blog-posts\" \"gimlab-static-pages\"))
        ))

(org-publish \"gimlab-blog\" t)
"

echo "--- Proceso completado ---"
echo "Sitio generado en $OUTPUT_DIR/"
