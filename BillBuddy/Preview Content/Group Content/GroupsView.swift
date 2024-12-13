//
//  GroupsView.swift
//  BillBuddy
//
//  Created by Michele Mariniello on 09/12/24.
//
import SwiftUI

// Modello Group
struct Group: Identifiable, Codable {
    var id: UUID
    var name: String
    var participants: [String]
    var expenses: [Expense] // Lista di spese

    // Inizializzatore
    init(id: UUID = UUID(), name: String, participants: [String], expenses: [Expense] = []) {
        self.id = id
        self.name = name
        self.participants = participants
        self.expenses = expenses
    }
}


class GroupsModel: ObservableObject {
    @Published var groups: [Group] = [] // Lista di gruppi condivisi

    init() {
        loadGroups()
    }

    func addGroup(name: String, participants: [String]) {
        let newGroup = Group(name: name, participants: participants)
        groups.append(newGroup)
        saveGroups()
    }

    func deleteGroup(_ group: Group) {
        groups.removeAll { $0.id == group.id }
        saveGroups()
    }

    private func saveGroups() {
        if let encoded = try? JSONEncoder().encode(groups) {
            UserDefaults.standard.set(encoded, forKey: "SavedGroups")
        }
    }

    private func loadGroups() {
        if let savedData = UserDefaults.standard.data(forKey: "SavedGroups"),
           let decodedGroups = try? JSONDecoder().decode([Group].self, from: savedData) {
            groups = decodedGroups
        }
    }
}

struct GroupsView: View {
    @ObservedObject var groupStore: GroupsModel // Modifica per accettare GroupsModel come parametro
    @State private var showAddGroupSheet = false // Stato per mostrare il foglio di aggiunta gruppo
    @State private var groupToDelete: Group? = nil // Gruppo da cancellare
    @State private var showDeleteConfirmation = false // Stato per confermare la cancellazione
    @State private var showLongPressConfirmation = false // Stato per la conferma di lunga pressione
    @State private var groupToDeleteOnLongPress: Group? = nil // Gruppo da cancellare con lunga pressione

    var body: some View {
        NavigationView {
            ScrollView { // Usa ScrollView per consentire lo scorrimento delle Cards
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) { // 2 colonne per le Cards
                    ForEach(groupStore.groups) { group in
                        NavigationLink(destination: GroupDetailView(groupName: group.name, groupStore: groupStore)) {
                            ZStack {
                                // Card
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.accentColor3)
//                                    .shadow(radius: 5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.accentColor, lineWidth: 2)
                                            )// Aggiunge un bordo rosso
                                VStack(alignment: .leading) {
                                    Text(group.name) // Visualizza solo il nome del gruppo
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.accentColor)
                                        .padding([.top, .leading, .trailing])
                                }
                            }
                            .frame(height: 150) // Altezza della Card
                            .gesture(
                                LongPressGesture(minimumDuration: 1.0) // Rileva lunga pressione
                                    .onEnded { _ in
                                        groupToDeleteOnLongPress = group
                                        showLongPressConfirmation = true
                                    }
                            )
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                groupToDelete = group
                                showDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding()
            }//end ScrollView
            .background(Color.accentColor5.ignoresSafeArea())
            .navigationTitle("Groups")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddGroupSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddGroupSheet) {
                AddGroupView { name, participants in
                    groupStore.addGroup(name: name, participants: participants)
                }
            }
            .confirmationDialog(
                "Are you sure you want to delete this group?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let group = groupToDelete {
                        groupStore.deleteGroup(group)
                    }
                }
                Button("Cancel", role: .cancel, action: {})
            }
            .alert(isPresented: $showLongPressConfirmation) {
                Alert(
                    title: Text("Delete Group"),
                    message: Text("Do you want to delete the group \(groupToDeleteOnLongPress?.name ?? "")?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let group = groupToDeleteOnLongPress {
                            groupStore.deleteGroup(group)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}


struct GroupsView_Previews: PreviewProvider {
    static var previews: some View {
        GroupsView(groupStore: GroupsModel()) // Inizializza il modello dei gruppi
            .onAppear {
                // Popola i gruppi con dati di esempio
                let sampleGroup1 = Group(name: "Group 1", participants: ["Alice", "Bob"])
                let sampleGroup2 = Group(name: "Group 2", participants: ["Charlie", "David"])
                let model = GroupsModel()
                model.groups = [sampleGroup1, sampleGroup2]
            }
    }
}
