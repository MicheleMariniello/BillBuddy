//
//  GroupDetailView.swift
//  BillBuddy
//
//  Created by Michele Mariniello on 09/12/24.
//
//Corretto
import SwiftUI

struct GroupDetailView: View {
    var groupName: String
    @State private var selectedTab = 0
    @ObservedObject var groupStore: GroupsModel

    var body: some View {
        VStack {
            // Tab Selection (Picker personalizzato)
            Picker("Select Tab", selection: $selectedTab) {
                Text("Expenses").tag(0)
                Text("Balances").tag(1)
                Text("Photos").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // TabView con swipe orizzontale
            TabView(selection: $selectedTab) {
                ExpensesView(groupStore: groupStore)
                    .tag(0)
//                    .tabItem {
//                        Label("Expenses", systemImage: "list.bullet")
//                    }

                BalancesView()
                    .tag(1)
//                    .tabItem {
//                        Label("Balances", systemImage: "person.2")
//                    }

                PhotosView()
                    .tag(2)
//                    .tabItem {
//                        Label("Photos", systemImage: "photo")
//                    }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
        .navigationTitle("\(groupName)")
    }
}


struct GroupDetailView_Previews: PreviewProvider {
    static var previews: some View {
        GroupDetailView(
            groupName: "Family Trip",
            groupStore: GroupsModel()
        )
    }
}


