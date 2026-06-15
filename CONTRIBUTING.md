# Contributing to pg-propre.el

Thanks for your interest in improving `pg-propre.el`! Bug reports, patches, and
suggestions are all welcome.

## Reporting issues

Please open an issue describing:

- what you did (ideally a minimal SQL snippet and the command you ran),
- what you expected, and what happened instead,
- your Emacs version, `pg-propre` version, and the `pg_propre` binary version
  (`pg_propre --version`).

## Development setup

You need Emacs 26.1+, the `reformatter` package, and the `pg_propre` executable
on your `PATH` (`cargo install pg_propre`, or a prebuilt binary from the
[releases page](https://gitlab.com/madtibo/pg_propre/-/releases)).

The `Makefile` drives the checks (the `reformatter` dependency is installed from
MELPA automatically):

```bash
make compile       # byte-compile (must be warning-free)
make package-lint  # run package-lint
make test          # run the ERT suite (needs pg_propre on PATH)
```

Run a single test:

```bash
emacs -Q -batch -l pg-propre.el -l pg-propre-tests.el \
  --eval '(ert-run-tests-batch-and-exit "pg-propre-tests-format-buffer")'
```

Also run `M-x checkdoc` on `pg-propre.el` before submitting.

## Pull requests

- Keep every symbol prefixed with `pg-propre-` / `pg-propre--` so `package-lint`
  stays clean.
- Add or update ERT tests in `pg-propre-tests.el` for any behaviour change.
- Make sure `make compile package-lint test` and `checkdoc` are all clean.

## AI assistance

This package was developed with the assistance of
[Claude Code](https://claude.com/claude-code) (Anthropic's Claude). The initial
formatter wrapper, the Flymake backend, the test suite, and the project
scaffolding were generated with its help and reviewed by the maintainer.

If you contribute code that was generated or substantially assisted by an LLM,
please disclose it: add an `Assisted-by:` trailer to your commit message, e.g.

```
Assisted-by: Claude Code (Anthropic)
```

This mirrors the attribution policy in MELPA's
[CONTRIBUTING.org](https://github.com/melpa/melpa/blob/master/CONTRIBUTING.org#attribution-for-ai-generated-code).

## License

By contributing, you agree that your contributions will be licensed under the
project's [GPL-3.0-or-later](LICENSE) license.
