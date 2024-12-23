//
//  PhotosView.swift
//  BillBuddy
//
//  Created by Michele Mariniello on 09/12/24.
//
import SwiftUI

struct PhotosView: View {
    @State private var cards: [String] = [] // Inizializza con un array vuoto di Cards
    @State private var cardToDelete: String? = nil // Card da eliminare
    @State private var showDeleteConfirmation = false // Stato per confermare la cancellazione
    
    @State private var albumCounter = 0 // Contatore per gli album
    @State private var showSheet = false // Stato per il foglio di input
    @State private var newAlbumName = "" // Nome dell'album da creare
    
    // Definiamo i GridItem per la disposizione delle card nella griglia
    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)] // Due colonne con uno spazio tra le card
    
    // Carica le card salvate in UserDefaults all'inizializzazione
    init() {
        if let savedCards = UserDefaults.standard.array(forKey: "cards") as? [String] {
            _cards = State(initialValue: savedCards)
            albumCounter = savedCards.count // Imposta il contatore sull'ultimo numero di album
        }
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
                LazyVGrid(columns: columns, spacing: 15) {
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
            // Finestra per inserire il nome dell'album
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
                    .disabled(newAlbumName.isEmpty) // Disabilita il pulsante se il campo è vuoto
                }
            }
            .padding()
        }
    }
    
    // Funzione per aggiungere una nuova card con nome personalizzato
    func addCard(with name: String) {
        albumCounter += 1
        cards.append(name) // Usa il nome inserito
        saveCards()
    }
    
    func deleteCard(_ card: String) {
        if let index = cards.firstIndex(of: card) {
            cards.remove(at: index)
            saveCards()
        }
    }
    
    func saveCards() {
        UserDefaults.standard.set(cards, forKey: "cards")
    }
}

struct PhotosView_Previews: PreviewProvider {
    static var previews: some View {
        PhotosView()
    }
}
