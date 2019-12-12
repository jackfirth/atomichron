#lang scribble/manual

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
