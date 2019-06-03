//
//  GameScene.swift
//  Sharapov Wars
//
//  Created by Никита Крупей on 3/30/19.
//  Copyright © 2019 Никита Крупей. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
 
    let playerCategory: UInt32 = 0x1 << 0
    let amoCategory: UInt32 = 0x1 << 1
    let playerTorpedoCategory: UInt32 = 0x1 << 2
    let bossCategory: UInt32 = 0x1 << 3
    let bossTorpedoCategory: UInt32 = 0x1 << 4
    let savePlaceCategory: UInt32 = 0x1 << 5
    
    //var player: SKSpriteNode!
    var mainBackground: SKSpriteNode!
    
    var playerHealth: SKLabelNode!
    var health: Int = 0 {
        didSet{
            playerHealth.text = "Жизни: \(health)"
        }
    }
    
    
    var bossHealth: SKLabelNode!
    var healthOfTheBoss: Int = 0 {
        didSet{
            bossHealth.text = "Жизни: \(healthOfTheBoss)"
        }
    }
   // var boss: SKSpriteNode!
    
    var amoLeft: SKLabelNode!
    var amo: Int = 30 {
        didSet {
            amoLeft.text = "Патроны: \(amo)"
        }
    }
    
    var gameTimer: Timer!
    var amoTimer: Timer!
    var weaponTimer: Timer!
    var bossMovementTimer: Timer!
    
    var contactDone = Bool()
    
    var bossFireShots = ["normalShot", "superShot"]
    
    lazy var boss: SKSpriteNode = {
        var sprite = SKSpriteNode(imageNamed: "boss")
        sprite.position = CGPoint(x: UIScreen.main.bounds.width * 0.5 - 100, y: 0)
        sprite.zPosition = 4
        sprite.size = CGSize(width: 90.0, height: 120.0)
        
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        
        sprite.physicsBody?.isDynamic = true
        
        sprite.physicsBody?.categoryBitMask = bossCategory
        sprite.physicsBody?.collisionBitMask = playerTorpedoCategory
        sprite.physicsBody?.contactTestBitMask = playerTorpedoCategory
        
        
        return sprite
    }()
    
    lazy var player: SKSpriteNode = {
        var sprite = SKSpriteNode(imageNamed: "soldier")
        sprite.position = CGPoint.zero
        sprite.zPosition = 1
        sprite.size = CGSize(width: 90.0, height: 120.0)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        
        
        sprite.physicsBody?.isDynamic = true
        
        sprite.physicsBody?.categoryBitMask = playerCategory
       // sprite.physicsBody?.collisionBitMask = bossTorpedoCategory
        //sprite.physicsBody?.contactTestBitMask = bossTorpedoCategory
        sprite.physicsBody?.collisionBitMask = amoCategory
        sprite.physicsBody?.contactTestBitMask = bossTorpedoCategory
        
        return sprite
    }()
    
    
    lazy var myWeapon: SKSpriteNode = {
        var sprite = SKSpriteNode(imageNamed: "myWeapon")
        sprite.size = CGSize(width: 100, height: 50)
        
        return sprite
    }()
    
    override func didMove(to view: SKView) {
        
        
        
        mainBackground = SKSpriteNode(imageNamed: "woodBackground")
        mainBackground.scale(to: UIScreen.main.bounds.size)
        mainBackground.zPosition = -1
        self.addChild(mainBackground)
        
//        player.physicsBody?.categoryBitMask = playerCategory
//        player.physicsBody?.collisionBitMask = bossTorpedoCategory
//        player.physicsBody?.contactTestBitMask = bossTorpedoCategory
        
        
        self.addChild(player)
        
        
        
        self.addChild(myWeapon)
        myWeapon.position = player.position
        self.myWeapon.position.x = self.myWeapon.position.x + 10
        myWeapon.zPosition = 2
        
        
        
//        boss.physicsBody?.categoryBitMask = bossCategory
//        boss.physicsBody?.collisionBitMask = playerTorpedoCategory
//        boss.physicsBody?.contactTestBitMask = playerTorpedoCategory

        
        self.addChild(boss)
        
        setupJoyStick()
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        let worldBorder = SKPhysicsBody(edgeLoopFrom: self.frame)
        worldBorder.friction = 0
        worldBorder.restitution = 1
        self.physicsBody = worldBorder
        
        //worldBorder.physicsBody.pinned = true
        
        playerHealth = SKLabelNode(text: "Жизни: 23")
        playerHealth.position = CGPoint(x: UIScreen.main.bounds.width * -0.5 + playerHealth.frame.width - 30, y: UIScreen.main.bounds.height * 0.5 - 35)
        playerHealth.zPosition = 2
        playerHealth.fontName = "AmericanTypewriter-Bold"
        playerHealth.fontSize = 20
        playerHealth.fontColor = UIColor.black
        health = 10
        
        self.addChild(playerHealth)
        
        
        bossHealth = SKLabelNode(text: "Жизни: 23")
        bossHealth.position = CGPoint(x: UIScreen.main.bounds.width * 0.5 - bossHealth.frame.width + 30, y: UIScreen.main.bounds.height * 0.5 - 35)
        bossHealth.zPosition = 7
        bossHealth.fontName = "AmericanTypewriter-Bold"
        bossHealth.fontSize = 20
        bossHealth.fontColor = UIColor.black
        //health = 10
        healthOfTheBoss = 1
        
        self.addChild(bossHealth)
        
       // self.addChild(playerHealth)
        
        //playerHealth.frame.width
       // playerHealth.position.x
        
        amoLeft = SKLabelNode(text: "Патроны: 1230")
        amoLeft.position = CGPoint(x: UIScreen.main.bounds.width * -0.5 + playerHealth.frame.width - 30 + amoLeft.frame.width, y: UIScreen.main.bounds.height * 0.5 - 35)
        amoLeft.zPosition = 3
        amoLeft.fontName = "AmericanTypewriter-Bold"
        amoLeft.fontSize = 20
        amoLeft.fontColor = UIColor.darkText
        amo = 30
        
        self.addChild(amoLeft)
        
        
        var index = 0
        while index < 10 {
            savePlaceSpawn()
            index += 1
        }
        
        
        var fireBossInterval = 0.75
        
        if UserDefaults.standard.bool(forKey: "Сложно"){
            fireBossInterval = 0.5
        }
        if UserDefaults.standard.bool(forKey: "Бурунин"){
            fireBossInterval = 0.3
        }
        
        
        gameTimer = Timer.scheduledTimer(timeInterval: fireBossInterval, target: self, selector: #selector(bossFire), userInfo: nil, repeats: true)
       
        
        
        bossMovementTimer = Timer.scheduledTimer(timeInterval: TimeInterval(CGFloat.random(in: 0 ... 2)), target: self, selector: #selector(bossMoveTo), userInfo: nil, repeats: true)
        
        
        amoTimer = Timer.scheduledTimer(timeInterval: TimeInterval(CGFloat.random(in: 10 ... 20)), target: self, selector: #selector(amoSpawn), userInfo: nil, repeats: true)
        
        
        
        contactDone = false
        
        
    }
    
    override func didSimulatePhysics() {
        enumerateChildNodes(withName: "EnemyTorpedo") {(enemyTorpedoNode, stop) in
            
            if (!self.intersects(enemyTorpedoNode)){
                enemyTorpedoNode.removeFromParent()
            }
            
//            let heightScreen = UIScreen.main.bounds.height
//            if enemyBullet.position.y < -heightScreen {
//                enemyBullet.removeFromParent()
//            }
        }
        
        
        enumerateChildNodes(withName: "PlayerTorpedo") {(torpedoNode, stop) in
            
            if (!self.intersects(torpedoNode)){
                torpedoNode.removeFromParent()
            }
            
            //            let heightScreen = UIScreen.main.bounds.height
            //            if enemyBullet.position.y < -heightScreen {
            //                enemyBullet.removeFromParent()
            //            }
        }
    }
    
    @objc func bossMoveTo(){
        let halfWidth = UIScreen.main.bounds.width / 2 - boss.frame.width
        let halfHeight = UIScreen.main.bounds.height / 2 - boss.frame.height
        
        var a: CGFloat
        var b: CGFloat
        
        a = CGFloat.random(in: -halfWidth ... halfWidth)
        b = CGFloat.random(in: -halfHeight ... halfHeight)
        
        var location: CGPoint = CGPoint(x: a, y: b)
        
        let distance = distanceCalculate(a: boss.position, b: location)
        let speed: CGFloat = 150
        let time = timeToTravel(distance: distance, speed: speed)
        
        let moveAction = SKAction.move(to: location, duration: time)
        
        boss.run(moveAction)
        // moveAction.timingMode = SKActionTimingMode.easeInEaseOut
        
        // let point = CGPoint(x: self.player.zRotation, y: self.player.zRotation)
        // actionArray.append(SKAction.move(by: CGVector(dx: x, dy: y), duration: animationDuration))
        // SKAction.move(by: CGVector(dx: x, dy: y), duration: animationDuration)
        //actionArray.append(SKAction.move(to: player.position, duration: time))
        //actionArray.append(SKAction.move(to: boss.position, duration: animationDuration))
        //actionArray.append(SKAction.removeFromParent())
        
        //enemyTorpedoNode.run(SKAction.sequence(actionArray))
        
     
    }
    
    @objc func playerFire()
        // point: CGPoint)
    {
        
        if amo > 0 {
            
            self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
            let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
            torpedoNode.position = myWeapon.position
            torpedoNode.position.x += 5
            torpedoNode.zPosition = 6
            torpedoNode.size.height = torpedoNode.size.height / 2
            torpedoNode.size.width = torpedoNode.size.width / 2
            //torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
            torpedoNode.physicsBody = SKPhysicsBody(texture: torpedoNode.texture!, size: torpedoNode.size)
            torpedoNode.physicsBody?.isDynamic = true
            
            torpedoNode.name = "PlayerTorpedo"
            
            torpedoNode.physicsBody?.categoryBitMask = playerTorpedoCategory
            torpedoNode.physicsBody?.collisionBitMask = 0
            torpedoNode.physicsBody?.contactTestBitMask = bossCategory
            
            torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
            
            self.addChild(torpedoNode)
            
            
            let sinus = sin(myWeapon.zRotation - 1.5)
            let cosinus = cos(myWeapon.zRotation - 1.5)
            
            //            xPos = player.position.x - sinus * player.size.height / 2
            //            yPos = player.position.y + cosinus * player.size.width / 2
            
            let speed: CGFloat = 1
            
            torpedoNode.physicsBody?.applyImpulse(CGVector(dx: -sinus, dy: cosinus))
            // torpedoNode.physicsBody?.applyImpulse(CGVector(dx: cosinus, dy: -sinus))
            
            
            
            amo -= 1
            
        }
    }
    
    
    
    @objc func bossFire(){
       // print("FIRE!!")
       
        
        let enemyTorpedoNode = SKSpriteNode(imageNamed: "enemyTorpedo")
        enemyTorpedoNode.position = boss.position
        enemyTorpedoNode.position.y += 5
        enemyTorpedoNode.zPosition = 9
        enemyTorpedoNode.size.height = enemyTorpedoNode.size.height / 2
        enemyTorpedoNode.size.width = enemyTorpedoNode.size.width / 2
        //torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
       // enemyTorpedoNode.physicsBody = SKPhysicsBody(texture: enemyTorpedoNode.texture!, size: enemyTorpedoNode.size)
        
        enemyTorpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: enemyTorpedoNode.size.width / 2)
        enemyTorpedoNode.physicsBody?.isDynamic = true
        
        enemyTorpedoNode.name = "EnemyTorpedo"
        
        enemyTorpedoNode.physicsBody?.categoryBitMask = bossTorpedoCategory
        enemyTorpedoNode.physicsBody?.collisionBitMask = 0
        enemyTorpedoNode.physicsBody?.contactTestBitMask = playerCategory
        
        enemyTorpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(enemyTorpedoNode)
        
        let animationDuration: TimeInterval = 1
        
        var actionArray = [SKAction]()
        
        
        let distance = distanceCalculate(a: boss.position, b: player.position)

        
        var dx = CGFloat(player.position.x - boss.position.x)
        var dy = CGFloat(player.position.y - boss.position.y)
        
        dx /= distance
        dy /= distance
        
        let vector = CGVector(dx:  dx, dy:  dy)
        
        enemyTorpedoNode.physicsBody?.applyImpulse(vector)
        
        let speed: CGFloat = 100
        let time = timeToTravel(distance: distance, speed: speed)
        
        //let moveAction = SKAction.move(to: touchLocation, duration: time)
       // moveAction.timingMode = SKActionTimingMode.easeInEaseOut
        
        // let point = CGPoint(x: self.player.zRotation, y: self.player.zRotation)
        // actionArray.append(SKAction.move(by: CGVector(dx: x, dy: y), duration: animationDuration))
        // SKAction.move(by: CGVector(dx: x, dy: y), duration: animationDuration)
        //actionArray.append(SKAction.move(to: player.position, duration: time))
        //actionArray.append(SKAction.move(to: boss.position, duration: animationDuration))
        //actionArray.append(SKAction.removeFromParent())
        
        //enemyTorpedoNode.run(SKAction.sequence(actionArray))
        
    }
    
    func distanceCalculate(a: CGPoint, b: CGPoint) -> CGFloat {
        return sqrt((b.x - a.x)*(b.x - a.x) + (b.y - a.y)*(b.y - a.y))
    }
    
    func timeToTravel(distance: CGFloat, speed: CGFloat) -> TimeInterval {
        let time = distance / speed
        return TimeInterval(time)
    }
    
    
    func savePlaceSpawn(){
        let savePlace = SKSpriteNode(imageNamed: "savePlace")
        
        let halfWidth = UIScreen.main.bounds.width / 2
        let halfHeight = UIScreen.main.bounds.height / 2
        
        // let halfWidth = size.width / 2
        //let halfHeight = size.height / 2
        savePlace.size = CGSize(width: 50.0, height: 30.0)
        savePlace.position.x = CGFloat.random(in: -halfWidth + 70 ... halfWidth - 70)
        
        
        //enemyBullet.position.x = CGFloat(arc4random()) / frame.size.width
        savePlace.position.y = CGFloat.random(in: -halfHeight + 20 + CGFloat(savePlace.size.height) ... halfHeight - 20 - savePlace.size.height)
        savePlace.zRotation = savePlace.zRotation - 1.5
        
        
        savePlace.zPosition = 13
        savePlace.size = CGSize(width: 50.0, height: 30.0)
        
        
        
        
        
        savePlace.physicsBody = SKPhysicsBody(texture: savePlace.texture!, size: savePlace.size)
        
        //amo.name = "enemyBullet"
        
        savePlace.physicsBody?.categoryBitMask = savePlaceCategory
        savePlace.physicsBody?.collisionBitMask = 0
        savePlace.physicsBody?.contactTestBitMask = bossTorpedoCategory | playerTorpedoCategory
        
        
        
        //enemyTorpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: enemyTorpedoNode.size.width / 2)
        //enemyTorpedoNode.physicsBody?.isDynamic = true
        
        //enemyTorpedoNode.name = "EnemyTorpedo"
        
//        enemyTorpedoNode.physicsBody?.categoryBitMask = bossTorpedoCategory
//        enemyTorpedoNode.physicsBody?.collisionBitMask = 0
//        enemyTorpedoNode.physicsBody?.contactTestBitMask = playerCategory
//
        savePlace.physicsBody?.usesPreciseCollisionDetection = true
//
        
        self.addChild(savePlace)
    }
    
    
    
    @objc func amoSpawn()
        //-> SKSpriteNode
    {
        let amo = SKSpriteNode(imageNamed: "bullet")
        
        let halfWidth = UIScreen.main.bounds.width / 2
        let halfHeight = UIScreen.main.bounds.height / 2
        
       // let halfWidth = size.width / 2
        //let halfHeight = size.height / 2
        amo.position.x = CGFloat.random(in: -halfWidth ... halfWidth)
        
        //enemyBullet.position.x = CGFloat(arc4random()) / frame.size.width
        amo.position.y = CGFloat.random(in: -halfHeight ... halfHeight)
        amo.zPosition = 5
        //enemyBullet.position.y = frame.size.height
        amo.size = CGSize(width: 70.0, height: 50.0)
        
        
        //enemyBullet.physicsBody = SKPhysicsBody(texture: enemyBullet.texture!, size: enemyBullet.size)
        
        amo.physicsBody = SKPhysicsBody(texture: amo.texture!, size: amo.size)
        
        //amo.name = "enemyBullet"
        
        amo.physicsBody?.categoryBitMask = amoCategory
        amo.physicsBody?.collisionBitMask = playerCategory
        amo.physicsBody?.contactTestBitMask = playerCategory
        
        self.addChild(amo)
        
       // return amo
    }
    
    
    //let pointOfShooting: CGPoint
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in (touches as! Set<UITouch>){
           let  pointOfShooting = touch.location(in: self)
//            pointOfShooting.x
            //playerFire(point:
           // playerFire()
        }
    }
    
    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        playerFire()
//    }
    
    
    

    lazy var analogJoystick: TLAnalogJoystick = {
        
        
        let js = TLAnalogJoystick(withDiameter: 100)
        js.position = CGPoint(x: UIScreen.main.bounds.width * -0.5 + js.radius + 55, y: UIScreen.main.bounds.height * -0.5 + js.radius + 35)
        js.zPosition = 50
        js.handleColor = UIColor.darkGray
        js.baseColor = UIColor.black
        return js
    }()
    
    
    lazy var aimJoystick: TLAnalogJoystick = {
        
        
        let js = TLAnalogJoystick(withDiameter: 100)
        js.position = CGPoint(x: UIScreen.main.bounds.width * 0.5 - js.radius - 55, y: UIScreen.main.bounds.height * -0.5 + js.radius + 35)
        js.zPosition = 50
        js.handleColor = UIColor.darkGray
        js.baseColor = UIColor.black
        return js
    }()


    func setupJoyStick(){
        addChild(analogJoystick)
        addChild(aimJoystick)
        
        analogJoystick.on(.move) {[unowned self] joystick in
            
            let pVelocity = joystick.velocity
            let speed = CGFloat(0.12)
            
            self.player.position = CGPoint(x: self.player.position.x + (pVelocity.x * speed), y: self.player.position.y + (pVelocity.y * speed))
            
            self.myWeapon.position = self.player.position
            self.myWeapon.position.x = self.myWeapon.position.x + 10
            
           //self.player.zRotation = joystick.angular
            //print(self.player.zRotation)
            
        }
        
        var isFire: Bool = true
        aimJoystick.on(.begin) {[unowned self] joystick in
            
            //self.myWeapon.zRotation = joystick.angular + 1.5
            //if isFire == true {
            //if isFire == true{
            self.weaponTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(self.playerFire), userInfo: nil, repeats: true)
            //}
           // }
           // isFire == true
        }
        
        
        aimJoystick.on(.move) {[unowned self] joystick in
            self.myWeapon.zRotation = joystick.angular + 1.5
            //self.weaponTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(self.playerFire), userInfo: nil, repeats: true)
        }
        
        aimJoystick.on(.end) { [unowned self] joystick in
            
            self.weaponTimer.invalidate()
            //isFire = false
            //self.myWeapon.zRotation = joystick.angular + 1.5
           // self.weaponTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(self.playerFire), userInfo: nil, repeats: true)
            //isFire = false
            //self.weaponTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(self.playerFire), userInfo: nil, repeats: false)
        }
        
        
        
    }
    
    func amIShooting(shootOrNot: Bool){
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {

      
        
            if contact.bodyA.categoryBitMask == playerTorpedoCategory && contact.bodyB.categoryBitMask == bossCategory {
                
                if let node = contact.bodyA.node as? SKSpriteNode{
                    if node.parent != nil {
                        node.removeFromParent()
                        healthOfTheBoss -= 1
                        
                        if healthOfTheBoss <= 0 {
                            //win
                            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                            let win = WinScene(fileNamed: "WinScene")
                            self.view?.presentScene(win!, transition: transition)
                        }
                        
                        let explosion = SKEmitterNode(fileNamed: "Explosion")!
                        explosion.position = boss.position
                        self.addChild(explosion)
                        self.run(SKAction.wait(forDuration: 1)){
                            explosion.removeFromParent()
                        }
                        
                    }
                }
            } else if contact.bodyA.categoryBitMask == bossCategory && contact.bodyB.categoryBitMask == playerTorpedoCategory{

                if let node = contact.bodyB.node as? SKSpriteNode{
                    if node.parent != nil {
                        node.removeFromParent()
                        healthOfTheBoss -= 1
                        
                        if healthOfTheBoss <= 0 {
                            //win
                            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                            let win = WinScene(fileNamed: "WinScene")
                            self.view?.presentScene(win!, transition: transition)
                        }
                        
                        let explosion = SKEmitterNode(fileNamed: "Explosion")!
                        explosion.position = boss.position
                        //explosion.
                        self.addChild(explosion)
                        self.run(SKAction.wait(forDuration: 1)){
                            explosion.removeFromParent()
                        }
                        
                    }
                }
                
            }
        
        
        
        if contact.bodyA.categoryBitMask == amoCategory && contact.bodyB.categoryBitMask == playerCategory {
            
            if let node = contact.bodyA.node as? SKSpriteNode{
                if node.parent != nil {
                    node.removeFromParent()
                    amo += 30
                }
            }
        } else if contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == amoCategory{
            
            if let node = contact.bodyB.node as? SKSpriteNode{
                if node.parent != nil {
                    node.removeFromParent()
                    amo += 30
                }
            }
            
        }
        
        
        
//        bossTorpedoCategory
//        playerCategory
        
        if contact.bodyA.categoryBitMask == bossTorpedoCategory && contact.bodyB.categoryBitMask == playerCategory {
            
            if let node = contact.bodyA.node as? SKSpriteNode{
                if node.parent != nil {
                    node.removeFromParent()
                    health -= 1
                    if health <= 0 {
                        //gameover
                        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                        let gameOver = GameOverScene(fileNamed: "GameOverScene")
                        self.view?.presentScene(gameOver!, transition: transition)
                        
                        
                    }
                    
                    
                    let explosion = SKEmitterNode(fileNamed: "Explosion")!
                    explosion.position = player.position
                    self.addChild(explosion)
                    self.run(SKAction.wait(forDuration: 1)){
                        explosion.removeFromParent()
                    }
                    
                }
            }
        } else if contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == bossTorpedoCategory{
            
            if let node = contact.bodyB.node as? SKSpriteNode{
                if node.parent != nil {
                    node.removeFromParent()
                    health -= 1
                    if health <= 0 {
                        //gameover
                        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                        let gameOver = GameOverScene(fileNamed: "GameOverScene")
                        self.view?.presentScene(gameOver!, transition: transition)
                    }
                    
                    let explosion = SKEmitterNode(fileNamed: "Explosion")!
                    explosion.position = player.position
                    //explosion.
                    self.addChild(explosion)
                    self.run(SKAction.wait(forDuration: 1)){
                        explosion.removeFromParent()
                    }
                    
                }
            }
            
        }
        
        
        if (contact.bodyA.categoryBitMask == savePlaceCategory && contact.bodyB.categoryBitMask == bossTorpedoCategory) || (contact.bodyA.categoryBitMask == savePlaceCategory && contact.bodyB.categoryBitMask == playerTorpedoCategory){
            
            if let node = contact.bodyB.node as? SKSpriteNode{
                if node.parent != nil {
                    node.removeFromParent()
                }
            }
        } else if (contact.bodyA.categoryBitMask == bossTorpedoCategory && contact.bodyB.categoryBitMask == savePlaceCategory) || (contact.bodyA.categoryBitMask == playerTorpedoCategory && contact.bodyB.categoryBitMask == savePlaceCategory){
            
            if let node = contact.bodyA.node as? SKSpriteNode{
                if node.parent != nil {
                    node.removeFromParent()
                    
                }
            }
            
        }
        
        

        
    }
    
    
    
    func torpedoDidCollideWithBoss (torpedo: SKSpriteNode, boss: SKSpriteNode){
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = boss.position
        self.addChild(explosion)
        
        torpedo.removeFromParent()
       // print("HIT THIS BITCH")
        self.run(SKAction.wait(forDuration: 2)){
            explosion.removeFromParent()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
//        if ((enemyTorpedoNode.parent != nil) && !intersects(enemyTorpedoNode)){
//            enemyTorpedoNode.removeFromParent()
//        }
//        if ((torpedoNode.parent != nil) && !intersects(torpedoNode)){
//            torpedoNode.removeFromParent()
//        }
    }
}
