//
//  ASBInterviewExerciseTests.swift
//  ASBInterviewExerciseTests
//
//  Created by ASB on 29/07/21.
//

import XCTest
@testable import ASBInterviewExercise
import Combine

class ASBInterviewExerciseTests: XCTestCase {

    override func setUpWithError() throws {
        // Initialize any shared resources before each test
        // Example: Set up a clean, consistent environment for test data
        UIPreviewStateManager.shared.previewStateManager = PreviewStateManager()
    }

    override func tearDownWithError() throws {
        // Clean up any resources after each test
        // Example: Remove any mock data or reset shared states
        UIPreviewStateManager.shared.previewStateManager = nil
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // Test performance of filter operations on a large dataset
        let viewModel = TransactionViewModel(networkService: MockNetworkService())
        
        // Create test data with many transactions
        var largeDataset: [Transaction] = []
        for i in 1...1000 {
            largeDataset.append(Transaction(
                id: i,
                transactionDate: Date(),
                summary: i % 2 == 0 ? "Income \(i)" : "Expense \(i)",
                debit: i % 2 == 0 ? 0 : Double(i),
                credit: i % 2 == 0 ? Double(i) : 0
            ))
        }
        
        viewModel.transactions = largeDataset
        
        // Measure performance of filtering operations
        self.measure {
            // Filter all transactions
            let _ = viewModel.filteredTransactions
            
            // Apply different filters and search
            viewModel.filterType = .income
            let _ = viewModel.filteredTransactions
            
            viewModel.filterType = .expense
            let _ = viewModel.filteredTransactions
            
            viewModel.searchText = "10"
            let _ = viewModel.filteredTransactions
        }
    }

    // Test Transaction model
    func testTransactionModel() {
        // Create test data
        let income = Transaction(
            id: 1,
            transactionDate: Date(),
            summary: "Salary Income",
            debit: 0,
            credit: 5000.0
        )
        
        let expense = Transaction(
            id: 2,
            transactionDate: Date(),
            summary: "Grocery, Shopping",
            debit: 350.0,
            credit: 0
        )
        
        // Test type detection
        XCTAssertEqual(income.type, .income)
        XCTAssertEqual(expense.type, .expense)
        
        // Test amount calculation
        XCTAssertEqual(income.amount, 5000.0)
        XCTAssertEqual(expense.amount, 350.0)
        
        // Test category logic
        XCTAssertEqual(income.category, "Salary Income")
        XCTAssertEqual(expense.category, "Grocery") // Should take part before comma
        
        // Test GST calculation (15%)
        let viewModel = TransactionViewModel(networkService: MockNetworkService())
        XCTAssertEqual(viewModel.calculateGST(for: 100), 15.0)
    }
    
    // Test network service
    func testMockNetworkService() {
        let expectation = self.expectation(description: "Fetch transactions")
        let mockService = MockNetworkService()
        
        var receivedTransactions: [Transaction] = []
        var cancellables = Set<AnyCancellable>()
        
        mockService.fetchTransactions()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Request failed with \(error)")
                }
                expectation.fulfill()
            }, receiveValue: { transactions in
                receivedTransactions = transactions
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // Verify we received the expected sample data
        XCTAssertFalse(receivedTransactions.isEmpty)
        XCTAssertEqual(receivedTransactions.count, Transaction.sampleData.count)
    }
    
    // Test view model filtering logic
    func testViewModelFiltering() {
        let viewModel = TransactionViewModel(networkService: MockNetworkService())
        
        // Manually set some test data
        viewModel.transactions = [
            Transaction(id: 1, transactionDate: Date(), summary: "Income Test", debit: 0, credit: 100),
            Transaction(id: 2, transactionDate: Date(), summary: "Expense Test", debit: 50, credit: 0)
        ]
        
        // Test all transactions
        viewModel.filterType = .all
        XCTAssertEqual(viewModel.filteredTransactions.count, 2)
        
        // Test income only
        viewModel.filterType = .income
        XCTAssertEqual(viewModel.filteredTransactions.count, 1)
        XCTAssertEqual(viewModel.filteredTransactions.first?.id, 1)
        
        // Test expense only
        viewModel.filterType = .expense
        XCTAssertEqual(viewModel.filteredTransactions.count, 1)
        XCTAssertEqual(viewModel.filteredTransactions.first?.id, 2)
        
        // Test search
        viewModel.filterType = .all
        viewModel.searchText = "income"
        XCTAssertEqual(viewModel.filteredTransactions.count, 1)
        XCTAssertEqual(viewModel.filteredTransactions.first?.id, 1)
    }
}
