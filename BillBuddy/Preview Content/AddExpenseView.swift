//
//  AddExpenseView.swift
//  BillBuddy
//
//  Created by Michele Mariniello on 09/12/24.
//
import SwiftUI

// Modello Expense
struct Expense: Codable {
    var group: String
    var name: String
    var amount: Double
    var payer: String
    var category: String
    var participants: [String]
    var contributions: [String: Double] // Nuovo campo per i contributi
}

struct AddExpenseView: View {
    @Binding var isPresented: Bool  // Gestione della visibilità
    @ObservedObject var groupStore: GroupsModel  // Modello condiviso
    @State private var group = ""
    @State private var expenseName = ""
    @State private var amount = ""
    @State private var payer = ""
    @State private var category = ""
    @State private var selectedParticipants: Set<String> = []  // Partecipanti selezionati
    @State private var contributions: [String: Double] = [:]  // Contributi personalizzati
    @State private var showAlert = false  // Stato per mostrare l'alert
    @State private var missingFields: [String] = []  // Campi mancanti
    
    let categories = ["Accommodation", "Food", "Travel", "Other"]
    
    @Binding var expenses: [Expense]
    
    // Formatter per formattare numeri con la virgola e precisione al centesimo
    let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = "."
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details").font(.callout)) {
                    Picker("Group", selection: $group) {
                        ForEach(groupStore.groups.map { $0.name }, id: \ .self) { groupName in
                            Text(groupName).tag(groupName)
                        }
                    }
                    .onChange(of: group) {
                        selectedParticipants.removeAll() // Resetta i partecipanti quando cambia gruppo
                        contributions.removeAll()
                    }
                    
                    TextField("Description of the expense", text: $expenseName)
                    TextField("Amount (€)", text: $amount)
                        .keyboardType(.decimalPad)
                        .onChange(of: amount) {
                            updateContributions()
                        }
                    
                    // Payer Picker
                    if let selectedGroup = groupStore.groups.first(where: { $0.name == group }) {
                        Picker("Payer", selection: $payer) {
                            ForEach(selectedGroup.participants, id: \ .self) { participant in
                                Text(participant).tag(participant)
                            }
                        }
                        .pickerStyle(MenuPickerStyle()) // Usa un menu a tendina
                    }
                }
                
//                Section(header: Text("Category")) {
//                    Picker("Category", selection: $category) {
//                        ForEach(categories, id: \ .self) { category in
//                            Text(category)
//                        }
//                    }
//                    .pickerStyle(MenuPickerStyle())
//                }
                
                Section(header: Text("Participants").font(.callout)) {
                    if let selectedGroup = groupStore.groups.first(where: { $0.name == group }) {
                        ForEach(selectedGroup.participants, id: \ .self) { participant in
                            HStack {
                                // Nome del partecipante a sinistra
                                Text(participant)
                                    .frame(width: 130, alignment: .leading) // Nome del partecipante con spazio maggiore
                                    .padding(.leading, 20)
                                
                                // Contributo a sinistra
                                TextField("0", value: Binding(
                                    get: { contributions[participant] ?? 0.0 },
                                    set: { contributions[participant] = $0 }
                                ), formatter: currencyFormatter)
                                .frame(width: 75) // Larghezza del campo di input per il contributo
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center) // Centra il testo nel campo
                                
                                // Simbolo dell'euro a destra del contributo
                                Text("\u{20AC}")
                                    .frame(width: 15)
                                
                                // Bottone per selezionare il partecipante a destra
                                Button(action: {
                                    if selectedParticipants.contains(participant) {
                                        selectedParticipants.remove(participant)
                                    } else {
                                        selectedParticipants.insert(participant)
                                    }
                                    updateContributions()
                                }) {
                                    Image(systemName: selectedParticipants.contains(participant) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedParticipants.contains(participant) ? .green : .gray)
                                }
                                .frame(width: 40, alignment: .center)
                            }
                            .padding(.vertical, 5)
                        }
                        
                        if !isContributionsValid() {
                            Text("The total contributions must equal the expense amount.")
                                .foregroundColor(.red)
                        }
                    } else {
                        Text("Please select a group to see participants")
                            .foregroundColor(.gray)
                    }
                }                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        validateFieldsBeforeSave()
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Missing Information"),
                    message: Text("Please fill in the following fields: \(missingFields.joined(separator: ", "))"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    func updateContributions() {
        guard let amountDouble = Double(amount), !selectedParticipants.isEmpty else {
            // Se nessun partecipante è selezionato, azzera tutti i contributi
            contributions.removeAll()
            return
        }
        
        // Rimuove i partecipanti non selezionati dai contributi
        for participant in contributions.keys where !selectedParticipants.contains(participant) {
            contributions[participant] = 0.0
        }
        
        // Ricalcola i contributi equamente tra tutti i partecipanti selezionati
        let equalShare = amountDouble / Double(selectedParticipants.count)
        
        // Assegna a tutti i partecipanti selezionati il contributo calcolato
        for participant in selectedParticipants {
            contributions[participant] = equalShare
        }
    }
    
    func isContributionsValid() -> Bool {
        guard let amountDouble = Double(amount) else { return false }
        let totalContributions = contributions.values.reduce(0, +)
        return abs(totalContributions - amountDouble) < 0.01
    }
    
    func validateFieldsBeforeSave() {
        missingFields.removeAll()
        if group.isEmpty {
            missingFields.append("Group")
        }
        if expenseName.isEmpty {
            missingFields.append("Expense Name")
        }
        if Double(amount) == nil || amount.isEmpty {
            missingFields.append("Amount")
        }
        if payer.isEmpty {
            missingFields.append("Payer")
        }
        if !missingFields.isEmpty {
            showAlert = true
        } else if isContributionsValid() {
            saveExpense()
            isPresented = false
        }
    }
    
    func saveExpense() {
        guard let amountDouble = Double(amount) else { return }
        
        let newExpense = Expense(
            group: group,
            name: expenseName,
            amount: amountDouble,
            payer: payer,
            category: category,
            participants: Array(selectedParticipants),
            contributions: contributions
        )
        
        // Aggiungi la spesa al gruppo corrispondente
        if let groupIndex = groupStore.groups.firstIndex(where: { $0.name == group }) {
            groupStore.addExpense(to: groupStore.groups[groupIndex], expense: newExpense) // Aggiungi la spesa e salva
        }
        isPresented = false
    }
}

struct AddExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExpenseView(
            isPresented: .constant(true),
            groupStore: GroupsModel(),  // Placeholder di GroupsModel
            expenses: .constant([])     // Placeholder di expenses
        )
    }
}
