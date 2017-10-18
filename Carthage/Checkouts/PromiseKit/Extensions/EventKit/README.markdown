# PromiseKit EventKit Extensions ![Build Status]

This project adds promises to Apple’s EventKit framework.

## CocoaPods

```ruby
pod "PromiseKit/EventKit" ~> 4.0
```

The extensions are built into `PromiseKit.framework` thus nothing else is needed.

## Carthage

```ruby
github "PromiseKit/EventKit" ~> 1.0
```

The extensions are built into their own framework:

```swift
// swift
import PromiseKit
import PMKEventKit
```

```objc
// objc
@import PromiseKit;
@import PMKEventKit;
```


[Build Status]: https://travis-ci.org/PromiseKit/EventKit.svg?branch=master
