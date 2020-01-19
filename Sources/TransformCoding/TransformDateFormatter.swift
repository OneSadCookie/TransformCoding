import Foundation

public struct DateParseError: Error {}

public protocol DateTransformer: TransformCodable where
    EncodedType == String,
    DecodedType == Date
{
    static var formatter: DateFormatter { get }
}

public extension DateTransformer {

    static func transformEncode(_ value: DecodedType) throws -> EncodedType {
        formatter.string(from: value)
    }

    static func transformDecode(_ encoded: EncodedType) throws -> DecodedType {
        if let date = formatter.date(from: encoded) {
            return date
        }
        throw DateParseError()
    }

}
