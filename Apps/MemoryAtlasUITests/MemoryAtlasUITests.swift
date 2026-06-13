import Foundation
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

        try saveSimulatorScreenshot(named: "memory-atlas-evening-calm")
    }

    private func saveSimulatorScreenshot(named name: String) throws {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        guard let outputPath = ProcessInfo.processInfo.environment["WCS_SIMULATOR_SCREENSHOT_PATH"],
              !outputPath.isEmpty else {
            return
        }

        let outputURL = URL(fileURLWithPath: outputPath)
        try FileManager.default.createDirectory(
            at: outputURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try screenshot.pngRepresentation.write(to: outputURL)
    }
}
