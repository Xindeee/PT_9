all: main.l main.y 
	bison -d -o main.tab.cc main.y 
	flex --debug -o lex.yy.cc main.l 
	g++ lex.yy.cc main.tab.cc -lfl -g 
	./a.out < test

clean: 
	rm main.tab.cc main.tab.hh
	rm lex.yy.cc
