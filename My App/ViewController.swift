//
//  ViewController.swift
//  My App
//
//  Created by Арсений Простаков on 03.04.2024.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func openFlashcards(_ sender: Any) {
        if let vc1 = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            
            navigationController?.pushViewController(vc1, animated: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

}

