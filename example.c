#include <setjmp.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "sepoline.h"

int function_that_can_fail(const char* s, jmp_buf jb) {
  printf("%s\n", s);
  srand(time(0));
  if ((rand() & 1) == 0) {
    longjmp(jb, 0xBADB01);
  }
  return 123;
}

// Should match function_that_can_fail
typedef int (*my_sepoline_signature)(const char*, jmp_buf);

int main () {
  jmp_buf jb;
  int init_result = init_sepoline_lib();
  if (init_result) {
    printf("Failed to initialize sepoline lib: %d\n", init_result);
    return 1;
  }
  prepare_sepoline(function_that_can_fail, jb);
  int function_result = ((my_sepoline_signature)sepoline)("Processing...", jb);
  int setjmp_result = get_setjmp_ret();
  if (setjmp_result == 0) {
    printf("Function finished successfully! Result: %d\n", function_result);
  } else {
    printf("Function failed! Failure code: 0x%X\n", setjmp_result);
  }
}
