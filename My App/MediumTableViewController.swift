//
//  MediumTableViewController.swift
//  My App
//
//  Created by Арсений Простаков on 28.04.2024.
//

import Foundation
import UIKit

class MediumTableViewController: UITableViewController {
    var mediumGrammar = [String]()
    func loadStringsWithPrefixAndSuffixes(prefix: String, suffixes: [String]) {
        var strings: Set<String> = []
            
        // Get all image filenames in the main bundle for the specified extension
        let imagePaths = Bundle.main.paths(forResourcesOfType: "jpeg", inDirectory: nil)
        
        // Process each image filename
        for imagePath in imagePaths {
            let imageName = (imagePath as NSString).lastPathComponent
            
            // Check if the image filename starts with the specified prefix
            if imageName.hasPrefix(prefix) {
                // Construct strings based on the filename and suffixes
                for suffix in suffixes {
                    let string = "\(prefix)\(suffix)"
                    strings.insert(string)
                }
            }
        }
            
            // Assign the loaded strings to the easyGrammar array
            mediumGrammar = Array(strings)
        }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Grammar"
        let prefix = "Tiger"
        let suffixes = [" at", " is"]
        view.backgroundColor = .green
        loadStringsWithPrefixAndSuffixes(prefix: prefix, suffixes: suffixes)
//        let defaults = UserDefaults.standard
//        if let savedData = defaults.object(forKey: "pictures") as? Data {
//            let jsonDecoder = JSONDecoder()
//            do {
//                mediumGrammar = try jsonDecoder.decode([String].self, from: savedData)
//            } catch {
//                print("Failed to load people")
//            }
//        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediumGrammar.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MediumCell", for: indexPath)
            cell.textLabel?.text = mediumGrammar[indexPath.row]
        cell.backgroundColor = .lightGray
            return cell
        }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail1") as? PicturesViewController {
            vc.selectedImage = mediumGrammar[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
        self.save()
    }
    func save() {
        let json = JSONEncoder()
        if let savedData = try? json.encode(mediumGrammar) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "pictures")
        } else {
            print("Failed to save")
        }
    }
}
