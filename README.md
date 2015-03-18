# Chore

A library for simplifying task execution in Swift.

## Usage

Use the `§` custom operator to execute commands:

```swift
let result = §"true"
println(result.result) // 0
println(result.stdout) // ""
```

## Unit Tests

The tests require [xctester][1], install it via [Homebrew][2]:

```
$ brew install xctester
```

and run the tests:

```
$ make test
```

[1]: https://github.com/neonichu/xctester
[2]: http://brew.sh

