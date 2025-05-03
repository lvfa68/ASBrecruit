//
//  TransactionDetailView.swift
//  ASBInterviewExercise
//
//  Created by Lvfa on 03/05/2025.
//


import SwiftUI

struct TransactionDetailView: View {
    let transaction: Transaction
    
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Transaction type and amount
                HStack {
                    Image(systemName: transaction.type == .income ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(transaction.color)
                        .accessibilityHidden(true)
                    
                    VStack(alignment: .leading) {
                        Text(transaction.type.rawValue)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(transaction.type == .income ? "+\(transaction.formattedAmount)" : "-\(transaction.formattedAmount)")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(transaction.color)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(transaction.type.rawValue) amount: \(transaction.formattedAmount)")
                    
                    Spacer()
                    
                    // Transaction ID
                    Text("ID: \(transaction.id)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Transaction ID: \(transaction.id)")
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Transaction details card
                VStack(spacing: 16) {
                    DetailRow(title: "Transaction Name", value: transaction.category)
                    Divider()
                    DetailRow(title: "Summary", value: transaction.summary)
                    Divider()
                    DetailRow(title: "Date", value: transaction.formattedDate)
                    
                    // Show debit or credit amount
                    if transaction.debit > 0 {
                        Divider()
                        DetailRow(title: "Debit Amount", value: formatCurrency(transaction.debit))
                    }
                    
                    if transaction.credit > 0 {
                        Divider()
                        DetailRow(title: "Credit Amount", value: formatCurrency(transaction.credit))
                    }
                    
                    // Show GST amount
                    Divider()
                    DetailRow(title: "GST (15%)", value: formatCurrency(transaction.amount * 0.15))
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Transaction Details")
            .navigationBarTitleDisplayMode(getTitleDisplayMode())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Close")
                    }
                    .accessibilityLabel("Close details page")
                }
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        }
    }
    
    private func getTitleDisplayMode() -> NavigationBarItem.TitleDisplayMode {
        return .inline
    }
    
    // Format currency amount
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}


struct TransactionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionDetailView(transaction: Transaction.sampleData[0])
    }
}
