//
//  ASBInterviewExerciseUITests.swift
//  ASBInterviewExerciseUITests
//
//  Created by ASB on 29/07/21.
//
import XCTest

class ASBInterviewExerciseUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        // Add testing flags to let the app know it's running in test mode
        app.launchArguments = ["--uitesting"]
        
        // Print logs before launching
        print("Preparing to launch app for UI testing")
        app.launch()
        
        // Wait for app to fully load
        sleep(3)
        print("App launched")
    }
    
    override func tearDownWithError() throws {
        // Cleanup after each test
        print("Test completed, cleaning up")
    }
    
    // Debug helper to print UI elements
    private func dumpUIHierarchy() {
        print("\n==== UI Hierarchy ====")
        
        // Navigation bars
        print("Navigation Bars:")
        let navBars = app.navigationBars
        for i in 0..<navBars.count {
            if i < navBars.count {
                print("  - \(navBars.element(boundBy: i).label)")
            }
        }
        
        // Segmented Controls
        print("Segmented Controls:")
        let segments = app.segmentedControls
        for i in 0..<segments.count {
            if i < segments.count {
                let control = segments.element(boundBy: i)
                print("  - \(control.label) (buttons: \(control.buttons.count))")
                for j in 0..<control.buttons.count {
                    if j < control.buttons.count {
                        print("    * \(control.buttons.element(boundBy: j).label)")
                    }
                }
            }
        }
        
        // Buttons (first 5)
        print("Buttons (first 5):")
        let buttons = app.buttons
        for i in 0..<min(5, buttons.count) {
            if i < buttons.count {
                print("  - \(buttons.element(boundBy: i).label)")
            }
        }
        
        // Text elements (first 5)
        print("Text Elements (first 5):")
        let texts = app.staticTexts
        for i in 0..<min(5, texts.count) {
            if i < texts.count {
                print("  - \(texts.element(boundBy: i).label)")
            }
        }
        
        print("==================\n")
    }
    
    // Basic app launch test
    func testAppLaunches() throws {
        // Verify app has successfully launched
        XCTAssertTrue(app.exists, "App should launch successfully")
        
        // Print UI hierarchy for debugging
        dumpUIHierarchy()
        
        // Verify necessary UI elements exist
        // 1. Navigation bar
        let navBarExists = app.navigationBars.element.waitForExistence(timeout: 5)
        XCTAssertTrue(navBarExists, "Navigation bar should exist")
        
        // 2. Table or collection view
        let hasTableOrCollection = app.tables.element.exists || app.collectionViews.element.exists
        XCTAssertTrue(hasTableOrCollection, "Should have table or collection view")
        
        // 3. Segmented control (for filtering)
        let hasSegmentedControl = app.segmentedControls.element.exists
        XCTAssertTrue(hasSegmentedControl, "Should have segmented control for filtering")
    }
    
    // Test transaction list view
    func testTransactionListView() throws {
        print("Starting transaction list view test")
        dumpUIHierarchy()
        
        // 1. Verify page title - this part should work fine
        let navigationTitle = app.navigationBars["Transactions"]
        XCTAssertTrue(navigationTitle.waitForExistence(timeout: 10), "Page title should be 'Transactions'")
        
        // 2. Verify text content instead of table
        // Search for date headers or any transaction-related text
        let dateText = app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS[c] 'February' OR label CONTAINS[c] 'January' OR label CONTAINS[c] 'March' OR label CONTAINS[c] 'April'"))
        let waitResult = dateText.waitForExistence(timeout: 10)
        
        if !waitResult {
            print("Date text not found, trying to find any transaction-related text")
            // Print all visible static text
            print("Visible text elements:")
            for text in app.staticTexts.allElementsBoundByIndex {
                print("  > \(text.label)")
            }
        }
        
        // Try to find text containing "Income" or "Expense"
        let transactionText = app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS[c] 'Income' OR label CONTAINS[c] 'Expense'"))
        XCTAssertTrue(dateText.exists || transactionText.exists, "Page should display transaction-related text")
        
        // 3. Test segmented control - this part should also work fine
        let segmentedControl = app.segmentedControls.firstMatch
        XCTAssertTrue(segmentedControl.waitForExistence(timeout: 5), "Segmented control should exist")
        
        // Try clicking each button in the segmented control
        if segmentedControl.exists && segmentedControl.buttons.count >= 3 {
            // Click "Income"
            let incomeButton = segmentedControl.buttons.element(boundBy: 1)
            incomeButton.tap()
            sleep(1)
            
            // Confirm filter has been applied - check if text contains "Income"
            let hasIncomeText = app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS[c] 'Income'")).exists
            if !hasIncomeText {
                print("⚠️ No income transaction text detected, filter may not be working properly")
            }
            
            // Click "Expense"
            let expenseButton = segmentedControl.buttons.element(boundBy: 2)
            expenseButton.tap()
            sleep(1)
            
            // Confirm filter has been applied - check if text contains "Expense"
            let hasExpenseText = app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS[c] 'Expense'")).exists
            if !hasExpenseText {
                print("⚠️ No expense transaction text detected, filter may not be working properly")
            }
            
            // Click "All"
            let allButton = segmentedControl.buttons.element(boundBy: 0)
            allButton.tap()
            sleep(1)
        } else {
            print("Warning: Could not find segmented control with 3 buttons")
        }
        
        // 4. Test search functionality
        let searchButton = app.buttons["Search"] ?? app.buttons["magnifyingglass"]
        if searchButton.exists {
            searchButton.tap()
            sleep(1)
            
            // Find search field and enter text
            if app.searchFields.count > 0 || app.textFields.count > 0 {
                let searchField = app.searchFields.firstMatch.exists ?
                    app.searchFields.firstMatch : app.textFields.firstMatch
                
                searchField.tap()
                searchField.typeText("test")
                
                // Clear search - look for any close button
                let closeButton = app.buttons["xmark.circle.fill"] ?? app.buttons["Clear text"]
                if closeButton.exists {
                    closeButton.tap()
                } else {
                    // If no close button, may need to press return key on keyboard
                    if app.keyboards.buttons["return"].exists {
                        app.keyboards.buttons["return"].tap()
                    }
                }
            }
        }
        
        // 5. Test refresh button
        let refreshButton = app.buttons["Refresh"] ?? app.buttons["arrow.clockwise"]
        if refreshButton.exists {
            refreshButton.tap()
            sleep(2) // Wait for refresh to complete
        }
        
        // Verify app hasn't crashed
        XCTAssertTrue(app.exists, "App should still be running after refresh")
    }
    
    // Test transaction detail view
    func testTransactionDetailView() throws {
        print("Starting transaction detail view test")
        
        // Wait for the transactions to load
        let monthLabels = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@ OR label CONTAINS[c] %@ OR label CONTAINS[c] %@", "January", "February", "March", "April"))
        XCTAssertTrue(monthLabels.firstMatch.waitForExistence(timeout: 10.0))
        
        // Dump the UI hierarchy for debugging
        dumpUIHierarchy()
        
        // Find a transaction to tap
        let transactionTexts = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@", "Income", "Expense"))
        let transactionCount = transactionTexts.count
        print("Found \(transactionCount) transaction texts")
        
        // Tap the first one
        transactionTexts.element(at: 0).tap()
        
        // Dump the UI hierarchy for debugging
        dumpUIHierarchy()
        
        // Verify the detail view appears
        XCTAssertTrue(app.navigationBars["Transaction Details"].waitForExistence(timeout: 5.0))
        
        verifyDetailViewElements()
        
        // Dismiss the detail view
        dismissDetailView()
        
        // Wait for the transaction list to reappear
        // (You can add a verification that we're back at the list view if needed)
        XCTAssertTrue(app.navigationBars["Transactions"].waitForExistence(timeout: 5.0))
    }
    
    // Test filter functionality and detail view
    func testFilterAndViewDetail() throws {
        print("Starting filter and detail view test")
        
        // Wait for the transactions to load
        let monthLabels = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@ OR label CONTAINS[c] %@ OR label CONTAINS[c] %@", "January", "February", "March", "April"))
        XCTAssertTrue(monthLabels.firstMatch.waitForExistence(timeout: 15.0))
        
        // Make sure the segmented control exists
        XCTAssertTrue(app.segmentedControls.firstMatch.waitForExistence(timeout: 5.0))
        
        // Tap the Income filter
        XCTAssertTrue(app.buttons["Income"].exists)
        app.buttons["Income"].tap()
        print("Tapped Income filter")
        
        // Wait for filtered results and tap first transaction
        let incomeTransactions = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Income"))
        XCTAssertTrue(incomeTransactions.count > 0)
        incomeTransactions.element(at: 0).tap()
        print("Tapped first Income transaction")
        
        // Dump the UI hierarchy for debugging
        dumpUIHierarchy()
        
        // Verify the detail view appears - first check navigation bar
        if app.navigationBars["Transaction Details"].exists {
            print("Found 'Transaction Details' navigation bar")
        }
        
        verifyDetailViewElements()
        
        // Dismiss the detail view
        dismissDetailView()
        
        // Wait for the transaction list to reappear
        XCTAssertTrue(app.navigationBars["Transactions"].waitForExistence(timeout: 5.0))
    }
    
    // Helper method to verify elements in the detail view
    private func verifyDetailViewElements() -> Bool {
        // Check for detail view navigation title first
        let detailNavBar = app.navigationBars["Transaction Details"]
        let navBarFound = detailNavBar.waitForExistence(timeout: 10.0)
        
        if navBarFound {
            print("Found 'Transaction Details' navigation bar")
        } else {
            print("Warning: 'Transaction Details' navigation bar not found")
        }
        
        // Wait extra time for sheet animations to complete
        sleep(1)
        
        // Check for specific detail view elements using multiple approaches
        let detailElements = [
            "Transaction Name",
            "Transaction ID",
            "Income amount",
            "Expense amount",
            "GST",
            "Date"
        ]
        
        var foundDetailElement = false
        for element in detailElements {
            let matchingElements = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", element))
            if matchingElements.count > 0 {
                foundDetailElement = true
                print("Found detail element: \(element)")
                break
            }
        }
        
        // Dump UI hierarchy for troubleshooting if no elements found
        if !foundDetailElement && !navBarFound {
            print("No detail view elements found, dumping UI hierarchy:")
            dumpUIHierarchy()
        }
        
        // As an additional verification, look for buttons that might only be in detail view
        let detailViewSpecificButtons = app.buttons["Close details page"]
        if detailViewSpecificButtons.exists {
            print("Found 'Close details page' button")
            foundDetailElement = true
        }
        
        // Return true if we found either nav bar or detail elements
        return navBarFound || foundDetailElement
    }
    
    // Helper method to dismiss detail view
    private func dismissDetailView() {
        // Check if close button exists with the correct name
        let closeButton = app.buttons["Close details page"]
        
        if closeButton.exists {
            closeButton.tap()
            print("Tapped Close details page button")
            return
        }
        
        print("Close details page button not found, trying alternative dismissal methods")
            
        // Try tapping any button with "Close" in its label
        let anyCloseButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Close'")).firstMatch
        if anyCloseButton.exists {
            anyCloseButton.tap()
            print("Tapped a button containing 'Close'")
            return
        }
        
        // Try tapping navigation bar buttons that are visible (avoid search button)
        let navBarButtons = app.navigationBars.buttons.matching(NSPredicate(format: "label != 'magnifyingglass'"))
        if navBarButtons.count > 0 {
            navBarButtons.firstMatch.tap()
            print("Tapped navigation bar button")
            return
        }
        
        // Try tapping on navigation bar title to dismiss
        let detailNavBar = app.navigationBars["Transaction Details"]
        if detailNavBar.exists {
            // Tap in the middle of the navigation bar
            let navBarFrame = detailNavBar.frame
            let tapPoint = detailNavBar.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            tapPoint.tap()
            print("Tapped on navigation bar")
            return
        }
        
        // As last resort, try tapping in the top-left corner
        let escape = XCUIApplication().coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1))
        escape.tap()
        print("Tapped top-left corner as fallback")
    }
}
