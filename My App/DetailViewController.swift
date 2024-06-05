//
//  DetailViewController.swift
//  My App
//
//  Created by Арсений Простаков on 04.04.2024.
//

import Foundation
import UIKit
import AVFoundation

extension UIImage {
    func toBase64String() -> String? {
        guard let imageData = self.pngData() else {
            return nil
        }
        return imageData.base64EncodedString()
    }
}
class DetailViewController: UICollectionViewController {
    var audioPlayer: AVAudioPlayer?
    var flashcards = [Flashcard]()
    var myImages = [UIImage(named: "Dog"), UIImage(named: "Cat"), UIImage(named: "Giraffe"), UIImage(named: "Tiger"), UIImage(named: "Zebra"), UIImage(named: "Lion")]
    
    var myImagesString = ["Dog", "Cat", "Giraffe", "Tiger", "Zebra", "Lion"]
    
    @objc func guessFlashcards() {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(guessFlashcards))
        for (idx, item) in myImages.enumerated() {
            if let image = item {
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
                
                let flashcard = Flashcard(name: myImagesString[idx], image: image)
                flashcards.append(flashcard)
                collectionView.reloadData()
            } else {
                print("Image not found")
            }
        }
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flashcards.count
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.delegate = self
        func loadSound() {
            if let soundURL = Bundle.main.url(forResource: flashcards[indexPath.item].name, withExtension: "m4a") {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                    audioPlayer?.prepareToPlay()
                } catch {
                    print("Error loading sound file: \(error.localizedDescription)")
                }
            } else {
                print("Sound file not found in the app bundle.")
            }
        }
        loadSound()
        audioPlayer?.play()
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail1") as? PicturesViewController {
            vc.selectedImage = flashcards[indexPath.item].name
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Flashcard", for: indexPath) as? FlashcardCell else {
            fatalError("Nope.")
        }
        
        let flashcard = flashcards[indexPath.item]
        cell.name.text = flashcard.name
        let path = flashcard.imageData
        
//        do {
//            let data = try Data(contentsOf: path)
        cell.imageView.image = UIImage(data: path!)
//            print(data)
//        } catch {
//            print("ups")
//        }
        
        
        
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
