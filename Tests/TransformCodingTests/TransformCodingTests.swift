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

struct Compatible: Codable, Equatable {
    var date: String
    var string: String
}

final class TransformCodingTests: XCTestCase {
    
    func testHappyPath() throws {
        let thing = IHaveADate(date: .init(timeIntervalSinceReferenceDate: 60 * 60 * 24), string: "hi")
        let data = try JSONEncoder().encode(thing)
        let compat = try JSONDecoder().decode(Compatible.self, from: data)
        XCTAssertEqual(compat, Compatible(date: "02/01/2001", string: "hi"))
        let reThing = try JSONDecoder().decode(IHaveADate.self, from: data)
        XCTAssertEqual(thing, reThing)
    }
    
    func testDateParseError() throws {
        let compat = Compatible(date: "oops", string: "hi")
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
        ("testDateParseError", testDateParseError),
    ]
}
