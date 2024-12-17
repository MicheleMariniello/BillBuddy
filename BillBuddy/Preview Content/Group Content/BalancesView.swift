//
//  BalancesView.swift
//  BillBuddy
//
//  Created by Michele Mariniello on 09/12/24.
//
import SwiftUI

struct BalancesView: View {
    @ObservedObject var groupStore: GroupsModel
    var groupName: String

    // Calcola i bilanci di ogni partecipante nel gruppo
    private func calculateBalances() -> [String: Double] {
        var balances: [String: Double] = [:]
        
        // Trova il gruppo corrispondente
        if let group = groupStore.groups.first(where: { $0.name == groupName }) {
            for expense in group.expenses {
                // Aggiunge il credito al pagatore
                balances[expense.payer, default: 0.0] += expense.amount

                // Sottrae la quota a ciascun partecipante
                for (participant, contribution) in expense.contributions {
                    balances[participant, default: 0.0] -= contribution
                }
            }
        }
        return balances
    }
    
    var body: some View {
        let balances = calculateBalances()
        
        VStack {
            Text("Balances")
                .font(.title)
                .padding()

            List {
                ForEach(balances.sorted(by: { $0.key < $1.key }), id: \.key) { name, balance in
                    HStack {
                        Text(name)
                            .fontWeight(.bold)
                        Spacer()
                        Text(String(format: "%.2f €", balance))
                            .foregroundColor(balance >= 0 ? .green : .red)
                    }
                }
            }
        }
    }
}


//#Preview {
//    BalancesView()
//}
