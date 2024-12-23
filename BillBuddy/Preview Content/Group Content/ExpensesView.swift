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
    
    // Calcola la somma di tutte le spese
    private var totalExpenses: Double {
        group.expenses.reduce(0) { $0 + $1.amount }
    }
    
    // Calcola la somma delle spese che l'utente deve pagare (la sua parte)
    private var myExpenses: Double {
        group.expenses.reduce(0) { total, expense in
            // Se l'utente è un partecipante della spesa, aggiungi la sua parte
            if expense.participants.contains("me") {
                let share = expense.amount / Double(expense.participants.count)
                return total + share
            }
            return total
        }
    }
    
    private func formattedForAccessibility(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Contenitore per il bottone, allineato a destra
            HStack {
                Spacer()
                Button(action: {
                    isAddExpenseViewPresented = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.accentColor)
                    }
                }
                .accessibilityLabel("Button plus") // Etichetta di accessibilità
                .accessibilityHint("Tap to add a new expense") // Suggerimento di accessibilità
                .padding()
            }
            .background(Color.accentColor5)
            
            // Somma delle spese
            HStack {
                Spacer()
                VStack {
                    Text("My Expenses:")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                    Text("\(String(format: "%.2f", myExpenses))€")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("My Expenses \(formattedForAccessibility(myExpenses))")
                Spacer()
                VStack {
                    Text("Total Expenses:")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                    Text("\(String(format: "%.2f", totalExpenses))€")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Total Expenses \(formattedForAccessibility(totalExpenses))")
                Spacer()
            }
            .padding(.horizontal) // Margini laterali
            .padding(.vertical, 8) // Margine verticale
            .background(Color.gray.opacity(0.1)) // Sfondo per la sezione
            
            // Lista delle spese
            List {
                ForEach(group.expenses, id: \.name) { expense in
                    HStack {
                        Text(expense.name)
                            .frame(width: 100, alignment: .leading) // Larghezza fissa per il nome
                        Spacer()
                        Text(String(format: "%.2f", expense.amount) + "€")
                            .frame(width: 70, alignment: .trailing) // Larghezza fissa per l'importo
                        Spacer()
                        Text("Paid by \(expense.payer)")
                            .frame(width: 130, alignment: .trailing) // Larghezza fissa per "Paid by"
                    }
                    .onLongPressGesture {
                        expenseToDelete = expense
                        showDeleteConfirmation = true
                    }
                    .accessibilityElement(children: .combine) // Combinare tutti gli elementi figli come un'unica unità
                    .accessibilityLabel("\(expense.name), \(String(format: "%.2f", expense.amount))€, Paid by \(expense.payer)") // Descrizione dell'elemento
                }
                
                //PER ELIMINARE LA SPESA CON LO SWIPE
//                .onDelete { indexSet in
//                    deleteExpense(at: indexSet)
//                }
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
        .navigationTitle(group.name)
    }
    
    func deleteExpense(expense: Expense) {
        if let index = group.expenses.firstIndex(where: { $0.name == expense.name }) {
            groupStore.removeExpense(from: group, at: index)
        }
    }
    
    //FUNZIONE CHE PERMETTE DI ELIMINARE LA FUNZIONE CON LO SWIPE
//    func deleteExpense(at offsets: IndexSet) {
//        if let index = offsets.first {
//            groupStore.removeExpense(from: group, at: index)
//        }
//    }
    
}

//struct ExpensesView_Previews: PreviewProvider {
//    static var previews: some View {
//        let groupStore = GroupsModel()
//        ExpensesView(groupStore: groupStore)
//    }
//}
