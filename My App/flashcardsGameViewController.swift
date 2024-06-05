//
//  flashcardsGameViewController.swift
//  My App
//
//  Created by Арсений Простаков on 12.04.2024.
//

import Foundation
import SpriteKit
import UIKit

class flashcardsGameViewController: UIViewController {
    @IBAction func flashcardGameTapped(_ sender: Any) {
        
        if let vc3 = storyboard?.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController {
            
            navigationController?.pushViewController(vc3, animated: true)
        }
    }
    @IBAction func match(_ sender: Any) {
        if let vc4 = storyboard?.instantiateViewController(withIdentifier: "Matching") as? Matching {
            
            navigationController?.pushViewController(vc4, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
