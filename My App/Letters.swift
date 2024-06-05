//
//  Letters.swift
//  My App
//
//  Created by Арсений Простаков on 16.04.2024.
//

import Foundation
import UIKit

// Function to create a PNG image for a given character
func createImage(for character: Character) -> UIImage? {
    let size = CGSize(width: 100, height: 100) // Adjust the size as needed
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }

    // Draw the character in the center of the image
    let attributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 60), // Adjust the font size as needed
        .foregroundColor: UIColor.black
    ]
    let string = String(character)
    let textSize = string.size(withAttributes: attributes)
    let textRect = CGRect(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2, width: textSize.width, height: textSize.height)
    string.draw(in: textRect, withAttributes: attributes)

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}

// Loop through each English alphabet letter and create PNG images
for letter in "abcdefghijklmnopqrstuvwxyz" {
    if let image = createImage(for: letter) {
        // Convert the image to PNG data
        if let pngData = image.pngData() {
            // Save the PNG data to a file
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent("\(letter).png")
            do {
                try pngData.write(to: fileURL)
                print("Image for letter \(letter) saved at: \(fileURL)")
            } catch {
                print("Error saving image for letter \(letter): \(error)")
            }
        }
    }
}
