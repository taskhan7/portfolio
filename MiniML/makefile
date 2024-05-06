all: evaluation expr miniml miniml_tests


evaluation: evaluation.ml
	ocamlbuild -use-ocamlfind evaluation.byte

expr: expr.ml
	ocamlbuild -use-ocamlfind expr.byte

miniml: miniml.ml
	ocamlbuild -use-ocamlfind miniml.byte
  
miniml_tests: miniml_tests.ml
	ocamlbuild -use-ocamlfind miniml_tests.byte

clean:
	rm -rf _build *.byte
