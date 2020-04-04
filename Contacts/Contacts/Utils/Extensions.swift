//
//  Extensions.swift
//  Contacts
//
//  Created by Somenath on 23/03/20.
//  Copyright © 2020 Somenath. All rights reserved.
//

import UIKit
import Foundation


class Extensions {
    
    
}

let imageCache = NSCache<NSString, UIImage>()


extension UIImageView {
    func downloadIImage(from URL: URL) {
        contentMode = .scaleAspectFit
        
        
        if let cachedImage = imageCache.object(forKey: URL.absoluteString as NSString) {
//            DispatchQueue.main.async() {
                self.image = cachedImage
//            }
            return
         }
        
        URLSession.shared.dataTask(with: URL) {data, response, error in
            guard
            let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            
            imageCache.setObject(image, forKey: URL.absoluteString as NSString);
            DispatchQueue.main.async() {
                self.image = image
                
            }
        }.resume()
    }
    
    
}

extension UIView {
    
    func setGradientBackground(colorTop: UIColor, colorBottom: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = bounds

       layer.insertSublayer(gradientLayer, at: 0)
    }
}


extension UIViewController {
    
    func showNetworkUnavailableAlert() {
        let alertController = UIAlertController(title: "Oops!", message: "Not connected to internet", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(dismiss)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showEmptyFieldAlert() {
        let alertController = UIAlertController(title: "Oops!", message: "All fields must have some value", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(dismiss)
        self.present(alertController, animated: true, completion: nil)
    }
}
