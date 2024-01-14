import XCTest
@testable import MovieQuiz

final class MovieQuizUITests: XCTestCase {
    
    //  Это — примитив приложения. То есть эта переменная символизирует приложение, которое мы тестируем. Чтобы быть уверенными, что эта переменная будет проинициализирована на момент использования, присвоим ей значение в методе setUpWithError()
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        // Обнуляет значение, которое мы присвоили в setUpWithError
        app = nil
    }
    
    func testYesButton() {
        sleep(1)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        app.buttons["Yes"].tap()
        
        sleep(1)

        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]

        XCTAssertFalse(firstPosterData == secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(1)
        let firstPosterData = app.images["Poster"].screenshot().pngRepresentation
        app.buttons["No"].tap()
        
        sleep(1)
        let secondPosterData = app.images["Poster"].screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertEqual(indexLabel.label, "2/10")
        XCTAssertFalse(firstPosterData == secondPosterData)
    }
    
    func testResultAlertPopUp() {
        
        for _ in 1...10 {
            sleep(1)
            app.buttons["Yes"].tap()
        }
        
        sleep(1)
        XCTAssertTrue(app.alerts["Alert"].exists)
        XCTAssertEqual(app.alerts["Alert"].label, "Этот раунд окончен!")
        XCTAssertEqual(app.alerts["Alert"].buttons.firstMatch.label, "Сыграть еще раз")
    }
    
    func testResultAlertClosed() {
        
        for _ in 1...10 {
            sleep(1)
            app.buttons["Yes"].tap()
        }
        
        sleep(1)
        app.alerts["Alert"].buttons.firstMatch.tap()
        sleep(1)
        XCTAssertEqual(app.staticTexts["Index"].label, "1/10")
    }
        
}
