import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
    }
    
    func testAuth() throws {
        app.launchArguments.append("-UITestsReset")
        app.launch()
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["WebViewViewController"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("_")
        loginTextField.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        sleep(2)
        passwordTextField.typeText("_")
        sleep(2)
        webView.buttons["Login"].tap()
        sleep(2)
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        app.launch()
        sleep(2)
        let tablesQuery = app.tables
        sleep(2)
        let cell = tablesQuery.cells.element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        cell.swipeUp()
        sleep(2)
        
        let cellToLike = tablesQuery.cells.element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5))
        cellToLike.swipeDown()
        sleep(2)
        
        let likeButton = cellToLike.buttons.firstMatch
        XCTAssertTrue(likeButton.waitForExistence(timeout: 3))
        
        likeButton.tap()
        sleep(2)
        likeButton.tap()
        sleep(2)
        
        cellToLike.tap()
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons["back_button"]
        backButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["Sofya "].exists)
        XCTAssertTrue(app.staticTexts["@tarnalitska"].exists)
        
        app.buttons["logout_button"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
    
}
