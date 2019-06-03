//
//  MenuScene.swift
//  Sharapov Wars
//
//  Created by Никита Крупей on 3/31/19.
//  Copyright © 2019 Никита Крупей. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    
    var gameName: SKLabelNode!
    var newGameButton: SKSpriteNode!
    var difficultybutton: SKSpriteNode!
    var difficultyLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        gameName = SKLabelNode(text: "Победи Шарапова")
        gameName.position = CGPoint(x: 0, y: UIScreen.main.bounds.height * 0.5 - 70)
        gameName.zPosition = 1
        gameName.fontName = "AmericanTypewriter-Bold"
        gameName.fontSize = 40
        gameName.fontColor = UIColor.white
        addChild(gameName)
        
        
        newGameButton = SKSpriteNode(imageNamed: "newGame")
        //newGameButton.frame.width = 300
        //newGameButton.frame.height = 70
        newGameButton.size.width = 300
        newGameButton.size.height = 70
        newGameButton.zPosition = 2
        newGameButton.name = "newGameButton"
        newGameButton.position = CGPoint(x: 0, y: UIScreen.main.bounds.height * 0.5 - 90 - gameName.frame.height)
        addChild(newGameButton)
        
        
        difficultybutton = SKSpriteNode(imageNamed: "difficulty")
        difficultybutton.size.width = 290
        difficultybutton.size.height = 65
        difficultybutton.zPosition = 3
        difficultybutton.name = "difficultybutton"
        difficultybutton.position = CGPoint(x: 0, y: UIScreen.main.bounds.height * 0.5 - 110 - gameName.frame.height - newGameButton.size.height)
        addChild(difficultybutton)
        
        difficultyLabel = SKLabelNode(text: "Легко")
        difficultyLabel.position = CGPoint(x: 0, y: UIScreen.main.bounds.height * 0.5 - 130 - gameName.frame.height - newGameButton.size.height - difficultybutton.size.height)
        difficultyLabel.zPosition = 4
        difficultyLabel.fontName = "AmericanTypewriter-Bold"
        difficultyLabel.fontSize = 25
        difficultyLabel.fontColor = UIColor.white
        addChild(difficultyLabel)
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "Сложно"){
            difficultyLabel.text = "Сложно"
        } else if userDefaults.bool(forKey: ""){
            difficultyLabel.text = "Бурунин"
        } else{
            difficultyLabel.text = "Легко"
        }
        
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
            } else if nodesArray.first?.name == "difficultybutton" {
                changeDifficulty()
            }
        }
    }
    
    
    func changeDifficulty(){
        let userDefaults = UserDefaults.standard
        
        if difficultyLabel.text == "Легко" {
            difficultyLabel.text = "Сложно"
            userDefaults.set(true, forKey: "Сложно")
        }else if difficultyLabel.text == "Сложно"{
            difficultyLabel.text = "Бурунин"
            userDefaults.set(true, forKey: "Бурунин")
        } else {
            difficultyLabel.text = "Легко"
            userDefaults.set(true, forKey: "Легко")
        }
        
        userDefaults.synchronize()
        
        
    }
    

}
