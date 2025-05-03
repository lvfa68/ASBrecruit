//
//  Transaction.swift
//  ASBInterviewExercise
//
//  Created by Lvfa on 03/05/2025.
//

import Foundation
import SwiftUI

struct Transaction: Identifiable, Codable {
    let id: Int
    let transactionDate: Date
    let summary: String
    let debit: Double
    let credit: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case transactionDate
        case summary
        case debit
        case credit
    }
    
    // Calculate transaction type
    var type: TransactionType {
        credit > 0 ? .income : .expense
    }
    
    // Calculate transaction amount
    var amount: Double {
        credit > 0 ? credit : debit
    }
    
    // Determine category based on summary
    var category: String {
        // Simple example: categorize based on text before first comma
        let parts = summary.components(separatedBy: ",")
        return parts.first ?? "Other"
    }
    
    // Description (using summary directly)
    var description: String {
        return summary
    }
}

// Transaction type enum
enum TransactionType: String, Codable {
    case income = "Income"
    case expense = "Expense"
}

// Extensions for formatting and display
extension Transaction {
    // Formatted amount string
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
    
    // Formatted date string
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: transactionDate)
    }
    
    // Transaction color (green for income, red for expense)
    var color: Color {
        type == .income ? .green : .red
    }
}

// API response structure
struct TransactionsResponse: Decodable {
    let transactions: [Transaction]
}

// Sample data for previews and testing
extension Transaction {
    static var sampleData: [Transaction] = [
        Transaction(
            id: 1,
            transactionDate: Date().addingTimeInterval(-7*24*60*60),
            summary: "Salary Income",
            debit: 0,
            credit: 8000.00
        ),
        Transaction(
            id: 2,
            transactionDate: Date().addingTimeInterval(-5*24*60*60),
            summary: "Supermarket, Groceries",
            debit: 256.50,
            credit: 0
        ),
        Transaction(
            id: 3,
            transactionDate: Date().addingTimeInterval(-3*24*60*60),
            summary: "Movie Tickets, Entertainment",
            debit: 80.00,
            credit: 0
        ),
        Transaction(
            id: 4,
            transactionDate: Date().addingTimeInterval(-1*24*60*60),
            summary: "Freelance Income",
            debit: 0,
            credit: 500.00
        ),
        Transaction(
            id: 5,
            transactionDate: Date(),
            summary: "Restaurant Dinner, Friends Gathering",
            debit: 168.00,
            credit: 0
        )
    ]
}
