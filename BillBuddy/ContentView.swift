//
//  ContentView.swift
//  BillBuddy
//
//  Created by Michele Mariniello on 09/12/24.
//
import SwiftUI

struct ContentView: View {
    @State private var isAddExpenseViewPresented = false  // Variabile per gestire la visibilità della vista modale
    @State private var expenses: [Expense] = []  // Lista di spese
    @State private var selectedTab = 0  // Variabile per tenere traccia della tab selezionata
    @StateObject private var groupStore = GroupsModel()  // Istanza condivisa del modello GroupsModel

    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: $selectedTab) {
                    GroupsView(groupStore: groupStore)
                        .tabItem {
                            Label("Groups", systemImage: "rectangle.3.group.fill")
                        }
                        .tag(0)
                    FriendsView()
                        .tabItem {
                            Label("Friends", systemImage: "person.2.fill")
                        }
                        .tag(1)
                    AccountView()
                        .tabItem {
                            Label("Profile", systemImage: "gearshape.fill")
                        }
                        .tag(4)
                }
            }
            // Quando isAddExpenseViewPresented è true, si apre la sheet
            .sheet(isPresented: $isAddExpenseViewPresented) {
                AddExpenseView(isPresented: $isAddExpenseViewPresented, groupStore: groupStore, expenses: $expenses)
            }
        }
    }
}

#Preview {
    ContentView()
}
