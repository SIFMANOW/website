#lang reader "website.rkt"

@(define contact-table
   (list (list "Email"    "info@sifmanow.org")
         (list "Phone"    "508-68-SIFMA")
         (list ""         "(508-687-4362)")
         (list "Facebook" "@SIFMA Now")
         (list "Twitter"  @a[href: "https://twitter.com/SIFMA_NOW"]{@"@"SIFMA_NOW})))

@page[#:title "Contact"]{
 @h1{Contact}
 @div[class: "container"]{
  @table[class: "table table-borderless"]{
   @tbody{
    @(for/list ([i (in-list contact-table)])
       @tr{@td{@(first i)} @td{@(second i)}})}}}}
