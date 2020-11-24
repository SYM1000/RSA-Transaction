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
import BigNumber

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
                    self.scanningQRCode.toggle()
                    
                    
                }){
                    HStack {
                        Text("Scan a Code")
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
            
            .navigationBarTitle("Tansaction")
        }
        
    }
    
    // Convert a plain text into ASCII
    func convertMessageToNumbers(message: String) -> String{
        //Create dictionary with value of letters
        let text = message
        var numbers = ""
        
        let palabras = text.components(separatedBy: " ")
        let last = palabras.count-1
        
        for palabra in palabras{
            let palabraEnAscii = palabra.asciiValues
            let last2 = palabraEnAscii.count-1
            for x in palabraEnAscii{
                numbers += String(x)
                if(x == palabraEnAscii[last2]){
                    continue
                }
                numbers += "."
            }
            
            if(palabra == palabras[last]){
                continue
            }
            numbers += " "
        }
        
        
        //print("El numero final en ascii es", numbers )
        return numbers
    }
    
    func cypherNumber(text: String) -> String {
        let words = text.components(separatedBy: " ")
        var numbers = [BInt]()
        let e = UserDefaults.standard.integer(forKey: "e")
        let n = UserDefaults.standard.integer(forKey: "n")
        _ = UserDefaults.standard.integer(forKey: "d")
        
        for word in words{
            let valores = word.components(separatedBy: ".")
            for valor in valores {
                let value = TransactionView.powerMod(base: BInt(valor)!, exponent: BInt(e), modulus: BInt(n))
                numbers.append(value)
            }
            numbers.append(-1)
            
            //print("Values es", value)
        }
        
        //print("el texto cifrado es :", numbers)
        //print("el texto cifrado es :", convertToString(numbes: numbers))
        
       return convertToString(numbes: numbers)
        
    }
    
    // Exponenciacion rapida
   static func powerMod(base: BInt, exponent: BInt, modulus: BInt) -> BInt {
        guard base > 0 && exponent >= 0 && modulus > 0
            else { return -1 }

        var base = base
        var exponent = exponent
        var result = BInt(1)
    
        var z = 6.5
        z.round(.down)

        while exponent > 0 {
            if exponent % 2 == 1 {
                result = BInt((result * base) % modulus)
            }
            base = (base * base) % modulus
            exponent = exponent / 2
            let y = Double(exponent)
            exponent = BInt(y)
        
        }

        return BInt(result)
    }
    
    // Convert array of numbers to string: separated by ","
    func convertToString(numbes: [BInt]) -> String{
        var texto = ""
        
        let n = UserDefaults.standard.integer(forKey: "n")
        let d = UserDefaults.standard.integer(forKey: "d")

        texto += String(BInt(d))
        texto += ","
        texto += String(BInt(n))
        texto += ","
        
        for x in numbes{
            if(x == BInt(-1)){
                texto = String(texto.dropLast())
                texto += ","
                continue
            }
            texto += String(x)
            if(x != numbes[numbes.count-1]){
                texto += "."
            }
        }
        texto = String(texto.dropLast())
        //print("El texto convertido es", texto)
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
    @State var mensaje = "gg"
    
    var body: some View {
        CodeScannerView(codeTypes: [.qr], simulatedData: "Santiago Yeomans") { result in
            switch result {
            case .success(let code):
                print("Found code: \(code)")
                self.scannedCode = code
                self.mensaje = desencriptar(code: code)
                UserDefaults.standard.setValue(self.mensaje, forKey: "Message")
                
                self.isPresentingScanner.toggle()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        .sheet(isPresented: $isPresentingScanner) {
            self.scannerSheet
        }
    }
    
    var scannerSheet : some View {
        NavigationView(){
            
            Text("Tu mensaje es: \(UserDefaults.standard.string(forKey: "Message") ?? "Error")").font(.headline).padding()

            .navigationBarTitle("Encrypted Message")
        }
        
        
    }
    
    //Desencripar la informacion del codido QR
    func desencriptar(code : String) -> String{
        var message = ""
        var palabras = code.components(separatedBy: ",")
        
        let d = palabras[0]
        let n = palabras[1]
        
        palabras.remove(at: 0)
        palabras.remove(at: 0)
        
        for palabra in palabras {
            let letras = palabra.components(separatedBy: ".")
            for letra in letras{
                let value = TransactionView.powerMod(base: BInt(letra)!, exponent: BInt(d)!, modulus: BInt(n)!)
                let s = String(UnicodeScalar(UInt8(value)))
                message += s
            }
            message += " "
        }

        return message
        
    }
    
    

}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView()
    }
}

extension StringProtocol {
    var asciiValues: [UInt8] { compactMap(\.asciiValue) }
}
