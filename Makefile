.PHONY: all clean

all:
	ocamlbuild -use-ocamlfind test.native
	mv test.native server
	chmod +x server
clean:
	rm -rf _build
	rm -f test.native
