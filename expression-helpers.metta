;; check membership of a symbol in an expression

(= (isMember $x $list)
    (not (== (collapse (intersection (superpose ($x)) (superpose $list))) ()))
)

;; Returns children of an Expression

(= (filterChildren $exp)
        (if (== (get-metatype $exp) Symbol)
            (empty)
            (if (== (car-atom $exp) NOT)
                (empty)
                $exp)
        ))

(= (getChildren $exp)
     (case $exp
       (
         (() $exp)
         ((NOT $x) ())
         ($else (if (== (get-metatype $exp) Expression) 
                (collapse (filterChildren (superpose $exp))) 
                ()
                )
        ))))

;; Return literal children of an expression

(= (getLiterals $exp)
     (case $exp
       (
         (() $exp)
         ((NOT $x) $exp)
         ($else (if (== (get-metatype $exp) Expression) (collapse (filterLiterals (superpose $exp))) $exp)))
    ))

;; Guard set of an AND expression
;(: getGuardSet (-> Expression Expression))

(= (getGuardSet $exp)
    (if (== (car-atom $exp) OR)
        ()
        (getLiterals $exp))
)


;(: filter (-> (-> $t Bool) Expression Expression))
(= (filter $func $expr)
    (collapse
        (let $result (
            let $non-det (superpose $expr)
                (case 
                    ($func $non-det)
                    ((True $non-det))
                )
                    )
            $result )))

;; identifies literals like A B (NOT A)

;; ignores AND, OR, (OR ..), (AND ..)

(= (isLiteral $atom)
    (if (or (== $atom AND) (== $atom OR))
        False
        (if (== (get-metatype $atom) Symbol)
            True
            (let $head (car-atom $atom)
                (if (== $head NOT)
                    True
                    False
                )))))

(= (filterLiterals $exp)
    (if (== (get-metatype $exp) Symbol)
        (if (or (== $exp AND) (== $exp OR)) (empty) $exp)
        (if (== (car-atom $exp) NOT)
            $exp
            (empty)
        )))