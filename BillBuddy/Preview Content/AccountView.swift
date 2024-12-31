//
//  AccountView.swift
//  BillBuddy
//
//  Created by Michele Mariniello on 09/12/24.
//
import SwiftUI

struct AccountView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var currency = "€"
    @State private var isDarkMode = false  // Variabile per la modalità scura
    
    let currencies = ["€", "$", "£"]
    
    var body: some View {
        Form {
            Section(header: Text("User Info").font(.callout)) {
                TextField("Name", text: $username)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
            }
            
            Section(header: Text("Currency").font(.callout)) {
                Picker("Currency", selection: $currency) {
                    ForEach(currencies, id: \.self) { currency in
                        Text(currency)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("Accessibility").font(.callout)) {
                HStack {
                    Text("Dark Mode")
                    Spacer()
                    Toggle(isOn: $isDarkMode) {
                        Text("")
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))  // Aggiungi il colore al toggle
                }
            }
        }
        .navigationTitle("Account")
        .preferredColorScheme(isDarkMode ? .dark : .light)  // Applica la modalità selezionata
        
        Button("Logout"){
            
        }
        .font(.title2)
        .padding()
    }
}

#Preview {
    AccountView()
}
