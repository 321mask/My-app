//
//  Flashcard.swift
//  My App
//
//  Created by Арсений Простаков on 09.04.2024.
//

import Foundation
import UIKit

class Flashcard: NSObject, Codable {
    var name: String
    var imageData: Data?

        init(name: String, image: UIImage) {
            self.name = name
            self.imageData = image.jpegData(compressionQuality: 1.0)
        }

        func getImage() -> UIImage? {
            if let imageData = imageData {
                return UIImage(data: imageData)
            }
            return nil
        }
    }
