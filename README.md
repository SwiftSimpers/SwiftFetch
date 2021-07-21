# Swift Fetch

Fetch-like API implementation for Swift for asynchronous HTTP requests with the new `async/await` syntax.

## Usage

```swift
import SwiftFetch

@main
struct Program {
  static func main() async throws {
    let response = try await fetch("https://google.com")
    print("HTML", try await response.text())
  }
}
```

Wanna stream? It's easy!

```swift
import SwiftFetch

@main
struct Program {
  static func main() async throws {
    let response = try await fetch("https://url.to/something")
    
    for try await byte in response.body {
      // ...
    }
  }
}
```

## License

Check [./LICENSE] for more info.

Copyright 2021-present (c) DjDeveloperr, Helloyunho
