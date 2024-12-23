//
//  PhotosView.swift
//  BillBuddy
//
//  Created by Michele Mariniello on 09/12/24.
//
import SwiftUI

struct PhotosView: View {
    @ObservedObject var groupStore: GroupsModel
    var group: Group
    @State private var cards: [String] = [] // Inizializza con un array vuoto di Cards
    @State private var cardToDelete: String? = nil
    @State private var showDeleteConfirmation = false
    @State private var showSheet = false
    @State private var newAlbumName = ""
    
    // Carica le foto del gruppo all'inizializzazione
    init(groupStore: GroupsModel, group: Group) {
        self.groupStore = groupStore
        self.group = group
        self._cards = State(initialValue: loadCards()) // Carica le cards da UserDefaults
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Bottone "+"
            HStack {
                Spacer()
                Button(action: {
                    showSheet = true // Mostra il foglio per inserire il nome dell'album
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.accentColor)
                    }
                }
                .accessibilityHint("Button plus, Tap to add a new album")
                .padding()
            }
            .background(Color.accentColor5)
            
            // Griglia delle cards
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 15) {
                    ForEach(cards, id: \.self) { card in
                        VStack {
                            Text(card)
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding()
                                .frame(width: 180, height: 180)
                                .background(Color.accentColor3)
                                .cornerRadius(15)
                                .foregroundColor(.accentColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.accentColor, lineWidth: 2)
                                )
                                .contextMenu {
                                    Button(action: {
                                        cardToDelete = card
                                        showDeleteConfirmation = true
                                    }) {
                                        Text("Delete")
                                        Image(systemName: "trash")
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
        }
        .background(Color.accentColor5.ignoresSafeArea())
        .confirmationDialog(
            "Are you sure you want to delete this card?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let card = cardToDelete {
                    deleteCard(card) // Rimuovi la card e aggiorna la UI
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showSheet) {
            VStack {
                Text("Enter album name:")
                    .font(.headline)
                TextField("Album Name", text: $newAlbumName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                HStack {
                    Button("Cancel") {
                        showSheet = false
                    }
                    .padding()
                    
                    Button("Save") {
                        addCard(with: newAlbumName)
                        showSheet = false
                    }
                    .padding()
                    .disabled(newAlbumName.isEmpty)
                }
            }
            .padding()
        }
    }
    
    // Funzione per aggiungere una nuova card con nome personalizzato
    func addCard(with name: String) {
        cards.append(name) // Usa il nome inserito
        updateGroupStore() // Aggiorna le foto nel gruppo
    }
    
    func deleteCard(_ card: String) {
        if let index = cards.firstIndex(of: card) {
            cards.remove(at: index)
            updateGroupStore() // Aggiorna le foto nel gruppo
        }
    }
    
    // Funzione per aggiornare il gruppo con le nuove cards
    func updateGroupStore() {
        if let groupIndex = groupStore.groups.firstIndex(where: { $0.id == group.id }) {
            groupStore.groups[groupIndex].photos = cards // Salva le foto nel gruppo
            saveCards() // Salva anche in UserDefaults
        }
    }
    
    func saveCards() {
        UserDefaults.standard.set(cards, forKey: "Photos_\(group.id.uuidString)") // Salva le foto per il gruppo
    }
    
    // Funzione per caricare le cards da UserDefaults
    func loadCards() -> [String] {
        if let savedCards = UserDefaults.standard.array(forKey: "Photos_\(group.id.uuidString)") as? [String] {
            return savedCards
        }
        return [] // Ritorna un array vuoto se non ci sono dati salvati
    }
}



//struct PhotosView_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotosView()
//    }
//}
