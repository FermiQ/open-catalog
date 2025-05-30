# PWR053: Consider applying vectorization to forall loop

### Issue

The loop containing a
[forall](../../Glossary/Patterns-for-performance-optimization/Forall.md) pattern
can be sped up using [vectorization](../../Glossary/Vectorization.md).

### Actions

Implement a version of the forall loop using an Application Program Interface
(API) that enables vectorization, such as OpenMP, or using compiler-specific
directives.

### Relevance

Vectorizing a loop is one of the ways to speed it up. Vectorization is widely
used in modern computers, but writing vectorized code is not straightforward.
Essentially, the programmer must explicitly specify how to execute the loop in
vector mode on the hardware, as well as add the appropriate synchronization to
avoid race conditions at runtime. Typically, the compiler does a good job in
vectorization, so the biggest challenge is to vectorize loops manually beyond
the capabilities of the compiler.

> [!NOTE]
> Vectorizing forall loops typically incurs less overhead than vectorizing scalar
> reduction loops. The main reason is that no synchronization is needed to avoid
> race conditions and ensure the correctness of the code. Note appropriate data
> scoping of shared and private variables is still a must.

### Code example

#### C

```c
void example(double *D, double *X, double *Y, int n, double a) {
  for (int i = 0; i < n; ++i) {
    D[i] = a * X[i] + Y[i];
  }
}
```

The loop body has a `forall` pattern, meaning that each iteration of the loop
can be executed independently and the result in each iteration is written to an
independent memory location. Thus, no race conditions can appear at runtime
related to array `D`, so no specific synchronization is needed.

The code snippet below shows an implementation that uses the OpenMP compiler
directives to vectorize the loop explicitly. Note how no synchronization is
required to avoid race conditions:

```c
void example(double *D, double *X, double *Y, int n, double a) {
  #pragma omp simd
  for (int i = 0; i < n; ++i) {
    D[i] = a * X[i] + Y[i];
  }
}
```

#### Fortran

```fortran
pure subroutine example(D, X, Y, a)
  use iso_fortran_env, only: real32
  implicit none
  real(kind=real32), intent(out) :: D(:)
  real(kind=real32), intent(in) :: X(:), Y(:)
  real(kind=real32), intent(in) :: a
  integer :: i

  do i = 1, size(D, 1)
    D(i) = a * X(i) + Y(i)
  end do
end subroutine example
```

The loop body has a `forall` pattern, meaning that each iteration of the loop
can be executed independently and the result in each iteration is written to an
independent memory location. Thus, no race conditions can appear at runtime
related to array `D`, so no specific synchronization is needed.

The code snippet below shows an implementation that uses the OpenMP compiler
directives to vectorize the loop explicitly. Note how no synchronization is
required to avoid race conditions:

```fortran
pure subroutine example(D, X, Y, a)
  use iso_fortran_env, only: real32
  implicit none
  real(kind=real32), intent(out) :: D(:)
  real(kind=real32), intent(in) :: X(:), Y(:)
  real(kind=real32), intent(in) :: a
  integer :: i

  !$omp simd
  do i = 1, size(D, 1)
    D(i) = a * X(i) + Y(i)
  end do
end subroutine example
```

### Related resources

* [PWR053 examples](https://github.com/codee-com/open-catalog/tree/main/Checks/PWR053/)

### References

* [Forall pattern](../../Glossary/Patterns-for-performance-optimization/Forall.md)

* [Vectorization](../../Glossary/Vectorization.md)
