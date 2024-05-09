// Copyright 2024 Rickard Norlander
// License: MIT

#include <setjmp.h>

int init_sepoline_lib();
void prepare_sepoline(void* fn, void* jmpbuf);
// Must be cast to correct signature before calling!
void sepoline(void);
int get_setjmp_ret();
