//
//  BalancesView.swift
//  BillBuddy
//
//  Created by Michele Mariniello on 09/12/24.
//

import SwiftUI

struct BalancesView: View {
    var body: some View {
        List {
            Text("Alexa   owes   Mike   10.00€")
                .font(.headline)
            Text("Mike    owes   Pippo  500.00€")
                .font(.headline)
        }
        .navigationTitle("Balances")
    }
}

#Preview {
    BalancesView()
}
