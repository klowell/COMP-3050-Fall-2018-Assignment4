masm_mrd: mic1symasm_mult_rshift_div.o lex.yy.o
	gcc -o masm_mrd mic1symasm_mult_rshift_div.o lex.yy.o
mic1symasm_mult_rshift_div.o:  mic1symasm_mult_rshift_div.c
	gcc -c -g mic1symasm_mult_rshift_div.c
lex.yy.o:  lex.yy.c
	gcc -c -g lex.yy.c
lex.yy.c: mic1symasm_mult_rshift_div.ll
	flex mic1symasm_mult_rshift_div.ll
clean:
	rm lex.yy.o lex.yy.c mic1symasm_mult_rshift_div.o masm_mrd