//
//  TransactionViewModel.swift
//  ASBInterviewExercise
//
//  Created by Lvfa on 03/05/2025.
//

import Foundation
import Combine
import SwiftUI

class TransactionViewModel: ObservableObject {
    // Published states
    @Published var transactions: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Network service
    private let networkService: NetworkServiceProtocol
    // Store cancellation tokens
    private var cancellables = Set<AnyCancellable>()
    
    // Filter type and search options
    @Published var filterType: FilterType = .all
    @Published var searchText: String = ""
    
    // Filter enumeration
    enum FilterType {
        case all, income, expense
        
        var title: String {
            switch self {
            case .all: return "All"
            case .income: return "Income"
            case .expense: return "Expense"
            }
        }
    }
    
    // Initialization
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    // Fetch transactions
    func fetchTransactions() {
        isLoading = true
        errorMessage = nil
        
        networkService.fetchTransactions()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    if let networkError = error as? NetworkError {
                        self?.errorMessage = networkError.description
                    } else {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }, receiveValue: { [weak self] transactions in
                self?.transactions = transactions
            })
            .store(in: &cancellables)
    }
    
    // Filter transactions
    var filteredTransactions: [Transaction] {
        var filtered = transactions
        
        // Filter by type
        switch filterType {
        case .all: break
        case .income:
            filtered = filtered.filter { $0.type == .income }
        case .expense:
            filtered = filtered.filter { $0.type == .expense }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.summary.lowercased().contains(searchText.lowercased())
            }
        }
        
        return filtered
    }
    
    // Calculate GST (15%)
    func calculateGST(for amount: Double) -> Double {
        return amount * 0.15
    }
    
    // Format GST amount as string
    func formattedGST(for amount: Double) -> String {
        let gst = calculateGST(for: amount)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: gst)) ?? "$\(gst)"
    }
    
    // Group transactions by date, with time sorting
    var groupedTransactions: [String: [Transaction]] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var result = [String: [Transaction]]()
        
        for transaction in filteredTransactions {
            let dateKey = dateFormatter.string(from: transaction.transactionDate)
            if result[dateKey] == nil {
                result[dateKey] = [transaction]
            } else {
                result[dateKey]?.append(transaction)
            }
        }
        
        // Sort transactions within each date group (newest first)
        for (dateKey, transactions) in result {
            result[dateKey] = transactions.sorted { (t1, t2) -> Bool in
                return t1.transactionDate > t2.transactionDate
            }
        }
        
        return result
    }
    
    // Sorted date keys
    var sortedDates: [String] {
        groupedTransactions.keys.sorted().reversed()
    }
    
    // Format section date for display
    func formatSectionDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMM dd, yyyy"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
    
    // Refresh data
    func refresh() {
        fetchTransactions()
    }
}
