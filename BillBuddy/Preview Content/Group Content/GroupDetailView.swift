//
//  GroupDetailView.swift
//  BillBuddy
//
//  Created by Michele Mariniello on 09/12/24.
//
import SwiftUI

struct GroupDetailView: View {
    var groupName: String
    @ObservedObject var groupStore: GroupsModel
    
    var group: Group {
        groupStore.groups.first { $0.name == groupName } ?? Group(name: groupName, participants: [])
    }
    
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            if #available(iOS 17.0, *) {
                Picker("Select Tab", selection: $selectedTab) {
                    Text("Expenses").tag(0)
                    Text("Balances").tag(1)
                    Text("Photos").tag(2)
                }
                .pickerStyle(PalettePickerStyle())
                .padding()
            } else {
                // Fallback on earlier versions
            }
            
            TabView(selection: $selectedTab) {
                ExpensesView(groupStore: groupStore, group: group)
                    .tag(0)
                BalancesView(groupStore: groupStore, group: group)
                    .tag(1)
                PhotosView(groupStore: groupStore, group: group)
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
        .navigationTitle(group.name)
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
