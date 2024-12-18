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
    @State private var showLongPressConfirmation = false // Stato per la conferma di lunga pressione
    @State private var cardToDeleteOnLongPress: String? = nil // Card da eliminare con lunga pressione
    
    // Definiamo i GridItem per la disposizione delle card nella griglia
    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)] // Due colonne con uno spazio tra le card
    
    // Carica le card salvate in UserDefaults all'inizializzazione
    init() {
        if let savedCards = UserDefaults.standard.array(forKey: "cards") as? [String] {
            _cards = State(initialValue: savedCards)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Bottone "+"
            HStack {
                Spacer()
                Button(action: {
                    addCard()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.accentColor)
                    }
                }
                .accessibilityLabel("Aggiungi una spesa") // Etichetta di accessibilità
                .accessibilityHint("Tap to add a new album") // Suggerimento di
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
                                        deleteCard(card)
                                    }) {
                                        Text("Delete")
                                        Image(systemName: "trash")
                                    }
                                }
                        }
                        .gesture(
                            LongPressGesture(minimumDuration: 1.0)
                                .onEnded { _ in
                                    cardToDeleteOnLongPress = card
                                    showLongPressConfirmation = true
                                }
                        )
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
            Button("Cancel", role: .cancel, action: {})
        }
        .alert(isPresented: $showLongPressConfirmation) {
            Alert(
                title: Text("Delete Album"),
                message: Text("Do you want to delete the album \(cardToDeleteOnLongPress ?? "")?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let card = cardToDeleteOnLongPress {
                        deleteCard(card) // Rimuovi la card e aggiorna la UI
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // Funzioni di utilità
    func addCard() {
        cards.append("New Album \(cards.count + 1)")
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
