// Check that TCO calls are preserved when callee always returns a constant
// RUN: clang -Oz -S -o - %s | FileCheck %s

void abort () __attribute__((noreturn));
int callee_return_const_0(int n, int *p) {
  for (int i = 0; i < 128; i++)
    if (p[i] != n)
      abort();

  return 0;
}

static volatile int n = 1;


// CHECK: caller:
// CHECK:   tail callee_return_const_0
int caller(void) {
  return callee_return_const_0(n + 2, (int *)&n);
}