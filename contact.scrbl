#lang reader "website.rkt"

@(define contact-table
   '(("Email"    "info@sifmanow.org")
     ("Phone"    "508-68-SIFMA")
     (""         "(508-687-4362)")
     ("Facebook" "@SIFMA Now")
     ("Twitter"  "@SIFMA_NOW")))

@page[#:title "Contact"]{
 @h1{Contact}
 @div[class: "container"]{
  @table[class: "table table-borderless"]{
   @tbody{
    @(for/list ([i (in-list contact-table)])
       @tr{@td{@(first i)} @td{@(second i)}})}}}}
