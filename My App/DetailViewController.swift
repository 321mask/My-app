//
//  DetailViewController.swift
//  My App
//
//  Created by Арсений Простаков on 04.04.2024.
//

import Foundation
import UIKit

extension UIImage {
    func toBase64String() -> String? {
        guard let imageData = self.pngData() else {
            return nil
        }
        return imageData.base64EncodedString()
    }
}
class DetailViewController: UICollectionViewController {
    var flashcards = [Flashcard]()
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = UIImage(named: "hdr-japan") {
            let imageName = UUID().uuidString
            let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
            if let jpegData = image.jpegData(compressionQuality: 0.1) {
                do {
                    try jpegData.write(to: imagePath)
                    // Check if the file exists at 'imagePath'
                    let fileManager = FileManager.default
                    if fileManager.fileExists(atPath: imagePath.path) {
                        print("Image data has been successfully written to \(imagePath)")
                    } else {
                        print("Failed to write image data to \(imagePath)")
                    }
                } catch {
                    print("Error writing image data to file: \(error)")
                }
            }
            
            let flashcard = Flashcard(name: "Japan", image: imagePath.absoluteString)
            flashcards.append(flashcard)
            collectionView.reloadData()
        } else {
            print("Image not found")
        }
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flashcards.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Flashcard", for: indexPath) as? FlashcardCell else {
            fatalError("Nope.")
        }
        
        let flashcard = flashcards[indexPath.item]
        cell.name.text = flashcard.name
        let path = URL(string: flashcard.image)
        print(path!.absoluteURL)
        print(path!.absoluteString)
        do {
            let data = try Data(contentsOf: path!.absoluteURL)
            cell.imageView.image = UIImage(data: data)
            print(data)
        } catch {
            print("ups")
        }
        
        
        
//        if let image = UIImage(named: "hdr-japan") {
//            if let base64String = image.toBase64String() {
//                cell.imageView.image = UIImage(named: base64String)
//            } else {
//                print("Failed to convert image to base64 string")
//            }
//        } else {
//            print("Image not found")
//        }
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        return cell
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
