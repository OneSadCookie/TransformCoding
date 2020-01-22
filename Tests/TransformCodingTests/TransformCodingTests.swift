import XCTest
@testable import TransformCoding

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
    
    var string: String
}

struct HaveCompatible: Codable, Equatable {
    var date: String
    var string: String
}

struct IMightHaveADate: Codable, Equatable {
    @TransformCoding<ShortSlashUTCDateFormat.OrNil>
    var date: Date?
    
    var string: String
}

struct MightHaveCompatible: Codable, Equatable {
    var date: String?
    var string: String
}

final class TransformCodingTests: XCTestCase {
    
    func testHappyPath() throws {
        let thing = IHaveADate(date: .init(timeIntervalSinceReferenceDate: 60 * 60 * 24), string: "hi")
        let data = try JSONEncoder().encode(thing)
        let compat = try JSONDecoder().decode(HaveCompatible.self, from: data)
        XCTAssertEqual(compat, HaveCompatible(date: "02/01/2001", string: "hi"))
        let reThing = try JSONDecoder().decode(IHaveADate.self, from: data)
        XCTAssertEqual(thing, reThing)
    }
    
    func testHappyPathOptional() throws {
        let thing = IMightHaveADate(date: .init(timeIntervalSinceReferenceDate: 60 * 60 * 24), string: "hi")
        let data = try JSONEncoder().encode(thing)
        let compat = try JSONDecoder().decode(MightHaveCompatible.self, from: data)
        XCTAssertEqual(compat, MightHaveCompatible(date: "02/01/2001", string: "hi"))
        let reThing = try JSONDecoder().decode(IMightHaveADate.self, from: data)
        XCTAssertEqual(thing, reThing)
    }
    
    func testNilOptional() throws {
        let thing = IMightHaveADate(date: nil, string: "hi")
        let data = try JSONEncoder().encode(thing)
        let compat = try JSONDecoder().decode(MightHaveCompatible.self, from: data)
        XCTAssertEqual(compat, MightHaveCompatible(date: nil, string: "hi"))
        let reThing = try JSONDecoder().decode(IMightHaveADate.self, from: data)
        XCTAssertEqual(thing, reThing)
    }
    
    func testDateParseError() throws {
        let compat = HaveCompatible(date: "oops", string: "hi")
        let data = try JSONEncoder().encode(compat)
        XCTAssertThrowsError(
            try JSONDecoder().decode(IHaveADate.self, from: data)
        ) { (error) in
            switch error {
            case is DateParseError:
                break
            default:
                XCTFail("Expected DateParseError but found \(error)")
            }
        }
    }

    static var allTests = [
        ("testHappyPath", testHappyPath),
        ("testHappyPathOptional", testHappyPathOptional),
        ("testNilOptional", testNilOptional),
        ("testDateParseError", testDateParseError),
    ]
}
