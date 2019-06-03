//
//  GameOverScene.swift
//  Sharapov Wars
//
//  Created by Никита Крупей on 3/31/19.
//  Copyright © 2019 Никита Крупей. All rights reserved.
//

import SpriteKit

class WinScene: SKScene {
    
    var win: SKLabelNode!
    var sharapovPic: SKSpriteNode!
    var newGameButton: SKSpriteNode!
    var difficultyLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        win = SKLabelNode(text: "ТЫ СДАЛ!!!")
        win.position = CGPoint(x: 0, y: UIScreen.main.bounds.height * 0.5 - 70)
        win.zPosition = 1
        win.fontName = "AmericanTypewriter-Bold"
        win.fontSize = 40
        win.fontColor = UIColor.white
        addChild(win)
        
        
        sharapovPic = SKSpriteNode(imageNamed: "winShar")
        //newGameButton.frame.width = 300
        //newGameButton.frame.height = 70
        sharapovPic.size.width = 200
        sharapovPic.size.height = 200
        sharapovPic.zPosition = 2
        sharapovPic.name = "newGameButton"
        sharapovPic.position = CGPoint(x: 0, y: UIScreen.main.bounds.height * 0.5 - 150 - win.frame.height)
        addChild(sharapovPic)
        
        
        
        newGameButton = SKSpriteNode(imageNamed: "newGame")
        //newGameButton.frame.width = 300
        //newGameButton.frame.height = 70
        newGameButton.size.width = 300
        newGameButton.size.height = 70
        newGameButton.zPosition = 2
        newGameButton.name = "newGameButton"
        newGameButton.position = CGPoint(x: 0, y: UIScreen.main.bounds.height * 0.5 - 90 - win.frame.height - sharapovPic.size.height)
        addChild(newGameButton)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self){
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGameButton" {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                //mainBackground.scale(to: UIScreen.main.bounds.size)
                let gameScene = GameScene(fileNamed: "GameScene")
                self.view?.presentScene(gameScene!, transition: transition)
            }
        }
    }
    
}
