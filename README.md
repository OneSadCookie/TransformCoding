# TransformCoding

A property wrapper to change the way a variable is encoded. This way
you can take advantage of generated Codable conformance, without
impacting the interface of your type.

## Usage

```swift
struct MyTransformer: TransformCodable {

    static func transformEncode(_ whatever: SomeType) -> String {
        // ...
    }

    static func transformDecode(_ encoded: String) throws -> SomeType {
        // ...
    }

}

struct MyStruct: Codable {

    @TransformCoding<MyTransformer>
    var whatever: SomeType

}
```

The library also provides a `DateTransformer` protocol you can use
for the common case of wanting to encode `Date` as `String` with a
particular `DateFormatter`:

```swift
struct ShortSlashUTCDateFormat: DateTransformer {
    static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        df.calendar = Calendar(identifier: .gregorian)
        df.timeZone = TimeZone(secondsFromGMT: 0)!
        return df
    }()
}

struct IHaveADate: Codable, Equatable {
    @TransformCoding<ShortSlashUTCDateFormat>
    var date: Date
}
```

## Swift Package Manager

Add to your `Package.swift`'s `dependencies:` array:

```swift
.package(url: "https://github.com/onesadcookie/TransformCoding.git", from: "1.0.0"),
```
