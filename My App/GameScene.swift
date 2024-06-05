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
    
    var correctWord = "tiger"
    var collectedLetters: [Character] = []
    var collectedLetterNodes: Set<SKNode> = []
    var motionManager: CMMotionManager!
    var lastTouchPosition: CGPoint?
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var isGameOver = false
    var playerIsCollidingWithVortex = false
    var levels = ["tiger", "cat"]
    var previousLevel: String?

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
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
        let scaleDown = SKAction.scale(to: 0.5, duration: 0.2)
        let moveToCorner = SKAction.move(to: CGPoint(x: frame.maxX - 200 + CGFloat(collectedLetters.count * 30), y: 20), duration: 0.5)
        let group = SKAction.group([scaleDown, moveToCorner])
        
        letterNode.run(group)
    }

    func animateWordFormation() {
        // Create a label for each collected letter and position them in sequence
        
        let word = correctWord
        let letterSpacing: CGFloat = 30.0
        let startX = frame.midX - CGFloat(word.count) * letterSpacing / 2
        let startY = frame.midY

        var letterNodes: [SKLabelNode] = []

        for (index, letter) in word.enumerated() {
            let label = SKLabelNode(text: String(letter))
            label.fontSize = 60
            label.fontColor = .red
            label.position = CGPoint(x: startX + CGFloat(index) * letterSpacing, y: startY)
            label.alpha = 0
            label.zPosition = 2
            addChild(label)
            letterNodes.append(label)
        }

        // Define the animations
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let scaleUp = SKAction.scale(to: 2.0, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let changeColor = SKAction.colorize(with: .yellow, colorBlendFactor: 1.0, duration: 0.5)
        let resetColor = SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.5)

        let animationSequence = SKAction.sequence([fadeIn, scaleUp, changeColor, scaleDown, resetColor])

        // Run the animation sequence on each letter node with a delay between each
        for (index, letterNode) in letterNodes.enumerated() {
            let delay = SKAction.wait(forDuration: TimeInterval(index) * 0.3)
            let delayedSequence = SKAction.sequence([delay, animationSequence])
            letterNode.run(delayedSequence)
        }
        // Optional: Add a final animation for the entire word
        let wordLabel = SKLabelNode(text: word)
        wordLabel.fontSize = 60
        wordLabel.fontColor = .green
        wordLabel.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        wordLabel.alpha = 0
//        addChild(wordLabel)

        let finalZoomIn = SKAction.scale(to: 2.0, duration: 1.0)
        let finalFadeIn = SKAction.fadeIn(withDuration: 1.0)
        let finalGroup = SKAction.group([finalZoomIn, finalFadeIn])
        let finalSequence = SKAction.sequence([SKAction.wait(forDuration: TimeInterval(word.count) * 0.3), finalGroup])

        wordLabel.run(finalSequence)
    }
    func updateCollectedWordDisplay() {
        // Display collected letters at the bottom right corner
        let collectedWord = String(collectedLetters)
        let collectedLabel = SKLabelNode(text: collectedWord)
        
        collectedLabel.fontSize = 40
        collectedLabel.fontColor = .red
        collectedLabel.horizontalAlignmentMode = .right
        collectedLabel.verticalAlignmentMode = .bottom
        collectedLabel.position = CGPoint(x: frame.maxX - 20, y: 20)
        
        // Remove previous collected word label
        enumerateChildNodes(withName: "collectedLabel") { node, _ in
            node.removeFromParent()
        }
        
        collectedLabel.name = "collectedLabel"
//        addChild(collectedLabel)
    }

    func resetCollectedLetters() {
        collectedLetters.removeAll()
        collectedLetterNodes.forEach { $0.removeFromParent() }
        collectedLetterNodes.removeAll()
        enumerateChildNodes(withName: "collectedLabel") { node, _ in
            node.removeFromParent()
        }
    }
    func loadRandomLevel() {
        var availableLevels = levels
        if let previous = previousLevel {
            availableLevels.removeAll { $0 == previous }
        }
        guard let selectedLevel = availableLevels.randomElement() else {
            fatalError("No levels available to load.")
        }
        loadLevel(levelName: selectedLevel)
        previousLevel = selectedLevel
    }

    func playerCollided(with node: SKNode) {
        guard let nodeName = node.name, nodeName != "\n", nodeName != " " else { return }
        if node.name == "vortex" && !isGameOver {
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1
            // Delay execution of the collision handling code
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                    
                let move = SKAction.move(to: node.position, duration: 0.25)
                let scale = SKAction.scale(to: 0.0001, duration: 0.25)
                let remove = SKAction.removeFromParent()
                let sequence = SKAction.sequence([move, scale, remove])

                self.player.run(sequence) { [weak self] in
                self?.createPlayer()
                self?.isGameOver = false
                }
            }
        } else if node.name == "n" {
            // next level?
            loadRandomLevel()
        } else if let letterNode = node as? SKSpriteNode, let letter = letterNode.name?.first {
//            print("Collided with letter node: \(letter)")
                // Check if the collided letter is part of the correct word
            if !collectedLetterNodes.contains(letterNode) {
                collectedLetterNodes.insert(letterNode)
                if collectedLetters.count < correctWord.count {
                    let correctIndex = correctWord.index(correctWord.startIndex, offsetBy: collectedLetters.count)
                    let expectedLetter = correctWord[correctIndex]
                    print("Expected letter: \(expectedLetter)")
                    if letter == expectedLetter {
                        // Correct letter collected
                        
                        collectedLetters.append(letter)
                        animateLetterCollection(for: letterNode)
                        updateCollectedWordDisplay()
                        
                        if collectedLetters.count == correctWord.count {
                            // All letters collected, form the word
                            animateWordFormation()
                            score += 1
                        }
                    } else {
                        print("Collected wrong letter: \(letter)")
                        var isOrderWrong = false
                        for i in 0..<collectedLetters.count {
                            let correctLetter = correctWord[correctWord.index(correctWord.startIndex, offsetBy: i)]
                            if collectedLetters[i] != correctLetter {
                                isOrderWrong = true
                                break
                            }
                        }
                        if isOrderWrong {
                            print("Order is wrong, resetting collected letters")
                            // All letters collected so far are in the wrong order
                            score -= 1
                            resetCollectedLetters()
                        } else {
                            print("Collected letter but in wrong order: \(letter)")
                            // Play collect animation for the letter
                            animateLetterCollection(for: letterNode)
                            score -= 1
                        }
                    }
                }
                print(letter)
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
    func setupUI() {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
    }

    func loadLevel(levelName: String) {
        resetCollectedLetters()
        guard let levelURL = Bundle.main.url(forResource: levelName, withExtension: "txt") else {
            fatalError("Could not find \(levelName).txt in the app bundle.")
        }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load \(levelName).txt from the app bundle.")
        }
        removeAllChildren()
        collectedLetters.removeAll()
        collectedLetterNodes.removeAll()
        createPlayer()
        setupUI()
        
        switch levelName {
        case "tiger":
            correctWord = "tiger"
        case "cat":
            correctWord = "cat"
        default:
            fatalError("Unknown level name: \(levelName)")
        }
        let lines = levelString.components(separatedBy: "\n")
        let sWidth: CGFloat = 1024
        let sHeight: CGFloat = 768
        
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
                    node.name = "vortex"
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
                    let node = SKSpriteNode(imageNamed: "block")
                    node.position = position
                    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                    node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
                    node.physicsBody?.isDynamic = false
                    addChild(node)
                }  else if letter == " " {
                    continue
                } else {
                    // Create a sprite node for the letter at the calculated position
                    createLetterNode(for: letter, at: position)
                }
                print("Processing letter at position (\(column), \(row)): \(letter)")
            }
        }
    }
    func createLetterNode(for letter: Character, at position: CGPoint) {
        if let spriteNode = createSpriteNode(for: letter, at: position) {
            spriteNode.name = String(letter)
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
            spriteNode.physicsBody = SKPhysicsBody(circleOfRadius: spriteNode.size.height / 2)
            spriteNode.physicsBody?.isDynamic = false
            spriteNode.physicsBody?.categoryBitMask = CollisionTypes.letter.rawValue
            spriteNode.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
            spriteNode.physicsBody?.collisionBitMask = 0
            
            return spriteNode
        }
    
    override func didMove(to view: SKView) {
        loadRandomLevel()
        physicsWorld.contactDelegate = self
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        physicsWorld.gravity = .zero
    }
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }
}
