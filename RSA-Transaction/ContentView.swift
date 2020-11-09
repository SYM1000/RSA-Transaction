//
//  ContentView.swift
//  RSA-Transaction
//
//  Created by Santiago Yeomans on 08/11/20.
//  Copyright © 2020 Santiago Yeomans. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0
 
    var body: some View {
        TabView(selection: $selection){
            
            VStack{
                TransactionView()
            }
                .tabItem {
                    VStack {
                        Image(systemName: "paperplane").font(.system(size: 23))
                        Text("Transaction").font(.system(size: 23))
                    }
                }
                .tag(0)
            
            InformationView()
                .tabItem {
                    VStack {
                        Image(systemName: "info.circle").font(.system(size: 23))
                        Text("Information").font(.system(size: 23))
                    }
                }
                .tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
