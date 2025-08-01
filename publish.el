;; -*- coding: utf-8; lexical-binding: t -*-
;;; publish.el --- Configuración simple y funcional
;;; Commentary: Fichero que genera html a partir de los ficheros org-mode extrayendo datos de los mismos

(require 'org)
(require 'ox-publish)
(require 'ox)
(require 'ox-html)

(defvar gimlab-project-root
  (file-name-directory (or load-file-name buffer-file-name default-directory)))

(setq user-full-name "Joan Llopis")

;; Function to find files with 'borrador' tag
(defun gimlab-get-draft-files ()
  "Get a list of files that contain the \='borrador\=' tag."
  (let ((draft-files '())
        (posts-dir (expand-file-name "posts" (file-name-directory (or load-file-name buffer-file-name default-directory)))))
    
    (when (file-directory-p posts-dir)
      (dolist (file (directory-files posts-dir t "\\.org$"))
        (with-temp-buffer
          (insert-file-contents file)
          (goto-char (point-min))
          (when (re-search-forward "^#\\+TAGS:\\s-*\\(.+\\)$" nil t)
            (let ((tags-string (match-string 1)))
              (when (string-match-p "\\bborrador\\b" tags-string)
                (push (file-name-nondirectory file) draft-files)))))))
    
    draft-files))

;; Function to generate exclude pattern for draft files and unwanted files
(defun gimlab-generate-exclude-pattern ()
  "Generate regex pattern to exclude draft files and files directly in posts/ directory."
  (let ((draft-files (gimlab-get-draft-files))
        ;; Archivos que están directamente en posts/ y no siguen la estructura YYYYMMDD/slug/
        (unwanted-files '("theindex.org" "theindex.inc" "borrador-ejemplo.org")))
    ;; Combinar archivos de borrador con archivos no deseados
    (let ((all-excluded-files (append draft-files unwanted-files)))
      (if all-excluded-files
          (concat "\\(" (mapconcat 'regexp-quote all-excluded-files "\\|") "\\)$")
        "borrador-ejemplo\\.org$\\|theindex\\..*")))) ; fallback pattern

;; Function to wrap post content with template structure

;; Función mejorada: reemplaza <!--RELATIVE--> por '../' en posts y por '' en la home
(defun gimlab-post-body-filter (content backend info)
  "Add the post body CONTENT being the BACKEND of html type. The entry fileneme comes in INFO."
  (when (eq backend 'html)
    (let* ((input-file (plist-get info :input-file))
           (is-post (and input-file (string-match-p "/posts/" input-file)))
           (is-home (and input-file (string-match-p "/index\\.org$" input-file))))
      (if (or is-post is-home)
          (let* ((title (org-export-data (plist-get info :title) info))
                 (author (org-export-data (plist-get info :author) info))
                 (date (org-export-data (plist-get info :date) info))
                 (header-image (when is-post (gimlab-find-header-image input-file)))
                 (header-html (let ((raw-header (with-temp-buffer
                          (insert-file-contents (expand-file-name "header.html" gimlab-project-root))
                                                  (buffer-string))))
                               (cond
                                (is-post (replace-regexp-in-string "<!--RELATIVE-->" "../" raw-header))
                                (is-home (replace-regexp-in-string "<!--RELATIVE-->" "" raw-header))
                                (t raw-header))))
                 (footer-html (with-temp-buffer
                (insert-file-contents (expand-file-name "footer.html" gimlab-project-root))
                                (buffer-string))))
            (if is-post
                (concat
                 header-html
                 "<div class=\"post-layout\">\n"
                 "  <div class=\"posts-column\">\n"
                 "    <div class=\"post-header-section\">\n"
                 "      <h1 class=\"post-title\">" title "</h1>\n"
                 "      <div class=\"post-meta\">\n"
                 "        <span class=\"post-author\">" author "</span>\n"
                 "        <span class=\"post-date\">" date "</span>\n"
                 "      </div>\n"
                 "    </div>\n"
                 (if header-image
                     (format
            "<div class=\"main-featured\">
          <img src=\"%s\" alt=\"%s\" class=\"post-header-image\" />
        </div>\n"
            header-image title)
           "")
                 "    <div class=\"post-content\">\n"
                 content
                 "    </div>\n"
                 "  </div>\n"
                 "  <div class=\"sidebar\">\n"
                 "  </div>\n"
                 "</div>\n"
                 footer-html)
              (concat
               header-html
               "<div class=\"main-columns\">\n"
               "  <div class=\"posts-column\">\n"
               content
               "  </div>\n"
               "</div>\n"
               footer-html)))
        content))))

(defun gimlab-find-header-image (post-file)
  "Busca un fichero portada.* en el directorio del post y devuelve su nombre."
  (when (and post-file (file-exists-p post-file))
    (let* ((post-dir (file-name-directory post-file))
           (exts     '("png" "jpg" "jpeg" "gif" "webp")))
      (catch 'found
        (dolist (ext exts)
          (let ((f (expand-file-name (format "portada.%s" ext) post-dir)))
            (when (file-exists-p f)
              (throw 'found (file-name-nondirectory f)))))
        nil))))

(require 'cl-lib)

;; Function to extract categories from all org files
(defun gimlab-extract-categories ()
  "Extract unique categories from all org files in posts directory."
  (let ((categories '())
        (posts-dir (expand-file-name "posts" (file-name-directory (or load-file-name buffer-file-name default-directory))))
        (draft-pattern (gimlab-generate-exclude-pattern)))
    
    (when (file-directory-p posts-dir)
      (dolist (file (directory-files posts-dir t "\\.org$"))
        (unless (string-match-p draft-pattern (file-name-nondirectory file))
          (with-temp-buffer
            (insert-file-contents file)
            (goto-char (point-min))
            (when (re-search-forward "^#\\+TAGS:\\s-*\\(.+\\)$" nil t)
              (let ((tags-string (match-string 1)))
                (dolist (tag (split-string tags-string "[, ]+" t))
                  (setq tag (string-trim tag))
                  (when (and (not (string-empty-p tag))
                           (not (string= tag "borrador")))
                    (cl-pushnew tag categories :test #'string=)))))))))
    
    (sort categories 'string<)))

;; Function to generate HTML for categories
(defun gimlab-generate-categories-html ()
  "Generate HTML list items for categories."
  (let ((categories (gimlab-extract-categories)))
    (mapconcat (lambda (category)
                 (format "      <li><a href=\"#\">%s</a></li>" category))
               categories "\n")))

(defun gimlab-org-has-tag-p (file tag)
  "Devuelve t si el archivo FILE tiene el TAG Org correspondiente
en un encabezado (* ... :tag:) o en la línea #+TAGS:."
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (let ((found nil))
      ;; Buscar encabezados con :tag:
      (while (and (not found)
                  (re-search-forward "^\\*+ .*?:\\([^:\n]+\\(?:[:][^:\n]+\\)*\\):" nil t))
        (let ((tag-list (split-string (match-string 1) ":" t)))
          (when (member tag tag-list)
            (setq found t))))
      ;; Buscar en #+TAGS:
      (goto-char (point-min))
      (when (and (not found)
                 (re-search-forward "^#\\+TAGS:[ \t]*\\(.+\\)" nil t))
        (let ((tag-list (split-string (match-string 1) "[, \t]+" t)))
          (when (member tag tag-list)
            (setq found t))))
      found)))

(defun gimlab-generate-post-list-html ()
  "Genera el HTML de la lista de posts para la página principal."
  (let ((posts '())
        (posts-dir (expand-file-name "posts" gimlab-project-root)))
    ;; Recorremos todos los .org bajo posts/
    (when (file-directory-p posts-dir)
      (dolist (file (directory-files-recursively posts-dir "\\.org$"))
        (let* ((rel-path (file-relative-name file posts-dir))
               (components (split-string rel-path "/" t)))
          ;; Mensajes de depuración
          (message "Encontrado: %s" file)
          (message "Components: %S" components)

          ;; Solo incluir si la ruta es YYYYMMDD/slug/index.org
          ;; Excluir archivos directamente en posts/ (como theindex.org, borrador-ejemplo.org, etc.)
          (when (and (= (length components) 3)
                     (string-match "^[0-9]\\{8\\}$" (nth 0 components))
                     (string= (nth 2 components) "index.org")
                     (not (gimlab-org-has-tag-p file "borrador")))
            (message ">>> INCLUIDO: %s" file)
            (with-temp-buffer
              (insert-file-contents file)
              (let ((title "Sin título")
                    (date "")
                    (description "")
                    (author "")
                    (file-base (file-name-sans-extension (file-relative-name file posts-dir)))
                    (img-html ""))
                (goto-char (point-min))
                (when (re-search-forward "^#\\+TITLE: \\(.*\\)" nil t)
                  (setq title (match-string 1)))
                (goto-char (point-min))
                (when (re-search-forward "^#\\+DATE: \\(.*\\)" nil t)
                  (setq date (match-string 1)))
                (goto-char (point-min))
                (when (re-search-forward "^#\\+AUTHOR: \\(.*\\)" nil t)
                  (setq author (match-string 1)))
                (goto-char (point-min))
                (when (re-search-forward "^#\\+DESCRIPTION: \\(.*\\)" nil t)
                  (setq description (match-string 1)))

                ;; Buscar portada.<ext> en el directorio del post
                (let* ((dir     (file-name-directory file))
                       ;; ruta relativa dentro de posts/, sin slash final
                       (rel-dir (directory-file-name
                                 (file-relative-name dir posts-dir)))
                       ;; extensiones a probar
                       (ext-cands '("jpg" "jpeg" "png" "webp" "gif"))
                       ;; buscamos la primera extensión que exista
                       (img-ext (seq-find
                                 (lambda (ext)
                                   (file-exists-p
                                    (expand-file-name
                                     (format "portada.%s" ext) dir)))
                                 ext-cands)))
                  ;; construimos img-html sólo si hemos encontrado portada.ext
                  (setq img-html
                        (if img-ext
                            (format
                             "<a href=\"posts/%s/index.html\"><img src=\"posts/%s/portada.%s\" alt=\"Portada del post\"></a>"
                             rel-dir   ;; enlace al índice del post
                             rel-dir   ;; ruta de la imagen
                             img-ext)  ;; extensión encontrada
                          "")))

                (let ((html
                       (format "<div class=\"post-list-item\">\n  <div class=\"post-list-image-wrapper\">%s</div>\n  <div class=\"post-list-content\">\n    <h3><a href=\"posts/%s.html\">%s</a></h3>\n    <div class=\"post-meta\"><strong>%s</strong> | %s</div>\n    <p class=\"post-list-summary\">%s</p>\n    <a href=\"posts/%s.html\" class=\"read-more-button\">Leer Más</a>\n  </div>\n</div>"
                               img-html
                               file-base
                               title
                               author
                               date
                               description
                               file-base)))
                  (message "HTML generado para %s: %s" file (substring html 0 (min 100 (length html))))
                  (push html posts))))))))

    ;; Devolver el HTML concatenado o cadena vacía si no hay posts
    (message "Total posts encontrados: %d" (length posts))
    (if posts
        (mapconcat #'identity (reverse posts) "\n")
      "")))

(defun gimlab-generate-featured-post-html ()
  "Genera el HTML para el post destacado (tag ‘destacado’) o, si no hay, el más reciente."
  (let* ((posts-dir (expand-file-name "posts" gimlab-project-root))
         ;; TODOS los index.org bajo posts/
         (files (directory-files-recursively posts-dir "^index\\.org$"))
         (post-list '()))
    ;; Recorrer cada index.org
    (dolist (file files)
      (let* ((dir      (file-name-directory file))
             ;; carpeta relativa: YYYYMMDD/mi-slug
             (rel-dir  (file-relative-name (directory-file-name dir) posts-dir))
             (components (split-string rel-dir "/" t)))
        ;; Solo procesar si sigue la estructura YYYYMMDD/slug
        (when (and (= (length components) 2)
                   (string-match "^[0-9]\\{8\\}$" (nth 0 components)))
          (let ((rel-url  (format "posts/%s/index.html" rel-dir))
                title date author tags img-path)
            ;; Leer metadatos
            (with-temp-buffer
              (insert-file-contents file)
              (goto-char (point-min))
              (setq title (or (and (re-search-forward "^#\\+TITLE:[ \t]*\\(.*\\)" nil t)
                                   (string-trim (match-string 1)))
                              "Sin título"))
              (goto-char (point-min))
              (setq date  (or (and (re-search-forward "^#\\+DATE:[ \t]*\\(.*\\)" nil t)
                                   (string-trim (match-string 1)))
                              rel-dir))
              (goto-char (point-min))
              (setq author (or (and (re-search-forward "^#\\+AUTHOR:[ \t]*\\(.*\\)" nil t)
                                   (string-trim (match-string 1)))
                              ""))
              (goto-char (point-min))
              (setq tags   (or (and (re-search-forward "^#\\+TAGS:[ \t]*\\(.*\\)" nil t)
                                   (string-trim (match-string 1)))
                              "")))
            ;; Buscar portada.<ext>
            (let* ((exts      '("jpg" "jpeg" "png" "webp" "gif"))
                   (found-ext (seq-find
                               (lambda (e)
                                 (file-exists-p
                                  (expand-file-name (format "portada.%s" e) dir)))
                               exts)))
              (when found-ext
                (setq img-path (format "/posts/%s/portada.%s" rel-dir found-ext))))
            ;; Añadir a la lista
            (push (list :title    title
                        :date     date
                        :author   author
                        :rel-url  rel-url
                        :img-path img-path
                        :tags     tags)
                  post-list)))))
    ;; Elegir destacado o, si no hay, el más reciente
    (let* ((featured
            (catch 'found
              (dolist (p post-list)
                (when (and (plist-get p :tags)
                           (string-match-p "\\bdestacado\\b" (plist-get p :tags)))
                  (throw 'found p)))
              nil))
           (post (or featured
                     ;; ordenar por fecha descendente
                     (car (sort post-list
                                (lambda (a b)
                                  (string> (plist-get a :date)
                                           (plist-get b :date))))))))
      (when post
        (format
         "<div class=\"latest-post-section\">\n  \
<a href=\"%s\"><img src=\"%s\" alt=\"Imagen del último artículo\" \
class=\"latest-post-image\"></a>\n  \
<div class=\"latest-post-overlay\">\n    \
<h2><a href=\"%s\">%s</a></h2>\n    \
<div class=\"post-meta\"><strong>%s</strong> | %s</div>\n  \
</div>\n</div>\n"
         ;; 1: enlace al post
         (plist-get post :rel-url)
         ;; 2: ruta de la imagen (o banner por defecto)
         (or (plist-get post :img-path) "/img/banner.png")
         ;; 3: enlace al post (para el título)
         (plist-get post :rel-url)
         ;; 4: título
         (plist-get post :title)
         ;; 5: autor
         (or (plist-get post :author) "Autor")
         ;; 6: fecha
         (plist-get post :date))))))

;; Set up the project structure with dynamic exclude pattern
(setq org-publish-project-alist
      `(
    ;; Publicar los posts
    ("gimlab-blog-posts"
         :base-directory "posts/"
         :base-extension "org"
         :publishing-directory "public_html/posts/"
         :recursive t
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :auto-preamble t
         :section-numbers nil
         :with-toc nil
         :html-head "<link rel=\"stylesheet\" href=\"/css/style.css\" type=\"text/css\" />"
         :html-head-include-default-style nil
         :html-head-include-scripts nil
         :exclude ,(gimlab-generate-exclude-pattern)
         :filter-body gimlab-post-body-filter)

    ;; Páginas estáticas
        ("gimlab-static-pages"
         :base-directory "./"
         :base-extension "org"
         :publishing-directory "public_html/"
         :exclude "posts/"
         :recursive nil
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :auto-preamble t
         :section-numbers nil
         :with-toc nil
         :html-head "<link rel=\"stylesheet\" href=\"css/style.css\" type=\"text/css\" />"
         :html-head-include-default-style nil
         :html-head-include-scripts nil
     :exclude "posts/.*\\|README\\.org\\|theindex\\..*"
         :makeindex nil)

    ("gimlab-sitemap"
     :base-directory "./"
     :base-extension "org"
     :publishing-directory "public_html/"
     :recursive nil
     :publishing-function org-html-publish-to-html
     :auto-sitemap t
     :sitemap-filename "sitemap.org"
     :sitemap-title "Sitemap"
     :exclude ".*"
     :include ("sitemap.org")
     :auto-preamble t
     :section-numbers nil
     :with-toc nil
     :html-head "<link rel=\"stylesheet\" href=\"/css/style.css\" type=\"text/css\" />"
     :html-head-include-default-style nil
     :html-head-include-scripts nil
     :filter-body (gimlab-post-body-filter)
     :filter-final-output (org-html-final-function))
    
        ("gimlab-css"
         :base-directory "css/"
         :base-extension "css"
         :publishing-directory "public_html/css/"
         :recursive t
         :publishing-function org-publish-attachment)

    ;; Imágenes globales
        ("gimlab-img"
         :base-directory "img/"
         :base-extension "jpg\\|jpeg\\|png\\|gif\\|webp\\|svg"
         :publishing-directory "public_html/img/"
         :recursive t
         :publishing-function org-publish-attachment
         :exclude "theindex\\..*")

    ;; Imágenes por post
        ("gimlab-posts-img"
         :base-directory "posts/"
         :base-extension "jpg\\|jpeg\\|png\\|gif\\|webp\\|svg"
         :publishing-directory "public_html/posts/"
         :recursive t
         :publishing-function org-publish-attachment)

    ;; Proyecto completo
        ("gimlab-blog" :components ("gimlab-blog-posts"
                                    "gimlab-static-pages"
                  "gimlab-sitemap"
                  "gimlab-css"
                                    "gimlab-img"
                                    "gimlab-posts-img"))
        ))

;;; Entradas para ejecución manual o en scripts

;; Regenerar post-list.html antes de publicar
;; (with-temp-file "post-list.html"
;;  (insert (gimlab-generate-post-list-html)))

;; Regenerar featured-post.html antes de publicar
;; (with-temp-file "featured-post.html"
;;   (let ((featured (gimlab-generate-featured-post-html)))
;;     (if featured
;;         (insert featured)
;;       (insert "<div class=\"latest-post-section\">No hay post destacado.</div>"))))

;; Publicación incremental (sólo archivos modificados)
;; (org-publish "gimlab-blog" t)

;; Para forzar publicación completa:
;; (org-publish "gimlab-blog" t)

(defun gimlab-build-and-publish ()
  "Genera contenido dinámico y publica el blog."
  (with-temp-file "post-list.html"
    (insert (gimlab-generate-post-list-html)))
  (with-temp-file "featured-post.html"
    (let ((featured (gimlab-generate-featured-post-html)))
      (if featured
          (insert featured)
        (insert "<div class=\"latest-post-section\">No hay post destacado.</div>"))))
  (org-publish "gimlab-blog" t))

;; Show completion message
(message "Blog publicado exitosamente!")
(provide 'publish)

;;; publish.el ends here
