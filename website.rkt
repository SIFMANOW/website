#!/usr/bin/env racket
#lang at-exp racket/base

(require syntax/parse/define
         scribble/html/html
         (prefix-in html: scribble/html/extra)
         racket/format
         racket/dict
         racket/runtime-path
         racket/path
         racket/splicing
         (except-in scribble/html/lang read read-syntax)
         web-server/servlet-env
         web-server/dispatchers/dispatch
         pkg
         pkg/lib
         (for-syntax racket/base
                     racket/list
                     racket/string
                     racket/dict))

(provide (except-out (all-from-out scribble/html/lang)
                     #%module-begin)
         (rename-out [-module-begin #%module-begin])
         read read-syntax get-info
         page)

(define (header #:rest [rest '()] . v)
  @head{
    @meta[charset: "utf-8"]
    @meta[http-equiv: "X-UA-Compatible" content: "IE=edge"]
    @meta[name: "viewport" 'content: "width=device-width, initial-scale=1"]
    @;@link[rel: "stylesheet" type: "text/css" href: "/css/bootstrap.min.css"]
    @link[rel: "stylesheet" type: "text/css" href: "/css/custom.css"]
    @;@link[rel: "shortcut icon" href: "logo/tiny.png" type: "image/x-icon"]
    @link[rel: "stylesheet"
          href: "https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css"
          integrity: "sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm"
          crossorigin: "anonymous"]
    @script[src: "https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"]
    @script[src: "https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"
            integrity: "sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl"
            crossorigin: "anonymous"]
    @title[v]{ - SIF MA NOW}
    @rest})

(define (navbar . current-page)
  @html:header{
 @element["nav" class: "navbar navbar-expand-sm navbar-light bg-light"]{
  @a[class: "navbar-brand" href: (build-path "/" (car (dict-ref html-navbar-file-table "Home")))]{
   @img[src: "res/cropped-SIF-Logo-Cross-LOW-RES.jpg" alt: "logo"]}
  @ul[class: "navbar-nav"]{
   @(for/list ([title-pair (in-list html-navbar-file-table)])
      (define cur-page (equal? (car title-pair) (car current-page)))
      (define subs (caddr title-pair))
      @li[class: @~a{nav-item @(if cur-page
                                   "active"
                                   "")
                              @(if (null? subs)
                                   ""
                                   "dropdown")}]{
       @a[class: @~a{nav-link @(if (null? subs)
                                   ""
                                   "dropdown-toggle")}
          href: (if (or cur-page (not (null? subs))) "#" (build-path "/" (cadr title-pair)))
          @(unless (null? subs) data-toggle:)
          @(unless (null? subs) "dropdown")
          (car title-pair)]
       @(unless (null? subs)
          @div[class: "dropdown-menu"]{
            @(for/list ([item (in-list subs)])
               @a[class: "dropdown-item" href: (build-path "/" (cdr item)) (car item)])})})}}})

(define (footer #:rest [rest '()] . v)
  (list*
   @html:footer[class: "container"]{
     @div[class: "copyright"]{
       @p[style: "float:left"]{Copyright © 2019 ????}}}
   ;@script[src: "/js/bootstrap.min.js"]
   rest))

(define (page #:title title
              #:header-rest [header-rest '()]
              #:footer-rest [footer-rest '()]
              . content)
  (list @doctype{html}
        @html[lang: "en"]{
          @header[#:rest header-rest]{@title}
          @body[id: "pn-top"]{
            @navbar[title]
            @html:main[role: "main"]{@content}
            @footer[#:rest footer-rest]}}))

;; ===================================================================================================

;; Each entry in the file table is:
;; (Pair Name (Pair Path (Listof (Pair Subname AnchorPath))))
(module files-mod sml
  file-table list ()
  '("Home" "index.scrbl")
  '("Who we are" "about.scrbl")
  '("Our Work" "work.scrbl")
  '("Learn More" "learn.scrbl"
                 ("What do the experts say?" . "")
                 ("National news coverage" . "")
                 ("SIFMA NOW in the news" . "")
                 ("Videos" . ""))
  '("Latest Updates" "updates.scrbl")
  '("Contact Us" "contact.scrbl"))
(require 'files-mod
         (for-syntax 'files-mod))

(define-runtime-path-list files
  (map car (dict-values file-table)))

(define html-navbar-file-table
  (for/list ([(f v) (in-dict file-table)])
    (define path (path-replace-suffix (car v) ".html"))
    (list f path
          (for/list ([(k* v*) (in-dict (cdr v))])
            (cons k* (format "~a#~a" path v*))))))

;; ===================================================================================================

;; Assumes Racket 7, with minimal backwards support for v6.10+
(define-syntax (-module-begin stx)
  (syntax-parse stx
    [(_ body ...)
     (if (string-prefix? (version) "6.1")
         ;; Old version of racket, make a best effort attempt.
         #'(#%module-begin
            (define orig-url-roots (url-roots))
            (url-roots '(("" "/" abs)))
            body ...
            (url-roots orig-url-roots))
         #'(#%module-begin
            (require racket/splicing)
            (splicing-parameterize ([url-roots '(("" "/" abs))])
              body ...)))]))

(module reader syntax/module-reader
  #:read scribble:read-inside
  #:read-syntax scribble:read-syntax-inside
  #:whole-body-readers? #t
  #:info        reader-info
  #:language (build-path this-dir "website.rkt")

  (require (prefix-in scribble: scribble/reader)
           (only-in scribble/base/reader scribble-base-reader-info)
           (only-in racket/runtime-path define-runtime-path)
           (for-syntax (only-in racket/base #%datum)))
  
  (define base-reader-info (scribble-base-reader-info))
  (define (reader-info key defvalue default)
    (case key
      [(drracket:default-filters) (cons '("Scribble HTML" "*.shtml")
                                        (or (base-reader-info key defvalue default) '()))]
      [(drracket:default-extension) "shtml"]
      [else (base-reader-info key defvalue default)]))
  
  (define-runtime-path this-dir "."))
(require 'reader)

;; ===================================================================================================

(define-runtime-path project-root-dir ".")

(define (preview)
  (serve/servlet (lambda (_) (next-dispatcher))
                 #:servlet-path "/index.html"
                 #:extra-files-paths (list project-root-dir)
                 #:port (integer-bytes->integer #"LA" #f)
                 #:listen-ip #f
                 #:launch-browser? #t))

(define (build)
  (for ([f (in-list files)])
    (unless (equal? (path-get-extension f) #".html")
      (with-output-to-file (path-replace-suffix f ".html")
        #:exists 'replace
        (lambda ()
          (dynamic-require f 0))))))

(define deps '("sml"))

(define (install-deps)
  (for ([i (in-list deps)])
    (cond [(and (hash-has-key? (installed-pkg-table) i))
           (pkg-update-command #:deps 'search-auto i #:no-setup #t)]
          [else
           (pkg-install-command #:deps 'search-auto i #:no-setup #t)])))

(module+ main
  (require racket/cmdline)
  (void
   (command-line
    #:program "Leif Andersen Website"
    #:once-each
    [("-d" "--deps") "Install the required deps to build the website"
     (install-deps)]
    [("-b" "--build") "Build Website"
     (build)]
    [("-p" "--preview") "Preview Website"
     (preview)]
    )))
