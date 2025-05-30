# PWR075: Avoid using compiler-specific Fortran extensions

### Issue

Using compiler-specific extensions, such as those provided by GNU's `gfortran`
or Intel's `ifort` and `ifx`, compromises the portability and consistency of
code across different development environments.

### Actions

Refactor the code to replace existing compiler-specific extensions with
standard-compliant Fortran code. The specific steps for refactoring will depend
on the particular features being replaced.

### Relevance

Fortran compilers often extend their support beyond the Fortran standard by
introducing additional language features. While these extensions can provide
enhanced functionality and convenience for programmers, they also present
significant drawbacks.

Even though some extensions may be supported by multiple compilers, there will
inevitably be environments where the code is not compilable, complicating
future maintenance. Additionally, even when multiple vendors support the same
extension, its behavior can vary, as these features are not regulated by the
Fortran standard. Ultimately, Fortran code that depends on compiler-specific
extensions cannot be guaranteed to be portable and consistent across different
development environments.

This issue is particularly problematic when inheriting legacy code. If the code
relies on compiler-specific extensions from a now unsupported or inaccessible
compiler version, developers are forced to port the code to new environments,
further complicating the already challenging task of maintaining legacy code.

Some compiler-specific extensions include:

- GNU Fortran: shadowing host entities in internal procedures, forward
referencing symbols in the specification part, or using `REAL` expressions in
array subscripts.

- Intel Fortran: calling functions as if they were subroutines, allowing
`DATA` statements that do not fully initialize arrays or derived types, or
accessing arrays beyond their declared bounds without triggering any semantic
errors.

For more information on which extensions are implemented by different compilers,
see the **References** section below for links to their official documentation.

### Code examples

#### GNU Fortran extension

Consider the following code, which checks if the file itself exists:

```fortran
! example-gnu.f90
program example
  implicit none
  character(len = *), parameter :: file  = "example-gnu.f90"

  if(access(file, " ") == 0) then
    print *, "I exist"
  end if
end program example
```

This code uses
[`access()`](https://gcc.gnu.org/onlinedocs/gfortran/ACCESS.html), a GNU
Fortran extension that compiles successfully with `gfortran`:

```txt
$ gfortran --version
GNU Fortran (Debian 14.2.0-3) 14.2.0
$ gfortran example-gnu.f90 -o example-gnu
$ ./example-gnu
 I exist
```

However, the same code fails to compile with LLVM's `flang` compiler:

```txt
$ flang-new-18 --version
Debian flang-new version 18.1.8 (9)
$ flang-new-18 example-gnu.f90 -o example-gnu
error: Semantic errors in example-gnu.f90
./example.f90:7:6: error: No explicit type declared for 'access'
    if(access(file, " ") == 0) then
       ^^^^^^
```

To resolve this issue, the programmer needs to provide a replacement for the
functionality of the GNU extension. Fortunately, the Fortran standard provides
the built-in
[`inquire`](https://www.intel.com/content/www/us/en/docs/fortran-compiler/developer-guide-reference/2024-2/inquire.html#GUID-D0115A20-D0BD-4B0F-92A5-F6CB6D2E985C):

```fortran
! solution-gnu.f90
program solution
  implicit none
  character(len = *), parameter :: file  = "solution-gnu.f90"
  logical :: exists

  inquire(file=file, exist=exists)

  if(exists) then
    print *, "I exist"
  end if
end program solution
```

This revised code compiles and runs successfully with `flang`:

```txt
$ flang-new-18 solution-gnu.f90 -o solution-gnu
$ ./solution-gnu
 I exist
```

#### Intel Fortran extension

Consider the following code:

```fortran
! example-intel.f90
program main
  implicit none

  type :: foo_t
    integer :: x
  end type

  type(foo_t) :: foo(2)
  integer :: bar(2)

  data foo%x /1/
  data bar /1/

  print *, foo
  print *, bar
end
```

This code relies on an Intel Fortran extension that allows `DATA` statements to
partially initialize arrays or derived types. In this case, only the first
element of `foo%x` and `bar` is initialized explicitly, while the remaining
elements are implicitly zero-initialized.

When compiled with Intel's `ifx` compiler, the program produces:

```txt
$ ifx --version
ifx (IFX) 2024.0.0 20231017
Copyright (C) 1985-2023 Intel Corporation. All rights reserved.
$ ifx example-intel.f90 -o example-intel
$ ./example-intel
           1           0
           1           0
```

By contrast, compilers that follow the Fortran standard strictly reject the
code:

```txt
$ flang-new-18 --version
Debian flang-new version 18.1.8 (9)
$ flang-new-18 example-intel.f90 -o example-intel
error: Semantic errors in example-intel.f90
example-intel.f90:13:3: error: DATA statement set has no value for 'foo(2_8)%x'
    data foo%x /1/
    ^^^^^^^^^^^^^^
example-intel.f90:14:3: error: DATA statement set has no value for 'bar(2_8)'
    data bar /1/
    ^^^^^^^^^^^^
```

To make the code portable and accepted by all standard-compliant Fortran
compilers, each element of the arrays and derived types must be explicitly
initialized. The corrected version of the program is:

```fortran
! solution-intel.f90
program main
  implicit none

  type :: foo_t
    integer :: x
  end type

  type(foo_t) :: foo(2)
  integer :: bar(2)

  data foo%x /1, 0/
  data bar /1, 0/

  print *, foo
  print *, bar
end
```

Now, the `DATA` statements provide values for all elements of `foo%x` and `bar`,
eliminating any reliance on implicit zero initialization by a particular
compiler:

```txt
$ flang-new-18 solution-intel.f90 -o solution-intel
$ ./solution-intel
 1 0
 1 0
```

### Related resources

- [PWR075 examples](https://github.com/codee-com/open-catalog/tree/main/Checks/PWR075/)

### References

- ["Extensions (The GNU Fortran
Compiler)"](https://gcc.gnu.org/onlinedocs/gfortran/Extensions.html), Free
  Software Foundation, Inc. [last checked May 2025]

- ["Additional Language
Features"](https://www.intel.com/content/www/us/en/docs/fortran-compiler/developer-guide-reference/2025-1/additional-language-features.html),
Intel Corporation. [last checked May 2025]

- ["HPE Cray Fortran Language
Extensions"](https://support.hpe.com/hpesc/public/docDisplay?docId=dp00004438en_us&docLocale=en_US),
Hewlett Packard Enterprise Development LP. [last checked May 2025]
