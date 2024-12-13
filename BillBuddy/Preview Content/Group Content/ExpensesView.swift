//
//  ExpensesView.swift
//  BillBuddy
//
//  Created by Michele Mariniello on 09/12/24.
//
import SwiftUI

struct ExpensesView: View {
    @State private var expenses: [Expense] = []  // Lista delle spese
    @State private var isAddExpenseViewPresented = false  // Variabile per gestire la visibilità della vista modale
    @ObservedObject var groupStore: GroupsModel  // Modello condiviso

    @State private var expenseToDelete: Expense?  // Spesa selezionata per eliminazione
    @State private var showDeleteConfirmation = false  // Mostra l'alert di conferma

    var body: some View {
        VStack {
            List {
                ForEach(expenses, id: \.name) { expense in
                    Text("\(expense.name)     \(String(format: "%.2f", expense.amount))€    payed by \(expense.payer) ")
                        .font(.headline)
                        .onLongPressGesture {
                            expenseToDelete = expense
                            showDeleteConfirmation = true
                        }
                }
            }
        }
        .navigationTitle("Expenses") // Gestione del titolo
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isAddExpenseViewPresented = true
                }) {
                    Image(systemName: "plus.circle") // Icona di aggiunta
                        .font(.title2) // Dimensione del font per l'icona
                }
            }
        }
        .sheet(isPresented: $isAddExpenseViewPresented) {
            AddExpenseView(isPresented: $isAddExpenseViewPresented, groupStore: groupStore, expenses: $expenses)
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Expense"),
                message: Text("Are you sure you want to delete this expense?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let expense = expenseToDelete {
                        deleteExpense(expense)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            loadExpenses()
        }
    }

    // Funzione per caricare le spese salvate
    func loadExpenses() {
        if let data = UserDefaults.standard.data(forKey: "SavedExpenses"),
           let savedExpenses = try? JSONDecoder().decode([Expense].self, from: data) {
            expenses = savedExpenses
        }
    }

    // Elimina la spesa
    func deleteExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.name == expense.name }) {
            expenses.remove(at: index)
            saveExpenses() // Aggiorna UserDefaults
        }
    }

    // Salva le spese in UserDefaults
    func saveExpenses() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: "SavedExpenses")
        }
    }
}



struct ExpensesView_Previews: PreviewProvider {
    static var previews: some View {
        let groupStore = GroupsModel()
        ExpensesView(groupStore: groupStore)
    }
}
