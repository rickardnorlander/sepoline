sepoline.so: sepoline.o
	gcc -shared -o sepoline.so sepoline.o

sepoline.o: sepoline.asm
	nasm -f elf64 sepoline.asm

run: example
	./example

example: sepoline.o example.o
	gcc -o example sepoline.o example.o

example_dynamic_linked: sepoline.so example.o
	gcc -o example_dynamic_linked example.o ./sepoline.so

example.o: example.c
