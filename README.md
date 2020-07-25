# GraphQL Ruby benchmark example

```
$ BENCHMARK_SECONDS=5 ruby bench.rb
Warming up --------------------------------------
       without patch     1.000  i/100ms
          with patch     1.000  i/100ms
Calculating -------------------------------------
       without patch      6.782  (± 0.0%) i/s -     34.000  in   5.030646s
          with patch      8.633  (±11.6%) i/s -     44.000  in   5.140707s

Comparison:
          with patch:        8.6 i/s
       without patch:        6.8 i/s - 1.27x  (± 0.00) slower
```
