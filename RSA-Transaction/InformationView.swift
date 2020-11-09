//
//  InformationView.swift
//  RSA-Transaction
//
//  Created by Santiago Yeomans on 08/11/20.
//  Copyright © 2020 Santiago Yeomans. All rights reserved.
//

import SwiftUI

struct InformationView: View {
    var body: some View {
        
        NavigationView{
            
            Form{
                Section(header: Text("RSA KEYS")) {
                    HStack {
                        Text("Private Key")
                        Spacer()
                        Text("Generar llave")
                    }
                    
                    HStack {
                        Text("Public Key")
                        Spacer()
                        Text("Generar llave")
                    }
                }
                
                Section(header: Text("Author")) {
                    Text("Santiago Yeomans 🔥")

                }
            }
                
            .navigationBarTitle("RSA Information")
        }
    }
}

struct InformationView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView()
    }
}