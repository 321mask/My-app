//
//  Flaashcard.swift
//  My App
//
//  Created by Арсений Простаков on 09.04.2024.
//

import Foundation
import UIKit

class Flashcard: NSObject, Codable {
    var name: String
    var image: String
   

    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
