# PromiseKit Photos Extensions ![Build Status]

This project adds promises to Apple’s Photos framework.

## CocoaPods

```ruby
pod "PromiseKit/Photos" ~> 4.0
```

The extensions are built into `PromiseKit.framework` thus nothing else is needed.

## Carthage

```ruby
github "PromiseKit/Photos" ~> 1.0
```

The extensions are built into their own framework:

```swift
// swift
import PromiseKit
import PMKPhotos
```

```objc
// objc
@import PromiseKit;
@import PMKPhotos;
```


[Build Status]: https://travis-ci.org/PromiseKit/Photos.svg?branch=master
