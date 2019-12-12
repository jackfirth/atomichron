#lang racket/base

(require racket/contract/base)

(provide
 (contract-out
  [microbenchmark? predicate/c]
  [make-microbenchmark
   (->* (#:iterations exact-positive-integer?
         #:microexpression-iterations exact-positive-integer?
         #:microexpression-builder (-> natural? microexpression?))
        (#:name interned-symbol?)
        microbenchmark?)]
  [microbenchmark-result
   (-> #:average-cpu-nanoseconds nonnegative-rational?
       #:average-real-nanoseconds nonnegative-rational?
       #:average-gc-cpu-nanoseconds nonnegative-rational?
       microbenchmark-result?)]
  [microbenchmark-result? predicate/c]
  [microbenchmark-result-average-cpu-nanoseconds
   (-> microbenchmark-result? nonnegative-rational?)]
  [microbenchmark-result-average-real-nanoseconds
   (-> microbenchmark-result? nonnegative-rational?)]
  [microbenchmark-result-average-gc-cpu-nanoseconds
   (-> microbenchmark-result? nonnegative-rational?)]
  [microexpression? predicate/c]
  [make-microexpression
   (->* (#:thunk (procedure-arity-includes/c 0))
        (#:name interned-symbol?)
        microexpression?)]))

(require racket/math
         rebellion/base/symbol
         rebellion/collection/list
         rebellion/type/record
         rebellion/type/reference)

;@------------------------------------------------------------------------------

(define nonnegative-rational? (and/c rational? (>=/c 0)))

(define-reference-type microexpression (thunk))

(define-reference-type microbenchmark
  (iterations microexpression-iterations microexpression-builder))

(define-record-type microbenchmark-result
  (average-cpu-nanoseconds
   average-real-nanoseconds
   average-gc-cpu-nanoseconds))

(define num-nanoseconds-per-millisecond 1000000)

(define (compute-microbenchmark-result
         #:total-cpu-milliseconds cpu-ms
         #:total-real-milliseconds real-ms
         #:total-gc-cpu-milliseconds gc-cpu-ms
         #:iterations iterations
         #:microexpression-iterations microexpression-iterations)
  (define (compute-average-nanos total)
    (* (/ total iterations microexpression-iterations)
       num-nanoseconds-per-millisecond))
  (microbenchmark-result
   #:average-cpu-nanoseconds (compute-average-nanos cpu-ms)
   #:average-real-nanoseconds (compute-average-nanos real-ms)
   #:average-gc-cpu-nanoseconds (compute-average-nanos gc-cpu-ms)))

(define (microbenchmark-run! benchmark)
  (define iterations (microbenchmark-iterations benchmark))
  (define microexpression-iterations (microbenchmark-iterations benchmark))
  (define builder (microbenchmark-microexpression-builder benchmark))
  (for/fold ([total-cpu-milliseconds 0]
             [total-real-milliseconds 0]
             [total-gc-cpu-milliseconds 0]
             #:result
             (compute-microbenchmark-result
              #:total-cpu-milliseconds total-cpu-milliseconds
              #:total-real-milliseconds total-real-milliseconds
              #:total-gc-cpu-milliseconds total-gc-cpu-milliseconds
              #:iterations iterations
              #:microexpression-iterations microexpression-iterations))
            ([n (in-range iterations)])
    (define expr-thunk (microexpression-thunk (builder n)))
    (define-values (_ cpu-milliseconds real-milliseconds gc-cpu-milliseconds)
      (time-apply
       (λ () (for ([_ (in-range microexpression-iterations)]) (expr-thunk)))
       empty-list))
    (values (+ total-cpu-milliseconds cpu-milliseconds)
            (+ total-real-milliseconds real-milliseconds)
            (+ total-gc-cpu-milliseconds gc-cpu-milliseconds))))
