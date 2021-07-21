# Swift Fetch

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

Check (LICENSE)[./LICENSE] for more info.

Copyright 2021-present (c) DjDeveloperr, Helloyunho
