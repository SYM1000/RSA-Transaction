//
//  TransactionView.swift
//  RSA-Transaction
//
//  Created by Santiago Yeomans on 08/11/20.
//  Copyright © 2020 Santiago Yeomans. All rights reserved.
//

import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

struct TransactionView: View {
    var body: some View {
        
        NavigationView{
            VStack{
                Text("Your QR code")
                QRCodeView(url: "www.santiagoyeomans.com")
                
            }
            
            
            .navigationBarTitle("Tansaction")
        }
        
    }
}


struct QRCodeView : View {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    var url : String
    
    var body : some View{
        Image(uiImage: generateGRCodeImage(url))
            .interpolation(.none)
            .resizable()
            .frame(width: 120, height: 120, alignment: .center)
    }
    
    func generateGRCodeImage(_ url : String) -> UIImage{
        let data = Data(url.utf8)
        filter.setValue(data, forKey: "InputMessage")
        
        if let qrCodeImage = filter.outputImage{
            if let qrCodeCGImage = context.createCGImage(qrCodeImage, from: qrCodeImage.extent){
                return UIImage(cgImage: qrCodeCGImage)
            }
        }
        
        return UIImage(systemName: "xmark") ?? UIImage()
    }
    
}


struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView()
    }
}
