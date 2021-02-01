#
# This makefile is for building the sample code and make sure it works
# (well, compiles).
#

.PHONY: build
build:
	dune build @install
	test -e bin || ln -s _build/install/default/bin

.PHONY: test
test:
	./bin/cmdliner-demo-arg . foo -j 99 bar --user-name mj
	./bin/cmdliner-demo-subcmd subcmd1
	./bin/cmdliner-demo-subcmd subcmd2 --bar

.PHONY: install
install:
	dune install

.PHONY: clean
clean:
	git clean -dfX
