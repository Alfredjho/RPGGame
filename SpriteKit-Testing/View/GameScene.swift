import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var textLabel = SKLabelNode()
    var typedText: String = ""
    
    var sceneCamera: SKCameraNode = SKCameraNode()
    var floorCoordinates = [CGPoint]()
    var trapdoorNode: SKSpriteNode?
    
    var hero = Hero()
    var labelHealth: SKLabelNode = SKLabelNode()
    
    var isStunned = false
    var facingDirection = ""
    let heroManager = HeroManager()
    let labelManager = LabelManager()
    let sceneManager = SceneManager()
    
    var spellbook = SKSpriteNode()
    let spellList: [String] = ["fireSpell", "waterSpell"]
    var spellPage = 0
    
    var npc = SKSpriteNode()
    var npcName = SKLabelNode()
    var npcDialog = SKLabelNode()
    let dialog: [String] = ["Helo, newcomer!", "I see you want to challenge this tower, huh?",
                            "Here, I'll give you something!", "Press [TAB] to open", "[TYPE] to chant and [ENTER] to cast!"]
    var dialogPage = 0
    
    var isCollidingWithNPC = false
    var finishedTalking = false
    var targetedBox = 0
    
    var box1 = SKSpriteNode()
    var box2 = SKSpriteNode()
    var box3 = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        self.sceneCamera = childNode(withName: "sceneCamera") as! SKCameraNode
        
        // Initialize and position your label
        textLabel = SKLabelNode(fontNamed: "Helvetica")
        textLabel.fontSize = 16
        textLabel.text = typedText
        self.addChild(textLabel)
        
        spellbook = childNode(withName: "spellbook") as! SKSpriteNode
        spellbook.texture = SKTexture(imageNamed: spellList[0])
        spellbook.isHidden = true
        spellbook.zPosition = 1
        
        // Set up physics
        self.physicsWorld.contactDelegate = self
        
        for node in self.children {
            if let someTileMap: SKTileMapNode = node as? SKTileMapNode {
                giveTileMapPhysicsBody(map: someTileMap)
                
                someTileMap.removeFromParent()
            }
        }
        
        hero.spriteNode = childNode(withName: "player") as! SKSpriteNode
        hero.setupSpriteNode()
            
        labelHealth = hero.spriteNode.childNode(withName: "labelHealth") as! SKLabelNode
        labelHealth.text = "\(hero.currentHealth)"
                
        
        box1 = setUpBox(named: "box1", position: CGPoint(x: 96, y: 0))
        box2 = setUpBox(named: "box2", position: CGPoint(x: 96, y: -16))
        box3 = setUpBox(named: "box3", position: CGPoint(x: 96, y: -32))
        
        self.addChild(box1)
        self.addChild(box2)
        self.addChild(box3)
        
        
        if let npcNode = self.childNode(withName: "npc") as? SKSpriteNode {
            npc = npcNode
            npc.physicsBody?.categoryBitMask = bitMask.npc.rawValue
            npc.physicsBody?.contactTestBitMask = bitMask.sand.rawValue
            npc.physicsBody?.collisionBitMask = bitMask.person.rawValue

            
            npcName = (npc.childNode(withName: "npcName") as? SKLabelNode)!

            
            npcDialog = (npc.childNode(withName: "npcDialog") as? SKLabelNode)!
            npcDialog.isHidden = true
 
        }
        
        changeRandomFloorTileToTrapdoor()
        
    }
    
    func changeRandomFloorTileToTrapdoor() {
        if let randomFloorCoordinate = floorCoordinates.randomElement() {
            let trapdoorTexture = SKTexture(imageNamed: "trapdoor")
            let trapdoorNode = SKSpriteNode(texture: trapdoorTexture)
            trapdoorNode.position = randomFloorCoordinate
            trapdoorNode.size = CGSize(width: 16, height: 16)
            trapdoorNode.physicsBody = SKPhysicsBody(texture: trapdoorTexture, size: trapdoorNode.size)
            trapdoorNode.physicsBody?.categoryBitMask = bitMask.trapdoor.rawValue
            trapdoorNode.physicsBody?.collisionBitMask = 0
            trapdoorNode.physicsBody?.contactTestBitMask = bitMask.person.rawValue
            trapdoorNode.physicsBody?.affectedByGravity = false
            trapdoorNode.physicsBody?.isDynamic = false
            trapdoorNode.physicsBody?.friction = 1
            trapdoorNode.zPosition = -1
            
            self.addChild(trapdoorNode)
            self.trapdoorNode = trapdoorNode
        }
    }

    
    func setUpBox(named name: String, position: CGPoint) -> SKSpriteNode {
        let box = SKSpriteNode(color: .red, size: CGSize(width: 16, height: 16))
        box.name = name
        box.position = position
        box.zPosition = 0
        box.texture = SKTexture(imageNamed: "barrel")
        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
        box.physicsBody?.isDynamic = false
        box.physicsBody?.categoryBitMask = bitMask.box.rawValue
        box.physicsBody?.contactTestBitMask = bitMask.fireball.rawValue
        box.physicsBody?.collisionBitMask = bitMask.fireball.rawValue | bitMask.person.rawValue
        
        return box
    }

    
    func giveTileMapPhysicsBody(map: SKTileMapNode) {
        let tileMap = map
        let startLocation: CGPoint = tileMap.position
        let tileSize = tileMap.tileSize
        let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width
        let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height
        
        for col in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                
                if let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row) {
                    
                    let tileArray = tileDefinition.textures
                    let tileTextures = tileArray[0]
                    let x = CGFloat(col) * tileSize.width - halfWidth + ( tileSize.width / 2 )
                    let y = CGFloat(row) * tileSize.height - halfHeight + ( tileSize.height / 2 )
                    
                    let tileNode = SKSpriteNode(texture: tileTextures)
                    tileNode.position = CGPoint(x: x, y: y)
                    tileNode.size = CGSize(width: 16, height: 16)
                    tileNode.physicsBody = SKPhysicsBody(texture: tileTextures, size: CGSize(width: 16, height: 16))
                    
                    if tileMap.name == "wall" {
                        tileNode.physicsBody?.categoryBitMask = bitMask.wall.rawValue
                        tileNode.physicsBody?.contactTestBitMask = 0
                        tileNode.physicsBody?.collisionBitMask = bitMask.person.rawValue
                    }
                    else if tileMap.name == "floor" {
                        tileNode.physicsBody?.categoryBitMask = bitMask.sand.rawValue
                        tileNode.physicsBody?.collisionBitMask = 0
                        
                        let newPoint = CGPoint(x: x, y: y)
                        let newPointConverted = self.convert(newPoint, from: tileMap)
            
                        floorCoordinates.append(newPointConverted)
                    }
                    
                    tileNode.physicsBody?.affectedByGravity = false
                    tileNode.physicsBody?.isDynamic = false
                    tileNode.physicsBody?.friction = 1
                    tileNode.zPosition = -1
                    
                    tileNode.position = CGPoint(x: tileNode.position.x + startLocation.x, y: tileNode.position.y + startLocation.y)
                    self.addChild(tileNode)
                }
            }
        }
    }
    
    override func keyDown(with event: NSEvent) {
        
        if isStunned {
            print("you are stunned!")
            return
        }
        
        switch event.keyCode {
        case 123:
            hero.move(direction: .left)
        case 124:
            hero.move(direction: .right)
        case 126:
            hero.move(direction: .up)
        case 125:
            hero.move(direction: .down)
        case 0x12: //angka 1
            targetedBox = 1
        case 0x13: //angka 2
            targetedBox = 2
        case 0x14: //angka 3
            targetedBox = 3
        case 48:
            if finishedTalking {
                openSpellBook()
            }
        case 36: // Enter key
            if finishedTalking{
                castSpell(direction: hero.facingDirection)
                typedText = ""
                labelManager.updateLabel(label: textLabel, typedText: typedText)
            }
        case 49: // Space key
        if isCollidingWithNPC {
            npcTalk()
        } else {
            print("Space key pressed, but no collision with NPC")
        }
        default:
            if(finishedTalking){
                spellbook.isHidden = true
                if let characters = event.characters {
                    for char in characters {
                        if char.isLetter || char.isWhitespace || char.isNumber {
                            typedText.append(char)
                            labelManager.updateLabel(label: textLabel, typedText: typedText)
                        }
                    }
                }
            }
        }
    }
    
    func openSpellBook() {
        if spellbook.isHidden {
           spellbook.isHidden = false
           spellPage = 0
           spellbook.texture = SKTexture(imageNamed: spellList[spellPage])
       } else {
           spellPage += 1
           if spellPage >= spellList.count {
               spellbook.isHidden = true
           } else {
               spellbook.texture = SKTexture(imageNamed: spellList[spellPage])
           }
       }
    }
    
    func npcTalk() {
        if npcDialog.isHidden {
            npcDialog.isHidden = false
            dialogPage = 0
            npcDialog.text = dialog[dialogPage]
        } else {
            dialogPage += 1
            if dialogPage >= dialog.count {
                npcDialog.isHidden = true
                finishedTalking = true
            } else {
                npcDialog.text = dialog[dialogPage]
            }
        }
    }
    
    func castSpell(direction: String) {
            if typedText.lowercased() == "fireball" {
                if targetedBox != 0 {
                    castFireballtoTarget(target: targetedBox)
                } else {
                    castFireball(direction: direction)
                }
            } else {
                isStunned = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isStunned = false
                }
            }
        }
    
    func castFireballtoTarget(target: Int) {
            print("fireball casted")

            let fireball = SKSpriteNode(texture: SKTexture(imageNamed: "fireball"))
            fireball.position = hero.spriteNode.position
            fireball.zPosition = 0
            fireball.size = CGSize(width: 16, height: 16)
            fireball.physicsBody = SKPhysicsBody(rectangleOf: fireball.size)
            fireball.physicsBody?.isDynamic = true
            fireball.physicsBody?.categoryBitMask = bitMask.fireball.rawValue
            fireball.physicsBody?.contactTestBitMask = bitMask.box.rawValue
            fireball.physicsBody?.collisionBitMask = bitMask.box.rawValue
            fireball.physicsBody?.usesPreciseCollisionDetection = true
            fireball.physicsBody?.affectedByGravity = false
            fireball.name = "fireball"
            addChild(fireball)

            var moveAction: SKAction
            switch target {
            case 1:
                moveAction = SKAction.move(to: box1.position, duration: 0.25)
            case 2:
                moveAction = SKAction.move(to: box2.position, duration: 0.25)
            case 3:
                moveAction = SKAction.move(to: box3.position, duration: 0.25)
            default:
                return
            }

            fireball.run(moveAction) {
                fireball.removeFromParent()
            }
        }
    
    func castFireball(direction: String) {
        print("fireball casted")

        let fireball = SKSpriteNode(texture: SKTexture(imageNamed: "fireball"))
        fireball.position = hero.spriteNode.position
        fireball.zPosition = 0
        fireball.size = CGSize(width: 16, height: 16)
        fireball.physicsBody = SKPhysicsBody(rectangleOf: fireball.size)
        fireball.physicsBody?.isDynamic = true
        fireball.physicsBody?.categoryBitMask = bitMask.fireball.rawValue
        fireball.physicsBody?.contactTestBitMask = bitMask.box.rawValue
        fireball.physicsBody?.collisionBitMask = bitMask.box.rawValue
        fireball.physicsBody?.usesPreciseCollisionDetection = true
        fireball.physicsBody?.affectedByGravity = false
        fireball.name = "fireball"
        addChild(fireball)

        var moveAction: SKAction
        switch direction {
        case "right":
            moveAction = SKAction.move(by: CGVector(dx: 80, dy: 0), duration: 0.25)
        case "left":
            moveAction = SKAction.move(by: CGVector(dx: -80, dy: 0), duration: 0.25)
        case "up":
            moveAction = SKAction.move(by: CGVector(dx: 0, dy: 80), duration: 0.25)
        case "down":
            moveAction = SKAction.move(by: CGVector(dx: 0, dy: -80), duration: 0.25)
        default:
            return
        }

        fireball.run(moveAction) {
            fireball.removeFromParent()
        }
    }


    
    override func update(_ currentTime: TimeInterval) {
        sceneCamera.position = hero.spriteNode.position
        labelHealth.text = "\(hero.currentHealth)"
        sceneCamera.position = hero.spriteNode.position
        
        spellbook.position.x = hero.spriteNode.position.x
        spellbook.position.y = hero.spriteNode.position.y + 64
        labelManager.setLabelAboveHero(label: textLabel, hero: hero.spriteNode)
        
        // Cek apakah pemain masih dalam kolisi dengan NPC
        if hero.spriteNode.frame.intersects(npc.frame) {
                if !isCollidingWithNPC {
                    isCollidingWithNPC = true
                    print("Player collided with NPC!")
                    hero.currentHealth -= 10
                    print(" kebaca darah: \(hero.currentHealth)")
                }
            } else {
                if isCollidingWithNPC {
                    isCollidingWithNPC = false
                    print("Player ended collision with NPC")
                }
            }
    }
}
