! (register-module! ./helper)
! (import! &self helper:expression-helpers)

;; the main constraint complement subtraction function
;; two parameteres - the point of application and the whole expression

(= (oneCcSub $poa $expr)
    (if (== $expr ())
        $expr
        (let* (
            ($poaGuardSet (getLiterals $poa))
            ($truthAndEl (checkForTerminalAnd $poa $expr))
            ($truthValue (car-atom $truthAndEl))
        )
        (if $truthValue
            (let $commonElements (cdr-atom $truthAndEl)
                (updatePoa $commonElements $poa $expr)
            )
            (collapse (let $x (superpose $expr)
                (if (== (get-metatype $x) Symbol)
                    $x
                    (if (== (getChildren $x) ())
                        $x
                        (oneCcSub $poa $x)
                    ))))))))

(= (invertLiterals $guardSet)
    (collapse (let $a (superpose $guardSet)
            (unify $a (NOT $x)
                $x
                (NOT $a)
                ))))

;; removes redundant () that result from the (cdr-atom) operation

(= (cleanExpr $expr)
    (if (== (cdr-atom $expr) ())
        (car-atom $expr)
        $expr
    )) 

;; get inner access to any level of nested structure and manipulate atoms

(= (innerAccess $expr)
    (collapse (let $el (superpose $expr)
            (if (and (== (get-metatype $el) Symbol) (not (== $el D)))
                $el
                (if (== $el D)
                    (superpose ())
                    (innerAccess $el)
                )))))
;; finds D and deletes it no matter where it is
;;! (innerAccess (AND B (AND (NOT B) (NOT C) D))) ;; (AND B (AND (NOT B) (NOT C))) -- D is deleted

(= (checkForTerminalAnd $poaGuard $expr)
    (if (== $expr ())
        (False)
        (let* (
            ($head (car-atom $expr))
            ($tail (cdr-atom $expr))
            )
            (if (isLiteral $head)
                (checkForTerminalAnd $poaGuard $tail)
                (if (and (== (car-atom $head) AND) (== (getChildren $head) ()))
                    (let* (
                        ($terminalGuardSet (invertLiterals (getGuardSet $head)))
                        ($commonElements (collapse (intersection (superpose $poaGuard) (superpose $terminalGuardSet))))
                        )
                        (if (== $commonElements ())
                            (checkForTerminalAnd $poaGuard $tail)
                            (True (cleanExpr $commonElements))
                        )
                    )
                    (checkForTerminalAnd $poaGuard $tail)
                )))))

;; once called updatePoa finds the poa and updates the children list (remove the common element(s))

(= (updatePoa $common $poa $expr)
    (collapse (let $el (superpose $expr)
        (if (expressionEquality $el $poa)
            (collapse (subtraction (superpose $poa) (superpose $common)))
            (if (or (== (get-metatype $el) Symbol) (isLiteral $el))
                $el
                (if (== (getChildren $el) ())
                    $el
                    (updatePoa $common $poa $el)
                ))))))

(= (expressionEquality $a $b)
    (let $diff (collapse (subtraction (superpose $a) (superpose $b)))
        (== $diff ())))

;; Test 01

! (assertEqual 
    (oneCcSub (AND B C) (AND B (AND B C) (AND (NOT B) D)))
        (AND B (AND C) (AND (NOT B) D)))

;; Test 02

! (assertEqual 
    (oneCcSub (AND B C) (AND B (OR (AND D) (AND B C)) (AND (NOT B) D)))  
        (AND B (OR (AND D) (AND C)) (AND (NOT B) D)))

;; Test 03

! (assertEqual 
    (oneCcSub (AND B C) (AND (AND B (OR (AND D) (AND B C))) (AND (NOT B) D))) 
        (AND (AND B (OR (AND D) (AND C))) (AND (NOT B) D)))

;; Test 04

! (assertEqual 
    (oneCcSub (AND (NOT B) C) (AND (AND B (OR (AND D) (AND (NOT B) C))) (AND B D))) 
        (AND (AND B (OR (AND D) (AND C))) (AND B D)))