#lang reader "website.rkt"

@(define (accordion . elements)
   (define ac-id (make-id))
   @div[class: "accordion" id: ac-id]{
    @(for/list ([e (in-list elements)])
       (define h-id (make-id))
       (define b-id (make-id))
       (list
        @div[class: "card"]{
         @div[class: "card-header" id: h-id]{
          @h2[class: "mb-0"]{
           @button[class: "btn btn-link"
                   type: "button"
                   data-toggle: "collapse"
                   data-target: (ref-id b-id)]{
            @(first e)}}}
         @div[id: b-id
              class: "collapse"
              data-parent: (ref-id ac-id)
              aria-labelledBy: (ref-id h-id)]{
          @div[class: "card-body"]{
           @(second e)}}}))})

@page[#:title "Learn More"]{

 @a[name: "experts"]
 @h1{What do the experts say?}
 @(accordion '("The American Medical Association"
               "Some More Text")
             '("The Lancet"
               "Some more more text"))
   

 @a[name: "national"]
 @h1{National news coverage}

 @a[name: "news"]
 @h1{SIFMA NOW in the news}

 @a[name: "videos"]
 @h1{Videos}
 
}
