//
//  AddGroupView.swift
//  BillBuddy
//
//  Created by Michele Mariniello on 10/12/24.
//
import SwiftUI

struct AddGroupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var groupName = ""
    @State private var participantName = ""
    @State private var participants: [String] = [] // Array dei partecipanti
    @State private var isFirstParticipant = true // Flag per identificare il primo partecipante
    
    var onAddGroup: (String, [String]) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Group Details")) {
                    TextField("Group Name", text: $groupName)
                }
                
                Section(header: Text("Participants")) {
                    Text("The first participant you add is you.\nYou will be identified as 'me'.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
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
                                .foregroundColor(.accentColor)
                        }
                        .disabled(participantName.isEmpty) // Disabilita se il campo è vuoto
                    }
                }
            }
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
        
        // Imposta il primo partecipante come "me"
        if isFirstParticipant {
            participants[0] = "me"  // Modifica il primo partecipante a "me"
            isFirstParticipant = false
        }
        
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
