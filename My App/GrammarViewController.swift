//
//  GrammarViewController.swift
//  My App
//
//  Created by Арсений Простаков on 26.04.2024.
//

import Foundation
import UIKit

class GrammarViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        self.title = "Choose your level"
    }
    @IBAction func EasyButton(_ sender: Any) {
        if let vc1 = storyboard?.instantiateViewController(identifier: "Easy") as? EasyTableViewController {
            navigationController?.pushViewController(vc1, animated: true)
        }
    }
    @IBAction func MediumButton(_ sender: Any) {
        if let vc2 = storyboard?.instantiateViewController(identifier: "Medium") as? MediumTableViewController {
            navigationController?.pushViewController(vc2, animated: true)
        }
    }
    @IBAction func HardButton(_ sender: Any) {
        if let vc3 = storyboard?.instantiateViewController(identifier: "Hard") as? HardTableViewController {
            navigationController?.pushViewController(vc3, animated: true)
        }
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
