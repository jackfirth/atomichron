#lang racket/base

(module doc racket/base

  (require racket/contract/base)

  (provide
   (contract-out
    [make-module-sharing-evaluator-factory
     (->* ()
          (#:private (listof module-path?)
           #:public (listof module-path?))
          (-> evaluator/c))]))

  (require racket/list
           scribble/example)

  ;@----------------------------------------------------------------------------

  (define evaluator/c (-> any/c any))

  (define (make-module-sharing-evaluator-factory
           #:public [public-modules empty]
           #:private [private-modules empty])
    (define base-factory
      (make-base-eval-factory (append private-modules public-modules)))
    (λ ()
      (define evaluator (base-factory))
      (evaluator `(require ,@public-modules))
      evaluator)))
