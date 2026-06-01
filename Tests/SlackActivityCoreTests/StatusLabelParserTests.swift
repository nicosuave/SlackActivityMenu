@testable import SlackActivityCore
import XCTest

final class StatusLabelParserTests: XCTestCase {
    func testParsesNumericLabel() {
        XCTAssertEqual(
            StatusLabelParser.parse(#""StatusLabel"={ "label"="13106" }"#),
            .label("13106")
        )
    }

    func testParsesEscapedLabel() {
        XCTAssertEqual(
            StatusLabelParser.parse(#""StatusLabel"={ "label"="9\"+" }"#),
            .label("9\"+")
        )
    }

    func testNullMeansNoBadge() {
        XCTAssertEqual(
            StatusLabelParser.parse(#""StatusLabel"=[ NULL ]"#),
            .noBadge
        )
    }

    func testEmptyOutputMeansAppIsNotRunning() {
        XCTAssertEqual(StatusLabelParser.parse(""), .appNotRunning)
    }
}
