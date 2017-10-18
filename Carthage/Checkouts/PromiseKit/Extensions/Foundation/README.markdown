# PromiseKit Foundation Extensions ![Build Status]

This project adds promises to Apple’s Foundation framework.

## CococaPods

```ruby
pod "PromiseKit/Foundation" ~> 4.0
```

The extensions are built into `PromiseKit.framework` thus nothing else is needed.

## Carthage

```ruby
github "PromiseKit/Foundation" ~> 1.0
```

The extensions are built into their own framework:

```swift
// swift
import PromiseKit
import PMKFoundation
```

```objc
// objc
@import PromiseKit;
@import PMKFoundation;
```

## SwiftPM

```swift
let package = Package(
    dependencies: [
        .Target(url: "https://github.com/PromiseKit/Foundation", majorVersion: 1)
    ]
)
```


[Build Status]: https://travis-ci.org/PromiseKit/Foundation.svg?branch=master
