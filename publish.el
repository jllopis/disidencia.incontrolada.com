;; -*- coding: utf-8; lexical-binding: t -*-
;;; publish.el --- Configuración simple y funcional
;;; Commentary: Fichero que genera html a partir de los ficheros org-mode extrayendo datos de los mismos

(require 'org)
(require 'ox-publish)
(require 'ox)
(require 'ox-html)

;; Function to find files with 'borrador' tag
(defun gimlab-get-draft-files ()
  "Get a list of files that contain the 'borrador' tag."
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

;; Function to generate exclude pattern for draft files
(defun gimlab-generate-exclude-pattern ()
  "Generate regex pattern to exclude draft files."
  (let ((draft-files (gimlab-get-draft-files)))
    (if draft-files
        (concat "\\(" (mapconcat 'regexp-quote draft-files "\\|") "\\)$")
      "borrador-ejemplo\\.org$"))) ; fallback pattern

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
                 (base-name (when input-file
                            (file-name-sans-extension (file-name-nondirectory input-file))))
                 (header-image (when base-name (gimlab-find-header-image base-name)))
                 (header-html (let ((raw-header (with-temp-buffer
                                                  (insert-file-contents (expand-file-name "header.html" (file-name-directory (or load-file-name buffer-file-name default-directory))))
                                                  (buffer-string))))
                               (cond
                                (is-post (replace-regexp-in-string "<!--RELATIVE-->" "../" raw-header))
                                (is-home (replace-regexp-in-string "<!--RELATIVE-->" "" raw-header))
                                (t raw-header))))
                 (footer-html (with-temp-buffer
                                (insert-file-contents (expand-file-name "footer.html" (file-name-directory (or load-file-name buffer-file-name default-directory))))
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
                     (format "    <div class=\"main-featured\">\n      <img src=\"../img/%s\" alt=\"Imagen del artículo\" class=\"post-header-image\">\n    </div>\n" header-image)
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

;; Helper function to find header image for a post
(defun gimlab-find-header-image (base-name)
  "Find the header image for a post based on its filename that comes in BASE-NAME."
  (when base-name
    ;; Buscar desde el directorio raíz del proyecto
    (let ((project-root (file-name-directory (or load-file-name buffer-file-name default-directory))))
      (cond
       ((file-exists-p (expand-file-name (format "posts/%s.png" base-name) project-root))
        (format "%s.png" base-name))
       ((file-exists-p (expand-file-name (format "posts/%s.jpg" base-name) project-root))
        (format "%s.jpg" base-name))
       ((file-exists-p (expand-file-name (format "img/%s.png" base-name) project-root))
        (format "%s.png" base-name))
       ((file-exists-p (expand-file-name (format "img/%s.jpg" base-name) project-root))
        (format "%s.jpg" base-name))
       (t nil)))))

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

;; Function to generate post list HTML for index page
(defun gimlab-generate-post-list-html ()
  "Generate HTML for the post list on the index page."
  (let ((posts '())
        (posts-dir (expand-file-name "posts" (file-name-directory (or load-file-name buffer-file-name default-directory))))
        (draft-pattern (gimlab-generate-exclude-pattern)))
    
    (when (file-directory-p posts-dir)
      (dolist (file (directory-files posts-dir t "\\.org$"))
        (let ((file-name (file-name-nondirectory file)))
          (unless (or (string-match-p draft-pattern file-name)
                      (string= file-name "sitemap.org"))
            (with-temp-buffer
              (insert-file-contents file)
              (goto-char (point-min))
              (let ((title "Sin título")
                    (date "")
                    (description "")
                    (author "")
                    (file-base (file-name-sans-extension file-name)))
                
                (when (re-search-forward "^#\\+TITLE:\\s-*\\(.+\\)$" nil t)
                  (setq title (string-trim (match-string 1))))
                
                (goto-char (point-min))
                (when (re-search-forward "^#\\+DATE:\\s-*\\(.+\\)$" nil t)
                  (setq date (string-trim (match-string 1))))
                
                (goto-char (point-min))
                (when (re-search-forward "^#\\+DESCRIPTION:\\s-*\\(.+\\)$" nil t)
                  (setq description (string-trim (match-string 1))))
                
                (goto-char (point-min))
                (when (re-search-forward "^#\\+AUTHOR:\\s-*\\(.+\\)$" nil t)
                  (setq author (string-trim (match-string 1))))
                
                (push (list :title title
                           :date date 
                           :description description 
                           :author author
                           :file-base file-base) posts))))))
    
    ;; Sort posts by date (newest first)
    (setq posts (sort posts (lambda (a b) 
                             (string> (plist-get a :date) (plist-get b :date)))))
    
    ;; Generate HTML with proper post-list structure
    (concat
     "<div class=\"post-list-container\">\n"
     (mapconcat (lambda (post)
                  (let* ((file-base (plist-get post :file-base))
                         (header-image (gimlab-find-header-image file-base)))
                    (format "<div class=\"post-list-item\">\n  <div class=\"post-list-image-wrapper\">\n    <a href=\"posts/%s.html\"><img src=\"img/%s\" alt=\"Imagen del artículo\" class=\"post-list-image\"></a>\n  </div>\n  <div class=\"post-list-content\">\n    <h3><a href=\"posts/%s.html\">%s</a></h3>\n    <div class=\"post-meta\"><strong>%s</strong> | %s</div>\n    <p class=\"post-list-summary\">%s</p>\n    <a href=\"posts/%s.html\" class=\"read-more-button\">Leer Más</a>\n  </div>\n</div>"
                            file-base
                            (or header-image "banner.png") ; fallback image
                            file-base
                            (plist-get post :title)
                            (or (plist-get post :author) "Autor")
                            (plist-get post :date)
                            (plist-get post :description)
                            file-base)))
                posts "\n")
     "\n</div>\n"))))

;; Set up the project structure with dynamic exclude pattern
(setq org-publish-project-alist
      `(("gimlab-blog-posts"
         :base-directory "posts/"
         :base-extension "org"
         :publishing-directory "public_html/posts/"
         :recursive t
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :auto-preamble t
         :section-numbers nil
         :with-toc nil
         :html-head "<link rel=\"stylesheet\" href=\"../css/style.css\" type=\"text/css\" />"
         :html-head-include-default-style nil
         :html-head-include-scripts nil
         :auto-sitemap t
         :sitemap-filename "sitemap.org"
         :sitemap-title "Sitemap"
         :exclude ,(gimlab-generate-exclude-pattern)
         :filter-body gimlab-post-body-filter)
        
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
         :html-head-include-scripts nil)
        
        ("gimlab-css"
         :base-directory "css/"
         :base-extension "css"
         :publishing-directory "public_html/css/"
         :recursive t
         :publishing-function org-publish-attachment)
        
        ("gimlab-img"
         :base-directory "img/"
         :base-extension "jpg\\|png\\|gif"
         :publishing-directory "public_html/img/"
         :recursive t
         :publishing-function org-publish-attachment)
        
        ("gimlab-posts-img"
         :base-directory "posts/"
         :base-extension "jpg\\|png\\|gif"
         :publishing-directory "public_html/img/"
         :recursive t
         :publishing-function org-publish-attachment)
        
        ("gimlab-blog"
         :components ("gimlab-blog-posts" "gimlab-static-pages" "gimlab-css" "gimlab-img" "gimlab-posts-img"))))

;; Regenerate post-list.html before publishing
(with-temp-file "post-list.html" 
  (insert (gimlab-generate-post-list-html)))

;; Publish the blog
(org-publish "gimlab-blog" t)

;; Show completion message
(message "Blog publicado exitosamente!")
(provide 'publish)
;;; publish.el ends here
