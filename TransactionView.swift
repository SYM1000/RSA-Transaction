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
    @State var message: String = ""
    @State var cipherText: String = ""
    @State var showingQRCode = false
    @State var scanningQRCode = false
    
    var body: some View {
        
        NavigationView{
            
            VStack() {
                Text("Enter your text here")
                    .bold()
                    .font(.title)
                
                TextField("Enter text here...", text: $message)
                    .padding()
                    .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
                    .cornerRadius(10)
                
                Button(action: {
                    if(self.message != ""){
                        let a = self.convertMessageToNumbers(message: self.message)
                        //self.cypherNumber(text: a)
                        self.cipherText = self.cypherNumber(text: a)
                        
                        self.showingQRCode.toggle()
                        
                        print("Texto original: \(self.message)")
                        print("Texto cifrado: \(self.cipherText)")
                    }
                    
                    
                }) {
                    HStack {
                        Text("Cypher Message")
                            .fontWeight(.semibold)
                            .font(.headline)
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(40)
                    
                }.sheet(isPresented: $showingQRCode) {
                    ShowCodeView(cipherText: self.$cipherText)
                }
                
                
                Button(action: {
                    print("Desifraando")
                    self.scanningQRCode.toggle()
                    
                    
                }){
                    HStack {
                        Text("Decipher a Code")
                            .fontWeight(.semibold)
                            .font(.headline)
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(40)
                }.padding(.top)
                .sheet(isPresented: $scanningQRCode) {
                    ScanCodeView()
                }
                
                    
                
            }.padding()
            
//            VStack{
//                Text("Your QR code")
//                QRCodeView(url: "www.santiagoyeomans.com")
//
//            }
            .navigationBarTitle("Tansaction")
        }
        
    }
    
    // Convert a plain text into numbers
    func convertMessageToNumbers(message: String) -> String{
        //Create dictionary with value of letters
        let text = message.lowercased()
        
        let dictionary = [
            "a" : "1",
            "b" : "2",
            "c" : "3",
            "d" : "4",
            "e" : "5",
            "f" : "6",
            "g" : "7",
            "h" : "8",
            "i" : "9",
            "j" : "10",
            "k" : "11",
            "l" : "12",
            "m" : "13",
            "n" : "14",
            "o" : "15",
            "p" : "16",
            "q" : "17",
            "r" : "18",
            "s" : "19",
            "t" : "20",
            "u" : "21",
            "v" : "22",
            "w" : "23",
            "x" : "24",
            "y" : "25",
            "z" : "26",
        ]
        var numbers = ""
        
        for letter in text {
            if (letter == " "){
                numbers += " "
                continue
            }
            numbers += dictionary[String(letter)]!
        }
    
        return numbers
    }
    
    func cypherNumber(text: String) -> String {
        let words = text.components(separatedBy: " ")
        var numbers = [Int]()
        let e = UserDefaults.standard.integer(forKey: "e")
        let n = UserDefaults.standard.integer(forKey: "n")
        
        //let p = powerMod(base: 715, exponent: 7, modulus: 2867)
        //print("valor es ", p)
        
        
        for word in words{
            //var value = Int(pow( Double(Int(word)!) , Double(e))) % n
            //print(word)
            let value = powerMod(base: Int(word)!, exponent: e, modulus: n)
            numbers.append(value)
        }
        
        
        //print("el texto cifrado es :", convertToString(numbes: numbers))
        
       return convertToString(numbes: numbers)
        
    }
    
    // Exponenciacion rapida
    func powerMod(base: Int, exponent: Int, modulus: Int) -> Int {
        guard base > 0 && exponent >= 0 && modulus > 0
            else { return -1 }

        var base = base
        var exponent = exponent
        var result = 1

        while exponent > 0 {
            if exponent % 2 == 1 {
                result = (result * base) % modulus
            }
            base = (base * base) % modulus
            exponent = exponent / 2
        }

        return result
    }
    
    // Convert array of numbers to string: separated by ","
    func convertToString(numbes: [Int]) -> String{
        var texto = ""
        
        for x in numbes{
            texto += String(x)
            if(x != numbes[numbes.count-1]){
                texto += ","
            }
        }
        
        return texto
    }
    
}


// View used create a QRCode
struct QRCodeView : View {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    var url : String
    
    var body : some View{
        Image(uiImage: generateGRCodeImage(url))
            .interpolation(.none)
            .resizable()
            .frame(width: 200, height: 200, alignment: .center)
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

// View used to present qrcode
struct ShowCodeView: View {
    @Binding var cipherText: String
    var body: some View {
        NavigationView{
            VStack{
                Spacer()
                Text("Use this code to share your encrypted message")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                QRCodeView(url: cipherText)
                Spacer()
            }
            .navigationBarTitle("QR Code")
        }
    }
}

// View used to scanns a qrcode
struct ScanCodeView: View {
    @State var isPresentingScanner = false
    @State var scannedCode: String?
    
    var body: some View {
        CodeScannerView(codeTypes: [.qr], simulatedData: "Santiago Yeomans") { result in
            switch result {
            case .success(let code):
                print("Found code: \(code)")
                self.scannedCode = code
                self.isPresentingScanner.toggle()
                //desencriptar el mensaje y mostarlo al usuario
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        .sheet(isPresented: $isPresentingScanner) {
            self.scannerSheet
        }
    }
    
    var scannerSheet : some View {
        
//        CodeScannerView(
//            codeTypes: [.qr],
//            completion: { result in
//                if case let .success(code) = result {
//                    self.scannedCode = code
//                    self.isPresentingScanner = false
//                }
//            }
//        )
        NavigationView{
            Text("El codigo es \(self.scannedCode!)")
                
            .navigationBarTitle("Code Scanned")
        }
        
        
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView()
    }
}
