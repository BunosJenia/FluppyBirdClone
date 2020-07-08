//
//  GameScene.swift
//  CloneFlappyBird
//
//  Created by Yauheni Bunas on 7/8/20.
//  Copyright © 2020 Yauheni Bunas. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ground = SKSpriteNode()
    var bird = SKSpriteNode()
    var wallPair = SKNode()
    
    var restartButton = SKSpriteNode()
    let scoreLabel = SKLabelNode()
    
    var moveAndRemove = SKAction()
    
    var isGameStarted: Bool = false
    var isAlive: Bool = true
    
    var score = 0
    
    override func didMove(to view: SKView) {
        createScene()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameStarted == false {
            isGameStarted = true
            
            bird.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.run {
                self.createWalls()
            }
            
            let delay = SKAction.wait(forDuration: 2.5)
            let sequence = SKAction.sequence([spawn, delay])
            
            self.run(SKAction.repeatForever(sequence))
            
            let distance = CGFloat(self.frame.width * 1.8 + wallPair.frame.width)
            let movePipes = SKAction.moveBy(x: -distance, y: 0.0, duration: 0.008 * Double(distance))
            let removePipes = SKAction.removeFromParent()
            
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
        } else {
            if isAlive == false {
                for touch in touches {
                    let location = touch.location(in: self)
                    
                    if restartButton.contains(location) {
                        restartScene()
                    }
                }
                
                return
            }
        }
        
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200))
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameStarted == true {
            enumerateChildNodes(withName: "background", using: ({
                (node, error) in
                var bg = node as! SKSpriteNode
                bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                
                if bg.position.x <= -bg.size.width {
                    bg.position = CGPoint(x: bg.position.x + bg.size.width * 2, y: bg.position.y)
                }
            }))
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCategory.score && secondBody.categoryBitMask == PhysicsCategory.bird {
            score += 1
            
            updateScoreLabel()
            
            firstBody.node?.removeFromParent()
        }
        else if secondBody.categoryBitMask == PhysicsCategory.score && firstBody.categoryBitMask == PhysicsCategory.bird {
            score += 1
                       
            updateScoreLabel()

            secondBody.node?.removeFromParent()
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.bird && secondBody.categoryBitMask == PhysicsCategory.wall || firstBody.categoryBitMask == PhysicsCategory.wall && secondBody.categoryBitMask == PhysicsCategory.bird {
//            enumerateChildNodes(withName: "wallPair", using: ({
//                (node, error) in
//                node.speed = 0
//                self.removeAllActions()
//            }))
            if isAlive == true {
                isAlive = false
                createRestartButton()
            }
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.bird && secondBody.categoryBitMask == PhysicsCategory.ground || firstBody.categoryBitMask == PhysicsCategory.ground && secondBody.categoryBitMask == PhysicsCategory.bird {
            if isAlive == true {
                isAlive = false
                createRestartButton()
            }
        }
    }
    
    func restartScene() {
        
        self.removeAllChildren()
        self.removeAllActions()
        
        isAlive = true
        isGameStarted = false
        score = 0
        
        createScene()
    }
    
    func createScene() {
        self.physicsWorld.contactDelegate = self
        
        spawnScoreLabel()
        createBackground()
        
        createGround()
        createBird()
    }
}

extension GameScene {
    func createRestartButton() {
        restartButton = SKSpriteNode(color: UIColor.blue, size: CGSize(width: 280, height: 140))
        restartButton.position = CGPoint(x: 0, y: 0)
        restartButton.setScale(0)
        restartButton.zPosition = 6
        
        let restartButtonBorder = SKSpriteNode(color: UIColor.white, size: CGSize(width: 260, height: 120))
        let restartLabel = SKLabelNode(text: "Restart")
        
        restartLabel.zPosition = 8
        restartButtonBorder.zPosition = 7
        restartLabel.position = CGPoint(x: 0, y: -18)
        restartLabel.fontName = "04b_19"
        restartLabel.fontSize = 48
        restartLabel.fontColor = UIColor.black
        
        restartButton.addChild(restartButtonBorder)
        restartButton.addChild(restartLabel)
        self.addChild(restartButton)
        
        restartButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func spawnScoreLabel() {
        scoreLabel.position = CGPoint(x: 0, y: self.frame.height / 2.8)
        scoreLabel.zPosition = 5
        scoreLabel.fontName = "04b_19"
        scoreLabel.fontSize = 64
        
        updateScoreLabel()
        
        self.addChild(scoreLabel)
    }
    
    func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
    }
    
    func createGround() {
        ground = SKSpriteNode(imageNamed: "ground")
        ground.position = CGPoint(x: 0, y: -self.frame.height / 2 + ground.frame.height / 3)
        ground.size = CGSize(width: self.frame.width, height: ground.frame.height)
        
        ground.zPosition = 3
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.collisionBitMask = PhysicsCategory.bird
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = false
        
        self.addChild(ground)
    }
    
    func createBird() {
        bird = SKSpriteNode(imageNamed: "bird")
        bird.size = CGSize(width: 100, height: 80)
        bird.position = CGPoint(x: -bird.frame.width, y: 0)
        
        bird.zPosition = 2
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.frame.width / 2)
        bird.physicsBody?.categoryBitMask = PhysicsCategory.bird
        bird.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.wall
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.wall | PhysicsCategory.score
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.isDynamic = true
        
        self.addChild(bird)
    }
    
    func createWalls() {
        wallPair = SKNode()
        
        let scoreNode = SKSpriteNode(imageNamed: "coin")
        let topWall = SKSpriteNode(imageNamed: "pipe")
        let bottomWall = SKSpriteNode(imageNamed: "pipe")
        let randomPosition = CGFloat.random(in: -250...100)
        
        topWall.position = CGPoint(x: self.frame.width, y: 500)
        topWall.zRotation = .pi
        topWall.setScale(0.5)
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.bird
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        topWall.physicsBody?.affectedByGravity = false
        topWall.physicsBody?.isDynamic = false
        
        bottomWall.position = CGPoint(x: self.frame.width, y: -300)
        bottomWall.setScale(0.5)
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        bottomWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        bottomWall.physicsBody?.collisionBitMask = PhysicsCategory.bird
        bottomWall.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        bottomWall.physicsBody?.affectedByGravity = false
        bottomWall.physicsBody?.isDynamic = false
        
        scoreNode.size = CGSize(width: 50, height: 50)
        scoreNode.position = CGPoint(x: self.frame.width, y: 100)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.color = SKColor.blue
        
        wallPair.addChild(topWall)
        wallPair.addChild(bottomWall)
        wallPair.addChild(scoreNode)
        
        wallPair.name = "wallPair"
        wallPair.zPosition = 1
        wallPair.position.y += randomPosition
        
        wallPair.run(moveAndRemove)
        
        self.addChild(wallPair)
    }
    
    func createBackground() {
        var startPosition = -self.frame.width / 2
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "background")
            
            background.position = CGPoint(x: startPosition, y: 0)
            background.name = "background"
            background.size = self.view?.bounds.size as! CGSize
            self.addChild(background)
            
            startPosition += self.frame.width
        }
    }
}
