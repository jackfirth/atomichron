#lang info

(define collection "atomichron")

(define scribblings
  (list (list "main.scrbl"
              (list)
              (list 'library)
              "atomichron")))

(define deps
  (list "base"
        "rebellion"))

(define build-deps
  (list "racket-doc"
        "rackunit-lib"
        "scribble-lib"))
