//
//  NetworkManager.swift
//  Contacts
//
//  Created by Somenath on 21/03/20.
//  Copyright © 2020 Somenath. All rights reserved.
//

import Foundation
import SystemConfiguration


class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {
    }
    
    
    // MARK:- GET Calls
    func getAllContacts(completion: @escaping (Any?) -> Void) {
        
        guard let url = URL(string: contactsURL) else { return }
        
        
        self.getAPICall(url: url) { (jsonData) in
            completion(jsonData)
        }
    }
    
    
    func getContactDetails(urlString: String, completion: @escaping (Any?) -> Void) {
        
        guard let url = URL(string: urlString) else { return }
        
        self.getAPICall(url: url) { (jsonData) in
            completion(jsonData)
        }
        
    }
    
    private func getAPICall(url: URL, completion: @escaping (Any?) -> Void) {
            
        let task = URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                 print(error)
                 return
             }
             guard response != nil else {
                 return
             }
             guard let data = data else {
                 return
             }
            
            do {
                
                let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])
                completion(jsonData)
//                completion(data)
            }
        }
        task.resume()
    }
    
    
    // MARK: - PUT Calls
    func editContactDetails(urlStr: String, httpMethod: String, body: [String: Any], completion: @escaping (Any?) -> Void) {
        guard let url = URL(string: urlStr) else { return }
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.allHTTPHeaderFields = ["Content-Type":"application/json", "description": ""]
        
        do {
            let bodyData = try? JSONSerialization.data(withJSONObject: body)
            request.httpBody = bodyData
        }
        
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            guard response != nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])
                completion(jsonData)
                //print(jsonData)
            }
            
        }
        task.resume()
        
    }
    
    
    // MARK: - DELETE Calls
    func removeContact(urlStr: String) {
        guard let url = URL(string: urlStr) else { return }
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            if let responseH = response as? HTTPURLResponse {
                print(responseH.statusCode)
            }
        }
        task.resume()
    }
    
}


extension NetworkManager {
    
    func isConnectedToInternet() -> Bool {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, "www.google.com") else { return false}
        var flags = SCNetworkReachabilityFlags()
        
        SCNetworkReachabilityGetFlags(reachability, &flags)
        if !isNetworkReachable(with: flags) {
           
            return false
        }
        
        #if os(iOS)
        // It's available just for iOS because it's checking if the device is using mobile data
        if flags.contains(.isWWAN) {
            return true
        }
        #endif
        
       return true
    }
    
    private func isNetworkReachable(with flags: SCNetworkReachabilityFlags) -> Bool {
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        return isReachable && (!needsConnection || canConnectWithoutUserInteraction)
    }
}
