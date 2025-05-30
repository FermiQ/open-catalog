# main.cpp

## Overview

This file is the main entry point for the benchmark executable. It uses the Google Benchmark library's `BENCHMARK_MAIN()` macro to generate the main function that runs all registered benchmarks.

## Key Components

*   **`BENCHMARK_MAIN()`:** A macro provided by the Google Benchmark library. When invoked, it generates the `main()` function necessary to initialize and run all defined benchmarks in the project.

## Important Variables/Constants

*   None.

## Usage Examples

This file itself does not provide components to be used by other modules. Instead, it compiles into the main executable that runs benchmarks.

To run the benchmarks, compile this file along with the benchmark definition files (e.g., `PWR*.cpp` files) and the Google Benchmark library. Then, execute the resulting binary.

```bash
# Example (pseudo-commands, actual compilation may vary)
# g++ -std=c++11 main.cpp PWR003.cpp ... -lbenchmark -lpthread -o benchmark_runner
# ./benchmark_runner
```

## Dependencies and Interactions

*   **`benchmark/benchmark.h`:** This file directly depends on the Google Benchmark library, specifically for the `BENCHMARK_MAIN()` macro.
*   **Benchmark Definition Files (e.g., `PWR*.cpp`, `Benchmark.h`):** While not a direct include dependency in `main.cpp` itself, the executable produced relies on other `.cpp` files where benchmarks are defined using macros like `BENCHMARK()` or `OC_BENCHMARK()`. The linker will combine these definitions with the `main` function generated here.
```
