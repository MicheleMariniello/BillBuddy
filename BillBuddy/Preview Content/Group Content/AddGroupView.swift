//
//  AddGroupView.swift
//  BillBuddy
//
//  Created by Michele Mariniello on 10/12/24.
//
//Corretto
import SwiftUI

struct AddGroupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var groupName = ""
    @State private var participantName = ""
    @State private var participants: [String] = [] // Array dei partecipanti

    var onAddGroup: (String, [String]) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Group Details")) {
                    TextField("Group Name", text: $groupName)
                }

                Section(header: Text("Participants")) {
                    ForEach(participants, id: \.self) { participant in
                        HStack {
                            Text(participant)
                            Spacer()
                            Button(action: {
                                removeParticipant(participant)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    HStack {
                        TextField("Add Participant", text: $participantName)
                            .disableAutocorrection(true)
                        Button(action: addParticipant) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.accentColor2)
                        }
                        .disabled(participantName.isEmpty) // Disabilita se il campo è vuoto
                    }
                }
            }
//            .navigationTitle("Add Group")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        onAddGroup(groupName, participants)
                        dismiss()
                    }
                    .disabled(groupName.isEmpty || participants.isEmpty) // Disabilita se i dati non sono completi
                }
            }
        }
    }

    // Funzione per aggiungere un partecipante
    private func addParticipant() {
        participants.append(participantName.trimmingCharacters(in: .whitespacesAndNewlines))
        participantName = ""
    }

    // Funzione per rimuovere un partecipante
    private func removeParticipant(_ participant: String) {
        participants.removeAll { $0 == participant }
    }
}

struct AddGroupView_Previews: PreviewProvider {
    static var previews: some View {
        AddGroupView { name, participants in
            print("Group Name: \(name)")
            print("Participants: \(participants)")
        }
    }
}
