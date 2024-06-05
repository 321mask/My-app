//
//  PicturesViewController.swift
//  My App
//
//  Created by Арсений Простаков on 29.04.2024.
//

import Foundation
import UIKit

class PicturesViewController: UIViewController {
    @IBOutlet var Pictures: UIImageView!
    var selectedImage: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        title = selectedImage
        if let imageToLoad = selectedImage {
            Pictures.image = UIImage(named: imageToLoad)
        }
        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
}
