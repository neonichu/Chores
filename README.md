# Chore

[![Version](https://img.shields.io/cocoapods/v/Chores.svg?style=flat)](http://cocoadocs.org/docsets/Chores)
[![License](https://img.shields.io/cocoapods/l/Chores.svg?style=flat)](http://cocoadocs.org/docsets/Chores)
[![Platform](https://img.shields.io/cocoapods/p/Chores.svg?style=flat)](http://cocoadocs.org/docsets/Chores)
[![Build Status](http://img.shields.io/travis/neonichu/Chores.svg?style=flat)](https://travis-ci.org/neonichu/Chores)

A library for simplifying task execution in Swift.

## Usage

Use the `>` custom operator to execute commands:

```swift
let result = >"true"
println(result.result) // 0
println(result.stdout) // ""
```

You can also create pipes using '|' custom operator:

```swift
let result = >"ls"|["grep", ".md$"]
println(result.stdout) // "README.md"
```

And pipe commands into a closure:

```swift
let result = >["ls", "README.md"]|{ String(count($0)) }
println(result.stdout) // "9"
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

