//
//  LoggerTests.swift
//  BaseCore
//
//  Created by baner on 12/12/25.
//

import XCTest
import BaseCore

final class LoggerTests: XCTestCase {

    func test_logger_doesNotCrash() {
        Logger.log("Test log")
        XCTAssertTrue(true)
    }
}
