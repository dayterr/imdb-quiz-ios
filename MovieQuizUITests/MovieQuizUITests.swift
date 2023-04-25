//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Ruth Dayter on 24.04.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
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
        app = nil
    }

    func testScreenCast() throws {
        
    }
    
    func testYesButton() {
        sleep(3)
            
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
            
        app.buttons["Yes"].tap()
        sleep(3)
            
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
            
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
       
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testEndGame() {
        sleep(3)
        for _ in 1...4 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        
        app.buttons["No"].tap()
        sleep(2)
        
        for _ in 1...5 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
    
        let alert = app.alerts["Game results"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }
    
    func testFinalAlertDisappear() {
        sleep(3)
        for _ in 1...4 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        
        app.buttons["No"].tap()
        sleep(2)
        
        for _ in 1...5 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Game results"]
        alert.buttons.firstMatch.tap()
        
        sleep(3)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}
