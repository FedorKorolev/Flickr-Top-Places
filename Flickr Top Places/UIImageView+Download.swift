//
//  UIImageView+Download.swift
//  CatsOnMap
//
//  Created by Nikolay Shubenkov on 01/04/2017.
//  Copyright © 2017 Nikolay Shubenkov. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func loadImage(link:String, highPriority:Bool = false){
        
        self.image = nil
        
        //создадим ссылку
        guard let url = URL(string: link) else {
            return
        }
        
        //попытаемся скачать данные по ссылке
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let imageData = data,
                let image = UIImage(data: imageData) else {
                    return
            }
            //не забудьте задать картинку для ImageView
            //!!!!!!!!В ОСНОВНОМ ПОТОКЕ!!!!!!!!!!!!!
            DispatchQueue.main.async {
                self.image = image
            }
        }
        task.priority = highPriority ? 1 : 0.5
        task.resume()
    }
    
}
