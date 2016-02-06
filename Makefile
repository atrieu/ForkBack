.PHONY: all clean

all:
	ocamlbuild -use-ocamlfind test.native
clean:
	rm -rf _build
	rm -f test.native
