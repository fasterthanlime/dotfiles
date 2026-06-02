## Modern Rust formatting

When printing or formatting simple variables, try to use the modern syntax for Rust which allows you to place simple variables directly inside the format string braces:

```rust
// Modern syntax for simple variables
format!("{a}, {b}");
println!("{a}, {b}");
print!("{a}, {b}");

// This works with logging macros from the tracing crate too
info!("Value: {a}");
warn!("Warning with {a} and {b}");
error!("Error code: {code}");
trace!("Detailed info: {a}, {b}");

// Instead of the older style
format!("{}, {}", a, b);
println!("{}, {}", a, b);
```

Note that this only works with simple variable names. For more complex expressions like field access, method calls, or other operations, you must use the older positional syntax:

```rust
// Must use positional arguments for complex expressions
format!("{}, {}", person.name, value.to_string());
println!("{}, {}", person.name, value.to_string());
info!("{}, {}", person.name, value.to_string());

// DO NOT do this:
// format!("{person.name}, {value.to_string()}");  // Won't compile!
// println!("{person.name}, {value.to_string()}");  // Won't compile!
// error!("{person.name}, {value.to_string()}");  // Won't compile!
```
