//
//  Matching.swift
//  My App
//
//  Created by Арсений Простаков on 30.04.2024.
//

import Foundation
import UIKit

class Matching: UIViewController {
    var myImages = [UIImage(named: "Dog"), UIImage(named: "Cat"), UIImage(named: "Giraffe"), UIImage(named: "Tiger"), UIImage(named: "Zebra"), UIImage(named: "Lion")]
    
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet var imageView: UIImageView!
    // Array of animal names and corresponding image names
        let animalNames = ["Dog", "Cat", "Giraffe", "Tiger", "Zebra", "Lion"]
        var animalImages = [UIImage]()
        
    var correctAnimalIndex = 0
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .green
            title = "Try to match"
            loadAnimalImages()
            setupGame()
        }
        
        func loadAnimalImages() {
            for name in animalNames {
                if let image = UIImage(named: name) {
                    animalImages.append(image)
                } else {
                    fatalError("Failed to load image for animal: \(name)")
                }
            }
        }
        
        func setupGame() {
            guard animalImages.count == animalNames.count else {
                fatalError("Mismatch between animal names and images")
            }
            
            correctAnimalIndex = Int(arc4random_uniform(UInt32(animalNames.count)))
            
            guard correctAnimalIndex < animalImages.count else {
                fatalError("Correct animal index out of range")
            }
            
            imageView.image = animalImages[correctAnimalIndex]
            
            var randomIndices = Set<Int>()
            while randomIndices.count < 2 {
                let randomIndex = Int(arc4random_uniform(UInt32(animalNames.count)))
                if randomIndex != correctAnimalIndex {
                    randomIndices.insert(randomIndex)
                }
            }
            
            var buttonTitles = Array(randomIndices).map { animalNames[$0] }
            buttonTitles.append(animalNames[correctAnimalIndex])
            buttonTitles.shuffle()
            
            button1.setTitle(buttonTitles[0], for: .normal)
            button2.setTitle(buttonTitles[1], for: .normal)
            button3.setTitle(buttonTitles[2], for: .normal)
        }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        let selectedAnimalName = sender.title(for: .normal) ?? ""
        let correctAnimalName = animalNames[correctAnimalIndex]
        
        if selectedAnimalName == correctAnimalName {
            showAlert(message: "Correct!")
        } else {
            showAlert(message: "Wrong! The correct answer is \(correctAnimalName).")
        }
        
    }
    func showAlert(message: String) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                self.setupGame() // Set up a new game round after dismissing the alert
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
}
