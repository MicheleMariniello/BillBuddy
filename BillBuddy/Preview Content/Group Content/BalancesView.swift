//
//  BalancesView.swift
//  BillBuddy
//
//  Created by Michele Mariniello on 09/12/24.
//
import SwiftUI

struct BalancesView: View {
    @ObservedObject var groupStore: GroupsModel
    var group: Group

    var balances: [String: Double] {
        groupStore.calculateBalances(for: group)
    }

    var body: some View {
        List {
            ForEach(balances.keys.sorted(), id: \.self) { person in
                HStack {
                    Text(person)
                    Spacer()
                    Text(String(format: "%.2f€", balances[person] ?? 0.0))
                        .foregroundColor((balances[person] ?? 0.0) >= 0 ? .green : .red)
                }
            }
        }
        .navigationTitle("Balances")
    }
}



//#Preview {
//    BalancesView()
//}
