#lang scribble/manual

@(require (for-label atomichron
                     racket/base
                     racket/contract/base
                     racket/math
                     rebellion/base/symbol)
          (submod atomichron/private/scribble-evaluator-factory doc)
          scribble/examples)

@(define make-evaluator
   (make-module-sharing-evaluator-factory
    #:public (list 'atomichron)
    #:private (list 'racket/base)))

@title{Atomichron}
@defmodule[atomichron]

Atomichron is a microbenchmarking library. A @deftech{microbenchmark} is an
experiment that measures the performance of a very small and isolated piece of
code. Microbenchmarks are best used to test the performance of @emph{library}
code, not @emph{real world} code --- the performance of real world code is
determined by complex environmental factors and variables that a microbenchmark
cannot reproduce. Library code has to perform well in many different
environments so these environmental factors can usually be ignored.

As a general rule of thumb, @bold{never write a microbenchmark to measure code
 that performs IO}. This includes code that reads or writes files and code that
talks to other computers over the network. The performance of such operations
cannot be reliably reproduced or measured by Atomichron.

@defproc[(microbenchmark? [v any/c]) boolean?]{
 A predicate for @tech{microbenchmarks}.}

@defproc[(make-microbenchmark
          [#:iterations num-iterations exact-positive-integer?]
          [#:microexpression-iterations num-microexpression-iterations
           exact-positive-integer?]
          [#:microexpression-builder builder (-> natural? microexpression?)]
          [#:name name (or/c interned-symbol? #f) #f])
         microbenchmark?]{
 Constructs a @tech{microbenchmark} named @racket[name]. Running the
 microbenchmark will construct @racket[num-iterations] different @tech{
  microexpressions} using the @racket[builder] function. Then each
 microexpression is run @racket[num-microexpression-iterations] times and the
 total time for that microexpression is recorded. Microexpressions are run
 multiple times because for many microexpressions, a single run would take so
 little time that it would be difficult to accurately measure.

 @(examples
   #:eval (make-evaluator)
   (define num-iterations 100)
   (define size 1000)
   (define vec (build-vector size values))
   (define indices (build-vector num-iterations (λ (_) (random size))))
   (define vector-ref-benchmark
     (make-microbenchmark
      #:iterations num-iterations
      #:microexpression-iterations 1000
      #:microexpression-builder
      (λ (iteration)
        (define i (vector-ref indices iteration))
        (make-microexpression #:thunk (λ () (vector-ref vec i))))))
   (microbenchmark-run! vector-ref-benchmark))}

@defproc[(microbenchmark-run! [benchmark microbenchmark?])
         microbenchmark-result?]{
 Runs @racket[benchmark] and returns timing results.}

@defproc[(microbenchmark-result? [v any/c]) boolean?]{
 A predicate for microbenchmark results returned from @racket[
 microbenchmark-run!].}

@defproc[(microbenchmark-result
          [#:average-cpu-nanoseconds cpu-nanos
           (and/c rational? (not/c negative?))]
          [#:average-real-nanoseconds real-nanos
           (and/c rational? (not/c negative?))]
          [#:average-gc-cpu-nanoseconds gc-nanos
           (and/c rational? (not/c negative?))])
         microbenchmark-result?]{
 Constructs a microbenchmark result. This function is normally not called by
 users. Instead results are retrieved from @racket[microbenchmark-run!]. See
 @racket[time-apply] for an explanation of the differences between CPU time,
 real time, and GC CPU time.}

@defproc[(microbenchmark-result-average-cpu-nanoseconds
          [result microbenchmark-result?])
         (and/c rational? (not/c negative?))]{
 Returns the average number of nanoseconds of CPU processing time spent in
 evaluating a @tech{microexpression} once.}

@defproc[(microbenchmark-result-average-real-nanoseconds
          [result microbenchmark-result?])
         (and/c rational? (not/c negative?))]{
 Returns the average number of nanoseconds of real time that elapsed while
 evaluating a @tech{microexpression} once.}

@defproc[(microbenchmark-result-average-gc-cpu-nanoseconds
          [result microbenchmark-result?])
         (and/c rational? (not/c negative?))]{
 Returns the averages number of nanoseconds of CPU processing time spent on
 garbage collection while evaluating a @tech{microexpression} once. This time is
 included in @racket[microbenchmark-result-average-cpu-nanoseconds].}

@defproc[(microexpression? [v any/c]) boolean?]{
 A predicate for @tech{microexpressions}.}

@defproc[(make-microexpression [#:thunk thunk (-> any/c any)]
                               [#:name name (or/c interned-symbol? #f) #f])
         microexpression?]{
 Constructs a @deftech{microexpression}, which is a small and simple expression
 that is timed and executed repeatedly during a @tech{microbenchmark}. Running
 the constructed microexpression calls @racket[thunk]. See @racket[
 make-microbenchmark] for an example of how microbenchmarks construct
 microexpressions.}
