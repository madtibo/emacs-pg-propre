EMACS ?= emacs

# A space-separated list of required package names
DEPS = reformatter

INIT_PACKAGES="(progn \
  (require 'package) \
  (push '(\"melpa\" . \"https://melpa.org/packages/\") package-archives) \
  (package-initialize) \
  (dolist (pkg '(PACKAGES)) \
    (unless (package-installed-p pkg) \
      (unless (assoc pkg package-archive-contents) \
        (package-refresh-contents)) \
      (package-install pkg))) \
  )"

all: compile package-lint test clean-elc

package-lint:
	${EMACS} -Q --eval $(subst PACKAGES,package-lint ${DEPS},${INIT_PACKAGES}) -batch -f package-lint-batch-and-exit pg-propre.el

test:
	${EMACS} -Q --eval $(subst PACKAGES,${DEPS},${INIT_PACKAGES}) -batch -l pg-propre.el -l pg-propre-tests.el -f ert-run-tests-batch-and-exit

compile: clean-elc
	${EMACS} -Q --eval $(subst PACKAGES,${DEPS},${INIT_PACKAGES}) -L . -batch -f batch-byte-compile *.el

clean-elc:
	rm -f *.elc

.PHONY:	all compile clean-elc package-lint test
