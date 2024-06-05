//
//  GameScene.swift
//  Project 26
//
//  Created by Арсений Простаков on 25.03.2024.
//

import SpriteKit
import GameplayKit
import CoreMotion
import UIKit

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case letter = 4
    case vortex = 8
    case finish = 16
}
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let correctWord = "tiger"
    var collectedLetters: [Character] = []
    var motionManager: CMMotionManager!
    var lastTouchPosition: CGPoint?
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var isGameOver = false

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    func didBegin(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node!
        let nodeB = contact.bodyB.node!

        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
#if targetEnvironment(simulator)
    if let currentTouch = lastTouchPosition {
        let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
        physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
    }
#else
    if let accelerometerData = motionManager.accelerometerData {
        physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
    }
#endif
    }
    func animateLetterCollection(for letterNode: SKSpriteNode) {
        // Example: Scale down animation
        let scaleDown = SKAction.scale(to: 0.5, duration: 0.2)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.2)
        let sequence = SKAction.sequence([scaleDown, scaleUp])
        letterNode.run(sequence)
    }

    func animateWordFormation() {
        // Example: Zoom and fade in animation for the formed word
        let label = SKLabelNode(text: correctWord)
        label.fontSize = 40
        label.fontColor = .white
        label.position = CGPoint(x: frame.midX, y: frame.midY)
        label.alpha = 0
        addChild(label)
        
        let zoomIn = SKAction.scale(to: 2.0, duration: 1.0)
        let fadeIn = SKAction.fadeIn(withDuration: 1.0)
        let group = SKAction.group([zoomIn, fadeIn])
        label.run(group)
    }

    func updateCollectedWordDisplay() {
        // Display collected letters at the bottom right corner
        let collectedWord = String(collectedLetters)
        let collectedLabel = SKLabelNode(text: collectedWord)
        collectedLabel.fontSize = 20
        collectedLabel.fontColor = .white
        collectedLabel.horizontalAlignmentMode = .right
        collectedLabel.verticalAlignmentMode = .bottom
        collectedLabel.position = CGPoint(x: frame.maxX - 20, y: 20)
        
        // Remove previous collected word label
        enumerateChildNodes(withName: "collectedLabel") { node, _ in
            node.removeFromParent()
        }
        
        collectedLabel.name = "collectedLabel"
        addChild(collectedLabel)
    }

    func resetCollectedLetters() {
        collectedLetters.removeAll()
        enumerateChildNodes(withName: "collectedLabel") { node, _ in
            node.removeFromParent()
        }
    }

    func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1

            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])

            player.run(sequence) { [weak self] in
                self?.createPlayer()
                self?.isGameOver = false
            }
        } else if node.name == "finish" {
            // next level?
        }
        if let letterNode = node as? SKSpriteNode, let letter = letterNode.name?.first {
                // Check if the collided letter is part of the correct word
                if collectedLetters.count < correctWord.count {
                    let correctIndex = correctWord.index(correctWord.startIndex, offsetBy: collectedLetters.count)
                    if letter == correctWord[correctIndex] {
                        // Correct letter collected
                        collectedLetters.append(letter)
                        updateCollectedWordDisplay()
                        
                        if collectedLetters.count == correctWord.count {
                            // All letters collected, form the word
                            animateWordFormation()
                        } else {
                            // Play collect animation for the letter
                            animateLetterCollection(for: letterNode)
                        }
                    } else {
                        // Incorrect letter collected, deduct score and reset
                        score -= 1
                        resetCollectedLetters()
                    }
                }
            }
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "TigerHeadOpen")
        let texture = SKTexture(imageNamed: "TigerHeadOpen")
        player.position = CGPoint(x: 96, y: 672)
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(texture: texture, size: player.size.self)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.vortex.rawValue | CollisionTypes.letter.rawValue | CollisionTypes.finish.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        addChild(player)
    }
    func createBlockNode(at column: Int, row: Int) -> SKSpriteNode {
        let node = SKSpriteNode(imageNamed: "block")
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.zPosition = 1
        return node
    }

    func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: "tiger", withExtension: "txt") else {
            fatalError("Could not find tiger.txt in the app bundle.")
        }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load tiger.txt from the app bundle.")
        }
        let lines = levelString.components(separatedBy: "\n")
        let sWidth: CGFloat = 1366
        let sHeight: CGFloat = 1024
        
        let sceneSize = CGSize(width: sWidth, height: sHeight)  // Adjust as needed
        let scene = SKScene(size: sceneSize)
        let screenWidth = scene.size.width
        let screenHeight = scene.size.height
        let maxRows = 12
        for (row, line) in lines.dropLast().reversed().enumerated() {
            guard row < maxRows else { break }
            for (column, letter) in line.enumerated() {
                let positionX = (screenWidth / CGFloat(lines.count + 1)) * CGFloat(column + 1)
                let positionY = (screenHeight / CGFloat(lines.count + 1)) * CGFloat(row + 1)
                
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                print("Processing letter at position (\(column), \(row)): \(letter)")
                if letter == "\n" {
                    continue
                }
                if letter == "v" {
                    let node = SKSpriteNode(imageNamed: "vortex")
                    node.position = position
                    node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false
                    node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    addChild(node)
                }
                else if letter == "x" {
                    // load wall
                    let node = createBlockNode(at: Int(positionX), row: Int(positionY))
                    node.position = position
                    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                    node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
                    node.physicsBody?.isDynamic = false
                    addChild(node)
                } else {
                    // Create a sprite node for the letter at the calculated position
                    if let spriteNode = createSpriteNode(for: letter, at: position) {
                        spriteNode.physicsBody = SKPhysicsBody(circleOfRadius: spriteNode.size.height / 2)
                        spriteNode.physicsBody?.isDynamic = false
                        spriteNode.physicsBody?.categoryBitMask = CollisionTypes.letter.rawValue
                        spriteNode.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                        spriteNode.physicsBody?.collisionBitMask = 0
                        addChild(spriteNode)
                    } else {
                        fatalError("Failed to create sprite node for letter: \(letter)")
                    }
                }
                print("Processing letter at position (\(column), \(row)): \(letter)")
            }
        }
    }
    func createImage(for character: Character) -> UIImage? {
        let size = CGSize(width: 70, height: 70) // Adjust the size as needed
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard UIGraphicsGetCurrentContext() != nil else { return nil }

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
    func createSpriteNode(for character: Character, at position: CGPoint) -> SKSpriteNode? {
            // Create a UIImage for the character
            guard let image = createImage(for: character) else {
                return nil
            }
            // Create an SKTexture from the UIImage
            let texture = SKTexture(image: image)
            
            // Create an SKSpriteNode with the texture
            let spriteNode = SKSpriteNode(texture: texture)
            if UIDevice.current.userInterfaceIdiom == .pad && UIScreen.main.bounds.size.width == 1024 && UIScreen.main.bounds.size.height == 768 {
                let scaleFactor: CGFloat = 1.5 // Example scale factor for larger screen
                spriteNode.position = CGPoint(x: position.x * scaleFactor, y: position.y * scaleFactor)
            } else {
                spriteNode.position = position
            }
            // Optionally, set position, scale, etc. for the spriteNode
            // spriteNode.position = CGPoint(x: 100, y: 100)
            // spriteNode.setScale(0.5)
        spriteNode.physicsBody = SKPhysicsBody(circleOfRadius: spriteNode.size.height / 2)
        spriteNode.physicsBody?.isDynamic = false
        spriteNode.physicsBody?.categoryBitMask = CollisionTypes.letter.rawValue
        spriteNode.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        spriteNode.physicsBody?.collisionBitMask = 0
            return spriteNode
        }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        physicsWorld.gravity = .zero
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        loadLevel()
        createPlayer()
        
        // Loop through each English alphabet letter and create PNG images
        for letter in "abcdefghijklmnopqrstuwyz" {
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
    }
    
}
