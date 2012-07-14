﻿; Y combinator allows us to write recursive code without
; mutating the environment.
(define Y 
    (lambda (m)
       (let z (lambda (f) (m (lambda (a) ((f f) a))))
	     (z z))))
; We could use the Y combinator here, but because we are defining
; 'length' using a define form, we can just recurse directly
(define (length list)
    (define length-tail
        ; Here, we make use of the "pattern matching" in lambda
        (lambda (so-far ()) so-far
                (so-far (x . y))
                    (length-tail (+ 1 so-far) y)))
    (length-tail 0 list))

(define (reverse l)
    (define reverse-tail
        (lambda (so-far ()) so-far
                (so-far (x . y))
                    (reverse-tail (cons x so-far) y)))
    (reverse-tail '() l))

(define (fold-right op initial xs)
    (define fold-right-tail
        (lambda (so-far ()) so-far
                (so-far (x . y)) (fold-right-tail (op x so-far) y)))
    (fold-right-tail initial (reverse xs)))

; mapcar can be defined in terms of fold
(define (mapcar f list)
    (let combiner
        (lambda (x list)
            (cons (f x) list))
        (fold-right combiner () list)))

(define (map f . ll)
    (define map-tail
        (lambda
            (f so-far (() . rest))
                so-far
            (f so-far ll)
                (map-tail f (cons (apply f (mapcar car ll)) so-far)
                            (mapcar cdr ll))))
    (reverse (map-tail f '() ll)))

(define-macro loop (var values . body)
    `(,reverse (,mapcar (,lambda (,var) (,begin ,@body)) (reverse ,values))))

; Explicit currying. It might be nicer to
; have implicit currying - but need to think
; about how best to implement first.
(define (curry fn . args)
    (lambda x
        (apply fn (append args x))))

(define (identity x) x)

(define (compose2 f g)
    (lambda (x)
        (f (g x))))
(define (compose . fns)
     (fold-right compose2 identity fns))

(define cadr (compose2 car cdr))
(define caddr (compose2 cadr cdr))
(define cdddr (compose cdr cdr cdr))

(define (find item list)
    (if (nil? list) list
        (eq? item (car list)) list
        (find item (cdr list))))

(define (after pivot list)
    (match (find pivot list)
           () ()
           (p . tail) tail))

; Not efficient - but
; it will do for now
(define (before pivot list)
    (reverse (after pivot (reverse list))))


(define-macro make-thunk args
    `(,lambda ()
        (,begin ,@args)))

(define (force thunk)
    (thunk))

(define-macro try clauses
    (with (body (before 'catch clauses)
           (ex-symbols . error-handler) (after 'catch clauses)
           c-symbol (gensym))
        `(,let/cc ,c-symbol
            (,execute-with-error-translator
                (,lambda ,ex-symbols (,c-symbol (,begin ,@error-handler)))
                (,make-thunk ,@body)))))

; A hygienic 'amb' macro.
;
; Using a factory function allows us to maintain
; the hygiene of 'amb-fail'.
; Use 'make-amb' to make an
; amb macro that you know won't interfere
; with anyone else's amb macro.

; The ability to do this - return a hygienically
; scoped 'amb' macro from a
; function, is something that is only possible
; in a Lisp with First Class macros and continuations
; (i.e. First Class Lisp!)
(define (make-amb error)
    (define amb-fail (curry error "exhausted"))
    (define (set-fail thunk)
        (set! amb-fail thunk))
    (define (get-fail)
        amb-fail)

    ; Based on
    ; http://c2.com/cgi/wiki/?AmbSpecialForm
    (define amb
        (define expand-amb (lambda
            ()  (list force (get-fail))
            (x) x
            (x y)
                (with (old-fail (gensym)
                       c (gensym))
                `(,let ,old-fail (,get-fail)
                    (,force
                        (,let/cc ,c
                            (,set-fail
                                (,make-thunk
                                    (,set-fail ,old-fail)
                                    (,c (,make-thunk ,y))))
                            (make-thunk ,x)))))
            (x . rest)
                `(,amb ,x (,amb ,@rest))))
     (macro expand-amb))
    amb)

; Given an amb macro, make an appropriate
; assert function. Once again, this sort of
; thing is only possible with first-class macros.
(define (make-assert amb)
    (lambda
        (#f) (amb)
        (condition) #t))

; Flatten a list of lists
(define flatten (curry apply append))
(define (stitch tuples element)
    (mapcar (curry cons element) tuples))
(define (cartesian l1 l2)
    (flatten (map (curry stitch l2) l1)))
(define cartesian-lists (curry fold-right cartesian '(())))
(define (cartesian-map f . lists)
    (map (curry apply f) (cartesian-lists lists)))
