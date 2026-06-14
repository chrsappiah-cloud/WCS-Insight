import XCTest

final class MemoryAtlasUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testHomeAndSessionNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Memory Atlas"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Today’s calm session"].exists)

        app.buttons["Open session player"].tap()

        XCTAssertTrue(app.staticTexts["Evening Calm"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Mark step complete"].exists)
    }
}
