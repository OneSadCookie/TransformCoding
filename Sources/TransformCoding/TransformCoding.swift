public protocol CodingTransformer {
    associatedtype EncodedType
    associatedtype DecodedType
}

public protocol TransformEncodable: CodingTransformer
where EncodedType: Encodable {

    static func transformEncode(_ value: DecodedType) throws -> EncodedType

}

public protocol TransformDecodable: CodingTransformer
where EncodedType: Decodable {

    static func transformDecode(_ encoded: EncodedType) throws -> DecodedType

}

public protocol TransformCodable: TransformEncodable & TransformDecodable {}

@propertyWrapper
public struct TransformCoding<Transformer: CodingTransformer> {
    
    public var wrappedValue: Transformer.DecodedType
    
    public init(wrappedValue: Transformer.DecodedType) {
        self.wrappedValue = wrappedValue
    }
    
}

extension TransformCoding: Encodable where Transformer: TransformEncodable {
    
    public func encode(to encoder: Encoder) throws {
        try Transformer.transformEncode(wrappedValue).encode(to: encoder)
    }
    
}

extension TransformCoding: Decodable where Transformer: TransformDecodable {

    public init(from decoder: Decoder) throws {
        self.init(wrappedValue: try Transformer.transformDecode(Transformer.EncodedType(from: decoder)))
    }

}

extension TransformCoding: Equatable
where Transformer.DecodedType: Equatable {}

extension TransformCoding: Hashable
where Transformer.DecodedType: Hashable {}
