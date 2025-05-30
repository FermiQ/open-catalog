# Benchmark.h

## Overview

This header file provides utility functions and macros for creating and running benchmarks within the OpenCatalog project. It includes functions for generating test data (vectors of zeros, uninitialized vectors, and random vectors) and a custom macro for defining benchmarks with fine-tuned settings.

## Key Components

*   **`OC_BENCHMARK(NAME, ...)`:** A macro that wraps the `BENCHMARK` macro from the `benchmark/benchmark.h` library. It sets the benchmark name and time unit to microseconds.
*   **`CreateZeroVector<Ty>(n)`:** A template function that returns a `std::vector<Ty>` of size `n` filled with zeros.
*   **`CreateUninitializedVector<Ty>(n)`:** A template function that returns an uninitialized `std::vector<Ty>` of size `n`.
*   **`CreateRandomVector<Ty>(n, lowerBound, upperBound)`:** A template function that returns a `std::vector<Ty>` of size `n` filled with random floating-point numbers uniformly distributed between `lowerBound` (default 1) and `upperBound` (default 128).

## Important Variables/Constants

*   None explicitly defined in this file that globally affect behavior outside of function parameters.

## Usage Examples

```cpp
#include "Benchmark.h"
#include <vector>

// Example of using CreateRandomVector
static void BM_MyRandomVectorUsage(benchmark::State& state) {
  for (auto _ : state) {
    std::vector<float> v = OpenCatalog::CreateRandomVector<float>(1000);
    // Process the vector v
    benchmark::DoNotOptimize(v.data());
  }
}
OC_BENCHMARK("MyRandomVectorBenchmark", BM_MyRandomVectorUsage);

// Example of using CreateZeroVector
static void BM_MyZeroVectorUsage(benchmark::State& state) {
  for (auto _ : state) {
    std::vector<int> v = OpenCatalog::CreateZeroVector<int>(500);
    // Process the vector v
    benchmark::DoNotOptimize(v.data());
  }
}
OC_BENCHMARK("MyZeroVectorBenchmark", BM_MyZeroVectorUsage);
```

## Dependencies and Interactions

*   **`<algorithm>`:** Used for `std::generate` in `CreateRandomVector`.
*   **`<random>`:** Used for random number generation (`std::mt19937`, `std::uniform_real_distribution`) in `CreateRandomVector`.
*   **`<vector>`:** Used for `std::vector` data structures.
*   **`benchmark/benchmark.h`:** This file heavily relies on the Google Benchmark library for its core functionality. The `OC_BENCHMARK` macro is a customization of the library's `BENCHMARK` macro.
*   Interacts with benchmark source files (`.cpp`) that will include this header to define and run specific benchmarks.
```
