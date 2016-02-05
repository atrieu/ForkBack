.PHONY: all clean

all:
	ocamlbuild -pkg opium test.native

clean:
	rm -rf _build
