//
//  GameScene.swift
//  project11
//
//  Created by Thomas Dobson on 1/11/21.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Variable Initializers
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel: SKLabelNode!
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    

    override func didMove(to view: SKView) {
        //Set background and add to Scene
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        
        //Set ScoreLabel and Add to Scene
        scoreLabel = SKLabelNode(fontNamed: "chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        //Set Edit Label and Add to Scene
        editLabel = SKLabelNode(fontNamed: "chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        //Add Physics Body to Edge of Screen
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        //Delegate to detect collisions
        physicsWorld.contactDelegate = self
        
        //Create the Slots and add them to the scene
        makeSlot(at: CGPoint(x: 128, y: 30), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 30), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 30), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 30), isGood: false)
        
        //Create Bouncers and add them to the scene
        makeBouncer(at: CGPoint(x: 0, y: 20))
        makeBouncer(at: CGPoint(x: 265, y: 20))
        makeBouncer(at: CGPoint(x: 512, y: 20))
        makeBouncer(at: CGPoint(x: 768, y: 20))
        makeBouncer(at: CGPoint(x: 1024, y: 20))

    }
    
    //What to do when a touch starts
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let object = nodes(at: location)
       
        //Check if edit mode is set
        //If touched object is the label - it toggles edit mode
        if object.contains(editLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                //if in edit mode and a box is touched - remove it
                let node : SKNode = self.atPoint(location)
                if node.name == "box" {
                    destroy(node: node)
                } else {
                    //if a box is not touched - create a random box at the touched location
                    let size = CGSize(width: Int.random(in: 16...128), height: 16)
                    let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                    box.zRotation = CGFloat.random(in: 0...3)
                    box.position = location
                    
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    box.name = "box"
                    addChild(box)
                }
                
            } else {
                //if edit mode is off - create a ball at the touched x location at top of screen.
                let ball = SKSpriteNode(imageNamed: "ballRed")
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
                ball.physicsBody?.restitution = 0.8
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                ball.position = CGPoint(x: location.x, y: 700)
                ball.name = "ball"
                addChild(ball)
            }

        }
    }
    
}

//Methods
extension GameScene {
    
    //Creates a Bouncer and adds to the scene
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    //Creates a lot and adds to the scene
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        //Add physics body to scene
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        //Rotates the slot effects
        let spin = SKAction.rotate(byAngle: CGFloat.pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    //Removes Balls on detected collison
    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(node: ball)
            particles(node: ball)
            score += 1
        } else if object.name == "bad" {
            destroy(node: ball)
            particles(node: ball)
            score -= 1
        }
    }
    
    //Particles are fired on ball collision with slot
    func particles (node: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = node.position
            addChild(fireParticles)
        }
    }
    
    //destry a node
    func destroy(node: SKNode) {
        node.removeFromParent()
    }
    
    //Detects collision between two objects
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        //detects object colliding with ball, or ball with objectm but ball to ball
        if nodeA.name == "ball" {
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
    }
}


