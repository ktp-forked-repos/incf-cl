(in-package :com.superadditive.incf-cl)

;;; Copyright (c) 2007 Juan M. Bello Rivas <jmbr@superadditive.com>
;;; 
;;; Permission is hereby granted, free of charge, to any person
;;; obtaining a copy of this software and associated documentation
;;; files (the "Software"), to deal in the Software without
;;; restriction, including without limitation the rights to use, copy,
;;; modify, merge, publish, distribute, sublicense, and/or sell copies
;;; of the Software, and to permit persons to whom the Software is
;;; furnished to do so, subject to the following conditions:
;;; 
;;; The above copyright notice and this permission notice shall be
;;; included in all copies or substantial portions of the Software.
;;; 
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
;;; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
;;; WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;;; DEALINGS IN THE SOFTWARE.

;;; Most of the docstrings are taken from A tour of the Haskell
;;; Prelude by Bernie Pope.

(defun break* (predicate list)
  "Given a PREDICATE and a LIST, breaks LIST into two lists (returned
as VALUES) at the point where PREDICATE is first satisfied.  If
PREDICATE is never satisfied then the first returned value is the
entire LIST and the second element is NIL."
  (span (complement predicate) list))

(defun drop (n list)
  "Applied to N (a non-negative integer) and LIST, returns the list
with the specified number of elements removed from the front of LIST.
If LIST has less than N elements then it returns NIL."
;;;   (nth-value 1 (split-at n list))
  (nthcdr n list))

(defun drop-while (predicate list)
  "Applied to PREDICATE and LIST, removes elements from the front of
LIST while PREDICATE is satisfied."
  (nth-value 1 (span predicate list)))
  
(defun flip (f)
  "Applied to a binary function F, returns the same function with the
order of the arguments reversed."
  (lambda (x y)
    (funcall f y x)))

(defun insert (x list &key (test #'<))
  "Inserts X before the first element in LIST which is greater than X.
The order relation can be specified by the keyword TEST"
  (multiple-value-bind (lt ge) (span (curry (flip test) x) list)
    (nconc lt (cons x ge))))

(defun replicate (n x)
  "Returns a list contaning N times the value X"
  (loop repeat n collect x))

(defun span (predicate list)
  "Splits LIST into two lists (returned as VALUES) such that elements
in the first list are taken from the head of LIST while PREDICATE is
satisfied, and elements in the second list are the remaining elements
from LIST once PREDICATE is not satisfied."
  (do ((list list (rest list))
       (xs nil (cons (first list) xs)))
      ((or (null list)
           (not (funcall predicate (first list))))
       (values (nreverse xs) list))))

(defun split-at (n list)
  "Given an integer N (positive or zero) and LIST, splits LIST into
two lists (returned as VALUES) at the position corresponding to the
given integer.  If the N is greater than the length of LIST, it
returns a tuple containing the entire list as its first element and
the empty list as its second element."
  (do ((list list (cdr list))
       (n n (1- n))
       (xs nil (cons (car list) xs)))
      ((or (zerop n)
           (null list))
       (values (nreverse xs) list))))

(defun take (n list)
  "Applied to the integer N and LIST, returns the specified number of
elements from the front of LIST.  If the sequence has less than N
elements, TAKE returns the entire sequence."
  (values (split-at n list)))

(defun take-while (predicate list)
  "Applied to PREDICATE and LIST, returns a list containing elements
from the front of LIST while PREDICATE is satisfied."
  (values (span predicate list)))