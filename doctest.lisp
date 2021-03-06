(cl:in-package #:incf-cl)

;;; Copyright (c) 2007-2010 Juan M. Bello Rivas <jmbr@superadditive.com>
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

(defvar *doctest-show-progress* t
  "Determines if a dot will be displayed for each passed test.")

(defmacro signals-p (condition &body body)
  "Returns T if evaluating BODY results in CONDITION being signalled,
NIL otherwise."
  `(typep (nth-value 1 (ignore-errors ,@body)) ',condition))

(define-condition doctest-failure ()
  ((sexpr :initarg :sexpr :reader sexpr)
   (actual-values :initarg :actual-values :reader actual-values)
   (expected-values :initarg :expected-values :reader expected-values))
  (:report (lambda (condition stream)
             (format stream "~s => ~{~a~^ ~} /= ~{~a~^ ~}"
                     (sexpr condition)
                     (actual-values condition)
                     (expected-values condition)))))

(defun test-docstring (documentation)
  "Returns T if the first doctest found in DOCUMENTATION passes,
signals DOCTEST-FAILURE otherwise."
  (with-input-from-string (input-stream documentation)
    (labels ((aux (_)
               (declare (ignore _))
               (read input-stream nil input-stream)))
      (let* ((sexpr (read input-stream))
             (actual-values (multiple-value-list (eval sexpr)))
             (expected-values (mapcar #'aux actual-values))
             (eof-pos (position-if (lambda (x)
                                     (eq input-stream x))
                                   expected-values)))
        (if (every #'equalp actual-values expected-values)
            t
            (signal 'doctest-failure
                    :sexpr sexpr
                    :actual-values actual-values
                    :expected-values (if eof-pos
                                         (subseq expected-values 0 eof-pos)
                                         expected-values)))))))

(defun test-function (package function stream)
  "Returns T if every test in FUNCTION's docstring passes, NIL
otherwise."
  (let* ((passed-p t)
         (*package* package)
         (package-name (package-name package))
         (re (concatenate 'string "[ \t]*" package-name "> "))
         (documentation (documentation function 'function))
         (matches (cl-ppcre:all-matches re documentation)))
    (loop for start in (rest matches) by #'cddr do
          (handler-case
              (when (test-docstring (subseq documentation start))
                (when *doctest-show-progress*
                  (princ #\. stream)))
            (end-of-file (_)
              (declare (ignore _))
              (format stream "~%MALFORMED TEST: ~a~%" function))
            (doctest-failure (condition)
              (format stream "~%FAILED TEST: ~a~%~a~%" function condition)
              (setf passed-p nil)))
          finally (return passed-p))))

(defun doctest (symbol &key (stream *standard-output*))
  "If SYMBOL corresponds to a function, then its documentation string
is tested and the results are printed to STREAM.  If SYMBOL refers to
a package, then all the functions corresponding to the external
symbols in the package are tested.  
DOCTEST returns T if the tests succeed, NIL otherwise."
  (flet ((get-package-and-function (symbol)
           (let ((package (find-package symbol)))
             (or package
                 (values (symbol-package symbol) symbol)))))
    (multiple-value-bind (package function) (get-package-and-function symbol)
      (if function
          (when (symbol-function function)
            (test-function package function stream))
          (every (lambda (x) (test-function package x stream))
                 (list-external-symbols package))))))
