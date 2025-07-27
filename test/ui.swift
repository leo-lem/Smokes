import XCTest

@MainActor class SmokesUITests: XCTestCase {
  let app = XCUIApplication()

  override func setUp() async throws {
    app.launchArguments.append("UI_TESTS")
    app.launch()
    if app.wait(for: .runningForeground, timeout: 10) { return }
  }

  override func tearDown() async throws {
    app.terminate()
    if app.wait(for: .notRunning, timeout: 10) { return }
  }

  func testAddingAndRemovingSmokes() async throws {
    let collections = app.collectionViews
    collections.buttons["add-button"].tap()
    XCTAssertTrue(collections.otherElements["today"].staticTexts["1 smoke"].exists)
    collections.buttons["remove-button"].tap()
    XCTAssertTrue(collections.otherElements["today"].staticTexts["None"].exists)
  }

  func testModifyingHistory() async throws {
    let collections = app.collectionViews
    collections.firstMatch.swipeRight()
    collections.buttons["start-modifying-button"].tap()

    let thisDay = collections.otherElements["this day"]
    let none = thisDay.staticTexts["None"]
    let smoke = thisDay.staticTexts["1 smoke"]

    XCTAssertTrue(none.exists)
    collections.buttons["add-button"].tap()
    XCTAssertTrue(smoke.exists)
    collections.buttons["next-day-button"].tap()
    XCTAssertTrue(none.exists)
    collections.buttons["previous-day-button"].tap()
    XCTAssertTrue(smoke.exists)
    collections.buttons["remove-button"].tap()
    XCTAssertTrue(none.exists)
  }

  func testViewingStats() async throws {
    let collections = app.collectionViews
    collections.firstMatch.swipeLeft()

    let alltime = collections.buttons["chevron.forward.to.line"]
    XCTAssertFalse(collections.staticTexts["per day (trend)"].exists)
    alltime.tap()
    XCTAssertTrue(collections.staticTexts["per day (trend)"].exists)
    alltime.tap()
  }

  func testViewingFact() async throws {
    app/*@START_MENU_TOKEN@*/.buttons["lightbulb"]/*[[".buttons[\"Fact\"]",".buttons[\"lightbulb\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    XCTAssertTrue(app.staticTexts["Smokes"].exists)
    app/*@START_MENU_TOKEN@*/.buttons["chevron.forward.to.line"]/*[[".buttons[\"skip\"]",".buttons[\"chevron.forward.to.line\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    XCTAssertTrue(app/*@START_MENU_TOKEN@*/.buttons["lightbulb"]/*[[".buttons[\"Fact\"]",".buttons[\"lightbulb\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists)
  }

  func testViewingInfo() async throws {
    app/*@START_MENU_TOKEN@*/.buttons["info"]/*[[".buttons[\"About\"]",".buttons[\"info\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    XCTAssertTrue(app.staticTexts["Smokes"].exists)
    XCTAssertTrue(app.collectionViews.staticTexts["Privacy Policy"].exists)

  }

  func testViewingTransfer() async throws {
    app.buttons["show-porter-button"].tap()
    XCTAssertTrue(app.buttons["export-button"].exists)
    XCTAssertTrue(app.buttons["import-button"].exists)
  }
}
