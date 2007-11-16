
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

(eval-when (:compile-toplevel :load-toplevel :execute)
  (asdf:oos 'asdf:load-op :incf-cl)
  (asdf:oos 'asdf:load-op :fiveam))

(defpackage #:com.superadditive.incf-cl-tests
  (:nicknames #:incf-cl-tests)
  (:use :common-lisp :incf-cl :5am))

(in-package :com.superadditive.incf-cl-tests)

(def-suite incf-cl-test-suite
    :description "Test suite for incf-cl.")

(in-suite incf-cl-test-suite)

(test drop
  (is (eq nil (drop 0 nil)))
  (is (eq nil (drop 1 nil)))
  (is (eq nil (drop -1 (list 1 2 3))))
  (is (equal (list 1 2 3) (drop 0 (list 1 2 3))))
  (is (equal nil (drop 3 (list 1 2 3)))))

(test drop-while
  (is (eq nil (drop-while (constantly t) nil)))
  (is (equal (list 1 2 3) (drop-while (constantly nil)
                                      (list 1 2 3)))))

(test flip
  (is (= (funcall (flip #'-) 1 2) 1))
  (is (= (funcall (flip #'-) 2 1) -1)))

(test replicate
  (is (eq nil (replicate -1 'x)))
  (is (eq nil (replicate 0 'x)))
  (is (equal (list 1 1 1) (replicate 3 1))))

(test starts-with
  (is (eq t (starts-with "Hello, world!" "Hell")))
  (is (eq nil (starts-with "Hello, world!" "Hola"))))

(test ends-with
  (is (eq t (ends-with "Hello, world!" "world!")))
  (is (eq nil (ends-with "Hello, world!" "world"))))

(test assemble
  (is (eq nil (assemble (constantly nil))))
  (is (equal (list 1 2 3) (assemble x (<- x (range 1 3)))))
  (is (equal (acons 0 0 (acons 0 1 (acons 1 0 (acons 1 1 nil))))
             (assemble (cons i j) (<- i '(0 1)) (<- j '(0 1))))))

(test hash-table->alist
  (is (equal (sort (hash-table->alist
                    (alist->hash-table
                     (pairlis '("one" "two" "three")
                              '(1 2 3))))
                   #'< :key #'cdr)
             (acons "one" 1 (acons "two" 2 (acons "three" 3) nil)))))

(run! 'incf-cl-test-suite)
