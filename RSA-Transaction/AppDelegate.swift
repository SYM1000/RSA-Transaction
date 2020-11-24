//
//  AppDelegate.swift
//  RSA-Transaction
//
//  Created by Santiago Yeomans on 08/11/20.
//  Copyright © 2020 Santiago Yeomans. All rights reserved.
//

import UIKit
import BigNumber

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        getKeys()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        
    }
    
    // Get all values needed to generate private and public keys
    func getKeys(){
        let stored = UserDefaults.standard
        
        let primes = randomPrimeArray(len: 100) // Get all the prime numbers from 0 to a valur(len)
        
        let p = primes[Int.random(in: 0..<primes.count)]
        let q = primes[Int.random(in: 0..<primes.count)]
        //p = 47
        //q = 61
        let n = p*q
        let phi = (p-1) * (q-1)
        let e = getE(phi: phi) //Used on public key
        let d = getD(e: e, phi: phi)
        
//        print("el valor p es ", p)
//        print("el valor q es ", q)
//        print("el valor n es ", n)
//        print("EL valor de phi es:", phi)
//        print( "El valor de e es ", e)
          //print("Valor de d:", d)

        stored.set(n, forKey: "n")
        stored.setValue(e, forKey: "e")
        stored.set(d, forKey: "d")
           
       }
    
    // Check is a number is prime
    func isPrime(num: Int) -> Bool {
        if num < 2 {
            return false
        }

        for i in 2..<num {
            if num % i == 0 {
                return false
            }
        }

        return true
    }
    
    // Get all the prime numbers from 0 to len
    func randomPrimeArray(len: Int) -> [Int] {
        var results = [Int]()
        var i = 0
        while i < len {
            let x = i
            if isPrime(num: x) {
                if !results.contains(x) {
                    results.append(x)
                }
            }
            i+=1
        }
        return results
    }
    
    // Get the Greatest Common Divison of two numbers
    func gcd(a:Int, b:Int) -> Int {
        if a == b {
            return a
        }
        else {
            if a > b {
                return gcd(a:a-b,b:b)
            }
            else {
                return gcd(a:a,b:b-a)
            }
        }
    }
    
    // Get the vale e
    func getE(phi: Int) -> Int {
        
        var e = 2
        
        while e < phi-1{
            let res = gcd(a: e, b: phi)
            
            if (res == 1) {
                //print("Comprobacion del valor de E :", gcd(a: e, b: phi))
                return e
            }
            e+=1
        }
        return -1
    }
    
    // Get the value D
    func getD (e:Int, phi: Int) -> Int {
        
        var d = 0
        var i = 0
        
        while (i<=10) {
            let x = 1+(i*phi)
            if(x%e == 0){ //d is for private key exponent
                d = x/e
                break
            }
            i+=1
        }
        return d
    }


}

