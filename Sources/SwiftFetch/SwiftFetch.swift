import Foundation

/**
 Used to set the HTTP method for a request.
 */
public enum RequestMethod {
    case GET
    case POST
    case PUT
    case DELETE
    case HEAD
    case OPTIONS
}

/**
 Used to set the HTTP header for a request.
 */
public struct FetchHeaders {
    private var headers: [String: String] = [:]

    init(_ data: [String: String]) {
        headers = data
        for header in data {
            headers[header.key.lowercased()] = header.value
        }
    }

    public mutating func set(_ key: String, _ value: String) -> Self {
        headers[key.lowercased()] = value
        return self
    }

    public func has(_ key: String) -> Bool {
        return headers[key.lowercased()] != nil
    }

    public func get(_ key: String) -> String? {
        return headers[key.lowercased()]
    }

    public mutating func delete(_ key: String) -> Bool {
        if !has(key.lowercased()) { return false }
        headers[key.lowercased()] = nil
        return true
    }

    public func all() -> [String: String] {
        return headers
    }

    public mutating func clear() -> Self {
        headers = [:]
        return self
    }
}

/**
 Used to make complicated requests to the server.
 */
public struct FetchRequestInit {
    /// The HTTP method to use.
    var method: RequestMethod?
    /// The URL to make the request to.
    var url: URL?
    /// A dictionary of headers to send with the request.
    var headers: [String: String] = [:]
    /// The body of the request.
    var body: Data?
}

/**
 Used to convert `FetchRequestInit` to `URLRequest`.
 You might want to use `FetchRequestInit` rather than this directly.
 */
public class FetchRequest {
    /// The HTTP method to use.
    var method: RequestMethod = .GET
    /// The URL to make the request to.
    var url: URL!
    /// A dictionary of headers to send with the request.
    var headers = FetchHeaders([:])
    /// The body of the request.
    var body: Data?

    /**
     Used to convert `FetchRequestInit` to `URLRequest`.
     You might want to use `FetchRequestInit` rather than this directly.

     - parameters:
         - requestInit: A `FetchRequestInit` to convert to a `URLRequest`.
     */
    init(_ requestInit: FetchRequestInit) {
        serialize(data: requestInit)
    }

    private func serialize(data: FetchRequestInit) {
        if let method = data.method {
            self.method = method
        }
        if let url = data.url {
            self.url = url
        }
        for header in data.headers {
            _ = headers.set(header.key, header.value)
        }
        if let body = data.body {
            self.body = body
        }
    }

    /**
     Converts `FetchRequest` to `URLRequest`.

     - returns: A `URLRequest` that can be used to make the request.
     */
    func intoURLRequest() -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = headers.all()
        switch method {
        case .GET:
            urlRequest.httpMethod = "GET"
        case .POST:
            urlRequest.httpMethod = "POST"
        case .PUT:
            urlRequest.httpMethod = "PUT"
        case .DELETE:
            urlRequest.httpMethod = "DELETE"
        case .HEAD:
            urlRequest.httpMethod = "HEAD"
        case .OPTIONS:
            urlRequest.httpMethod = "OPTIONS"
        }
        urlRequest.httpBody = body
        return urlRequest
    }
}

/**
 Used to get the response from a request.
 You shouldn't use this since it's meant to be created by the library.
 */
public struct FetchResponse {
    /// The HTTP status code of the response.
    public let status: Int
    /// Human readable text of the status code.
    public let statusText: String
    /// The HTTP headers of the response.
    public let headers: FetchHeaders
    /// The body of the response.
    public let body: URLSession.AsyncBytes
    public var ok: Bool { self.status >= 200 && self.status <= 299 }
    
    public func data() async throws -> Data {
        var tempData = Data()
        for try await byte in body {
            tempData.append(contentsOf: [byte])
        }
        
        return tempData
    }

    /**
     Converts body to `String`.

     - returns: The body of the response as a `String`.
     */
    public func text() async throws -> String? {
        let data = try await self.data()
        
        return String(data: data, encoding: .utf8)
    }
    
    /**
     Parses body json.

     - returns: The parsed body. Since json can be a number, dictionary, etc, the return type is `Any`.
     */
    public func json() async throws -> Any {
        let data = try await self.data()
        
        return try JSONSerialization.jsonObject(with: data)
    }
    
    /**
     Decodes body json to the specified type.

     - parameters:
        - type: The type you want to get.

     - returns: The decoded body, converted to the specified type.
     */
    public func json<T>(_ type: T.Type) async throws -> T where T: Decodable {
        let data = try await self.data()
        let decoder = JSONDecoder()
        
        return try decoder.decode(type, from: data)
    }
}

/**
 Makes a request to the server.

 - parameters:
    - urlString: The URL `string` to make the request to.
 - returns: A `FetchResponse` that contains the response from the server.
 */
public func fetch(_ urlString: String) async throws -> FetchResponse {
    return try await fetch(urlString, FetchRequestInit())
}

/**
 Makes a request to the server.

 - parameters:
    - urlString: The URL `string` to make the request to.
    - requestInit: A `FetchRequestInit` that contains the request information.
 - returns: A `FetchResponse` that contains the response from the server.
 */
public func fetch(_ urlString: String, _ requestInit: FetchRequestInit) async throws -> FetchResponse {
    let url = URL(string: urlString)!
    return try await fetch(url, requestInit)
}

/**
 Makes a request to the server.

 - parameters:
    - url: The `URL` to make the request to.
 - returns: A `FetchResponse` that contains the response from the server.
 */
public func fetch(_ url: URL) async throws -> FetchResponse {
    return try await fetch(url, FetchRequestInit())
}

/**
 Makes a request to the server.

 - parameters:
    - url: The `URL` to make the request to.
    - requestInit: A `FetchRequestInit` that contains the request information.
 - returns: A `FetchResponse` that contains the response from the server.
 */
public func fetch(_ url: URL, _ requestInit: FetchRequestInit) async throws -> FetchResponse {
    let request = FetchRequest(requestInit)
    request.url = url
    return try await fetch(request)
}

/**
 Makes a request to the server.

 - parameters:
    - requestInit: A `FetchRequestInit` that contains the request information.
 - returns: A `FetchResponse` that contains the response from the server.
 */
public func fetch(_ requestInit: FetchRequestInit) async throws -> FetchResponse {
    try await fetch(FetchRequest(requestInit))
}

/**
 Makes a request to the server.

 - parameters:
    - request: A `FetchRequest` that contains the request information.
 - returns: A `FetchResponse` that contains the response from the server.
 */
public func fetch(_ request: FetchRequest) async throws -> FetchResponse {
    let (body, urlResponse) = try await URLSession.shared.bytes(for: request.intoURLRequest())

    guard let res = urlResponse as? HTTPURLResponse else { throw NotAHTTPError() }

    return FetchResponse(
        status: res.statusCode,
        statusText: HTTPURLResponse.localizedString(
            forStatusCode: res.statusCode
        ),
        headers: FetchHeaders(
            (res.allHeaderFields as NSDictionary as? [String: String]) ?? [:]
        ),
        body: body
    )
}

public struct NotAHTTPError: Error {}
