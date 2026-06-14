;;; pg-propre-tests.el --- Test suite for pg-propre  -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Thibaut Madelaine

;; Author: Thibaut Madelaine
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; A few basic regression tests.  The formatting tests require the
;; `pg_propre' executable to be on `PATH'; the diagnostic-parsing test
;; does not.

;;; Code:

(require 'pg-propre)
(require 'ert)

;;; Formatter (require the pg_propre binary)

(ert-deftest pg-propre-tests-format-buffer ()
  (skip-unless (executable-find pg-propre-command))
  (with-temp-buffer
    (insert "select a,b from t where x=1\n")
    (pg-propre-format-buffer)
    (should (equal "SELECT a, b FROM t WHERE x = 1\n" (buffer-string)))))

(ert-deftest pg-propre-tests-format-region ()
  (skip-unless (executable-find pg-propre-command))
  (with-temp-buffer
    (insert "select a,b from t where x=1\n")
    (pg-propre-format-region (point-min) (point-max))
    (should (equal "SELECT a, b FROM t WHERE x = 1\n" (buffer-string)))))

(ert-deftest pg-propre-tests-format-with-style-arg ()
  (skip-unless (executable-find pg-propre-command))
  (let ((pg-propre-args '("--style" "comma-first")))
    (with-temp-buffer
      (insert (concat "insert into customer values "
                      "(101,'regress_alice','+81-12-3456-7890','passwd123'),"
                      "(102,'regress_bob','+01-234-567-8901','beafsteak');\n"))
      (pg-propre-format-buffer)
      ;; comma-first puts the comma at the start of each continuation line.
      (should (string-match-p "^, (102," (buffer-string))))))

;;; Diagnostic parsing (no binary required)

(ert-deftest pg-propre-tests-parse-warning ()
  (with-temp-buffer
    (insert "SELECT count (*) FROM t;\n")
    (let* ((output (concat "<stdin>:1:13: warning: "
                           "No space before function call parenthesis. [LT06]\n"))
           (diags (pg-propre--parse-diagnostics output (current-buffer))))
      (should (= 1 (length diags)))
      (let ((d (car diags)))
        (should (eq :warning (flymake-diagnostic-type d)))
        (should (string-match-p "LT06" (flymake-diagnostic-text d)))))))

(ert-deftest pg-propre-tests-parse-error ()
  (with-temp-buffer
    (insert "SELECT x.a FROM t;\n")
    (let* ((output (concat "<stdin>:1:8: error: "
                           "reference 'x' not found in FROM clause [query 1, RF01]\n"))
           (diags (pg-propre--parse-diagnostics output (current-buffer))))
      (should (= 1 (length diags)))
      (should (eq :error (flymake-diagnostic-type (car diags)))))))

(ert-deftest pg-propre-tests-parse-multiple-and-clean ()
  (with-temp-buffer
    (insert "select * from users where id=1;\nSELECT FROM;\n")
    (let* ((output (concat "<stdin>:1:1: warning: Line differs from formatted version. [LT00]\n"
                           "<stdin>:2:8: error: Invalid statement [query 2, line 2]\n"))
           (diags (pg-propre--parse-diagnostics output (current-buffer))))
      (should (= 2 (length diags))))
    ;; Lines that are not diagnostics must be ignored.
    (should (null (pg-propre--parse-diagnostics "note: nothing here\n" (current-buffer))))))

(provide 'pg-propre-tests)
;;; pg-propre-tests.el ends here
