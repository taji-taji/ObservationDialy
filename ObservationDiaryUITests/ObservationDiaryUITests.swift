//
//  ObservationDiaryUITests.swift
//  ObservationDiaryUITests
//
//  Created by tajika on 2015/12/24.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import XCTest

class ObservationDiaryUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["USE_UITEST_STORAGE"]
        app.launch()

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        let app = XCUIApplication()
        
        // 追加ボタンがあるかどうか
        XCTAssertTrue(app.buttons["AddTargetButton"].exists)
        
        // 追加ボタンタップ
        app.buttons["AddTargetButton"].tap()
        
        // タイトルを入力するテキストフィールドがあるかどうか
        let textField = app.textFields["TargetVCTargetTitleTextField"]
        XCTAssertTrue(textField.exists)
        
        // テキストフィールドをタップしてフォーカスを当てる
        textField.tap()
        // テキストフィールドに入力
        textField.typeText("ガジュマル")
        
        // 「追加」ボタンをタップ
        app.buttons["TargetVCAddButton"].tap()
        
        // 一行目にセルがあるかどうか
        XCTAssertTrue(app.tables.cells.elementBoundByIndex(0).exists)
        // 二行目にはセルがないはず
        XCTAssertFalse(app.tables.cells.elementBoundByIndex(1).exists)
        
        
//        let app = XCUIApplication()
//        app.navigationBars["記録リスト"].buttons["AddTargetButton"].tap()
//        
//        let targetvctargettitletextfieldTextField = app.textFields["TargetVCTargetTitleTextField"]
//        targetvctargettitletextfieldTextField.tap()
//        targetvctargettitletextfieldTextField.typeText("ガジュマル")
//        app.buttons["TargetVCAddButton"].tap()
        
    }
    
}
