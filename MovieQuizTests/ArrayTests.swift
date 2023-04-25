//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Ruth Dayter on 24.04.2023.
//

import Foundation
import XCTest
@testable import MovieQuiz

final class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        let array = [1, 7, 2, 3, 5]
            
        let value = array[safe: 3]
            
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 3)
    }
    
    func testGetValueOutOfRange() throws {
        let array = [1, 7, 2, 3, 5]
        
        let value = array[safe: 21]
        
        XCTAssertNil(value)
    }
}
