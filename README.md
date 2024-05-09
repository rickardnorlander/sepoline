# Sepoline

Sepoline is a trampoline for functions using the setjmp/longjmp mechanism for error handling. It calls a provided function and catches any longjmp. This is useful for ffi, as other languages calling into c are often unable to deal with longjmp unwinding the stack.

## Usage

See example.c

## Limitations

This implementation is quite limited. It works for x86-64 Linux. The processor must have the xsave instruction. The implementation is not threadsafe.
