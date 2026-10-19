# my_configs
my local configs for emacs, shells, etc

## AWK tree-sitter grammar

The local Emacs configuration installs the AWK grammar automatically before
setting up `awk-ts-mode`, and skips installation when the grammar is loadable.
The first run requires Emacs with tree-sitter support, Git, a C compiler, and
network access to the grammar repository. Installation failures are reported
explicitly and retried on the next startup.

### Bootstrap tests

Run from the repository root (no network or grammar downloads):

```sh
mkdir -p build/test-home build/tmp
HOME="$PWD/build/test-home" TMPDIR="$PWD/build/tmp" \
  emacs -Q --batch -l tests/awk-bootstrap-tests.el -f ert-run-tests-batch-and-exit
```

The tests extract the AWK bootstrap and package declaration from `init.local.el`,
stub tree-sitter installation, and check runtime and byte-compilation ordering
without loading the rest of the configuration or Straight.
