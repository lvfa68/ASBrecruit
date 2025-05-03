//
//  TransactionListView.swift
//  ASBInterviewExercise
//
//  Created by Lvfa on 03/05/2025.
//

import SwiftUI

// Helper for previews
class UIPreviewStateManager {
    static let shared = UIPreviewStateManager()
    
    var previewStateManager: PreviewStateManager?
}

class PreviewStateManager {
    let viewModel = TransactionViewModel(networkService: MockNetworkService())
}

struct TransactionListView: View {
    // Modified to use environment object or fallback to a manually created one
    @StateObject private var viewModel: TransactionViewModel = {
        if let stateManager = UIPreviewStateManager.shared.previewStateManager {
            return stateManager.viewModel
        } else {
            return TransactionViewModel(networkService: AppConfig.shared.getNetworkService())
        }
    }()
    
    @State private var showingDetail = false
    @State private var selectedTransaction: Transaction?
    @State private var isShowingSearchBar = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Filter options
                Picker("Filter", selection: $viewModel.filterType) {
                    Text("All").tag(TransactionViewModel.FilterType.all)
                    Text("Income").tag(TransactionViewModel.FilterType.income)
                    Text("Expense").tag(TransactionViewModel.FilterType.expense)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Search bar
                if isShowingSearchBar {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search transactions...", text: $viewModel.searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            viewModel.searchText = ""
                            withAnimation {
                                isShowingSearchBar = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Transaction list
                ZStack {
                    // Content
                    List {
                        if viewModel.sortedDates.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                            Text("No transactions found matching criteria")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(viewModel.sortedDates, id: \.self) { dateKey in
                                Section(header: Text(viewModel.formatSectionDate(dateKey))) {
                                    ForEach(viewModel.groupedTransactions[dateKey] ?? []) { transaction in
                                        TransactionRow(transaction: transaction, viewModel: viewModel)
                                            .onTapGesture {
                                                selectedTransaction = transaction
                                                showingDetail = true
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .onAppear {
                        viewModel.fetchTransactions()
                    }
                    
                    // Loading indicator
                    if viewModel.isLoading {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding()
                            Text("Loading...")
                                .font(.headline)
                                .padding(.top)
                        }
                        .frame(width: 120, height: 120)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                    }
                    
                    // Error message overlay
                    if let errorMessage = viewModel.errorMessage {
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40))
                                .foregroundColor(.red)
                                .padding(.bottom, 8)
                            
                            Text("Error")
                                .font(.headline)
                                .padding(.bottom, 4)
                            
                            Text(errorMessage)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 12)
                            
                            Button(action: {
                                viewModel.refresh()
                            }) {
                                Text("Retry")
                                    .bold()
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(20)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .padding()
                    }
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            isShowingSearchBar.toggle()
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.refresh()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showingDetail, onDismiss: {
                selectedTransaction = nil
            }) {
                if let transaction = selectedTransaction {
                    TransactionDetailView(transaction: transaction)
                }
            }
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    @ObservedObject var viewModel: TransactionViewModel
    
    var body: some View {
        HStack {
            // Transaction icon
            Image(systemName: transaction.type == .income ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .font(.title2)
                .foregroundColor(transaction.color)
                .frame(width: 40)
                .accessibilityLabel(transaction.type == .income ? "Income" : "Expense")
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.summary)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(transaction.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.type == .income ? "+\(transaction.formattedAmount)" : "-\(transaction.formattedAmount)")
                    .font(.headline)
                    .foregroundColor(transaction.color)
                
                // GST info for the row
                Text("GST: \(viewModel.formattedGST(for: transaction.amount))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(transaction.type.rawValue): \(transaction.summary), Amount: \(transaction.formattedAmount), GST: \(viewModel.formattedGST(for: transaction.amount))")
    }
}

#Preview {
    UIPreviewStateManager.shared.previewStateManager = PreviewStateManager()
    return TransactionListView()
}
