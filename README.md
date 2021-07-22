# Swift Fetch

[![Swift 5.5](https://img.shields.io/badge/Swift-5.5-red.svg?style=flat-square&logo=swift)](https://swift.org)
![Platforms: iOS, macOS, tvOS, watchOS](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgray.svg?style=flat-square)
[![Swift Package Manager Compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg?style=flat-square)](https://swift.org/package-manager)

Fetch-like API implementation for Swift for asynchronous HTTP requests with the new `async/await` syntax.

## Usage

```swift
import SwiftFetch

let response = try await fetch("https://google.com")
print(try await response.text())
```

Wanna stream? It's easy!

```swift
import SwiftFetch

let response = try await fetch("https://url.to/something")
    
for try await byte in response.body {
  // ...
}
```

## Contributing

You're always welcome to contribute! 

- We use SwiftFormat for formatting.

## License

Check [LICENSE](./LICENSE]) for more info.

Copyright 2021-present (c) DjDeveloperr, Helloyunho
