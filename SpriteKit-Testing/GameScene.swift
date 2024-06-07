import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var textLabel = SKLabelNode()
    var typedText: String = ""
    
    var sceneCamera: SKCameraNode = SKCameraNode()
    var hero: SKSpriteNode = SKSpriteNode()
    var floorCoordinates = [CGPoint]()
    var trapdoorNode: SKSpriteNode?
    
    var isStunned = false
    var facingDirection = ""
    let heroManager = HeroManager()
    let labelManager = LabelManager()
    
    var spellbook = SKSpriteNode()
    let spellList: [String] = ["fireSpell", "waterSpell"]
    var spellPage = 0
    
    var npc = SKSpriteNode()
    var npcName = SKLabelNode()
    var npcDialog = SKLabelNode()
    let dialog: [String] = ["Helo, newcomer!", "Whatch'a doing here?", "fak yu"]
    var dialogPage = 0
    
    var isCollidingWithNPC = false
    
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
        
        if let playerNode = self.childNode(withName: "player") as? SKSpriteNode {
            hero = playerNode
            hero.physicsBody?.categoryBitMask = bitMask.person.rawValue
            hero.physicsBody?.contactTestBitMask = bitMask.sand.rawValue | bitMask.trapdoor.rawValue
            hero.physicsBody?.collisionBitMask = bitMask.wall.rawValue | bitMask.npc.rawValue | bitMask.box.rawValue
            hero.physicsBody?.allowsRotation = false
            hero.physicsBody?.affectedByGravity = false
        }
                
        
        setUpBox(named: "box", position: CGPoint(x: 32, y: -16))
        
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

    
    func setUpBox(named name: String, position: CGPoint) {
        let box = SKSpriteNode(color: .red, size: CGSize(width: 16, height: 16))
        box.name = name
        box.position = position
        box.texture = SKTexture(imageNamed: "barrel")
        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
        box.physicsBody?.isDynamic = false
        box.physicsBody?.categoryBitMask = bitMask.box.rawValue
        box.physicsBody?.contactTestBitMask = bitMask.fireball.rawValue
        box.physicsBody?.collisionBitMask = bitMask.person.rawValue
        addChild(box)
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
            heroManager.moveHero(direction: .left, hero: hero)
        case 124:
            heroManager.moveHero(direction: .right, hero: hero)
        case 126:
            heroManager.moveHero(direction: .up, hero: hero)
        case 125:
            heroManager.moveHero(direction: .down, hero: hero)
        case 48:
            openSpellBook()
        case 36: // Enter key
            castSpell(direction: heroManager.heroFacingDirection)
            typedText = ""
            labelManager.updateLabel(label: textLabel, typedText: typedText)
        case 49: // Space key
        if isCollidingWithNPC {
            npcTalk()
        } else {
            print("Space key pressed, but no collision with NPC")
        }
        default:
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
            } else {
                npcDialog.text = dialog[dialogPage]
            }
        }
    }
    
    func castSpell(direction: String) {
        if typedText.lowercased() == "fireball" {
            castFireball(direction: direction)
        } else {
            isStunned = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.isStunned = false
            }
        }
    }
    
    func castFireball(direction: String) {
        print("fireball casted")
        
        // Disable hero physics temporarily
        let heroPhysicsBody = hero.physicsBody
        hero.physicsBody = nil
        
        let fireball = SKSpriteNode(texture: SKTexture(imageNamed: "fireball"))
        fireball.position = hero.position
        fireball.size = CGSize(width: 16, height: 16)
        fireball.zPosition = 10
        fireball.physicsBody = SKPhysicsBody(circleOfRadius: fireball.size.width / 2)
        fireball.physicsBody?.isDynamic = true
        fireball.physicsBody?.categoryBitMask = bitMask.fireball.rawValue 
        fireball.physicsBody?.contactTestBitMask = bitMask.box.rawValue
        fireball.physicsBody?.collisionBitMask = 0
        fireball.physicsBody?.usesPreciseCollisionDetection = true
        fireball.physicsBody?.affectedByGravity = false
        addChild(fireball)

        var moveAction: SKAction
        switch direction {
        case "right":
            moveAction = SKAction.move(by: CGVector(dx: 800, dy: 0), duration: 0.5)
        case "left":
            moveAction = SKAction.move(by: CGVector(dx: -800, dy: 0), duration: 0.5)
        case "up":
            moveAction = SKAction.move(by: CGVector(dx: 0, dy: 800), duration: 0.5)
        case "down":
            moveAction = SKAction.move(by: CGVector(dx: 0, dy: -800), duration: 0.5)
        default:
            return
        }

        fireball.run(moveAction) {
            fireball.removeFromParent()
            // Re-enable hero physics after fireball is cast
            self.hero.physicsBody = heroPhysicsBody
        }
    }

    
    override func update(_ currentTime: TimeInterval) {
        sceneCamera.position = hero.position
        spellbook.position.x = hero.position.x
        spellbook.position.y = hero.position.y + 64
        labelManager.setLabelAboveHero(label: textLabel, hero: hero)
        
        // Cek apakah pemain masih dalam kolisi dengan NPC
            if hero.frame.intersects(npc.frame) {
                if !isCollidingWithNPC {
                    isCollidingWithNPC = true
                    print("Player collided with NPC!")
                }
            } else {
                if isCollidingWithNPC {
                    isCollidingWithNPC = false
                    print("Player ended collision with NPC")
                }
            }
    }
}
