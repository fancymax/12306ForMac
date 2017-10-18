# PromiseKit UIKit Extensions ![Build Status]

This project adds promises to Apple’s UIKit framework.

## CococaPods

```ruby
pod "PromiseKit/UIKit" ~> 4.0
```

The extensions are built into `PromiseKit.framework` thus nothing else is needed.

## Carthage

```ruby
github "PromiseKit/UIKit" ~> 1.0
```

The extensions are built into their own framework:

```swift
// swift
import PromiseKit
import PMKUIKit
```

```objc
// objc
@import PromiseKit;
@import PMKUIKit;
```


[Build Status]: https://travis-ci.org/PromiseKit/UIKit.svg?branch=master
