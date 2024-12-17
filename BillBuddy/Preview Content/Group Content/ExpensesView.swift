//
//  ExpensesView.swift
//  BillBuddy
//
//  Created by Michele Mariniello on 09/12/24.
//
import SwiftUI

struct ExpensesView: View {
    @ObservedObject var groupStore: GroupsModel
    var group: Group
    @State private var isAddExpenseViewPresented = false
    @State private var expenseToDelete: Expense?
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(spacing: 0) { // Aggiungo uno spazio tra i componenti
            // Contenitore per il bottone, allineato a destra
            HStack {
                Spacer() // Spinge il bottone a destra
                Button(action: {
                    isAddExpenseViewPresented = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.accentColor)
                    }
                }
                .padding()
            }
            .background(Color.accentColor5)
            
            // Lista delle spese
            List {
                ForEach(group.expenses, id: \.name) { expense in
                    Text("\(expense.name) - \(String(format: "%.2f", expense.amount))€ - Paid by \(expense.payer)")
                        .font(.headline)
                        .onLongPressGesture {
                            expenseToDelete = expense
                            showDeleteConfirmation = true
                        }
                }
                .onDelete { indexSet in
                    deleteExpense(at: indexSet)
                }
            }
            .confirmationDialog("Are you sure you want to delete this expense?",
                                isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    if let expense = expenseToDelete {
                        deleteExpense(expense: expense)
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
        .sheet(isPresented: $isAddExpenseViewPresented) {
            AddExpenseView(
                isPresented: $isAddExpenseViewPresented,
                groupStore: groupStore,
                expenses: Binding(
                    get: { group.expenses },
                    set: { _ in } // Non modificabile direttamente
                )
            )
        }
        .navigationTitle("Expenses")
    }

    func deleteExpense(at offsets: IndexSet) {
        if let index = offsets.first {
            groupStore.removeExpense(from: group, at: index)
        }
    }

    func deleteExpense(expense: Expense) {
        if let index = group.expenses.firstIndex(where: { $0.name == expense.name }) {
            groupStore.removeExpense(from: group, at: index)
        }
    }
}

//struct ExpensesView_Previews: PreviewProvider {
//    static var previews: some View {
//        let groupStore = GroupsModel()
//        ExpensesView(groupStore: groupStore)
//    }
//}
