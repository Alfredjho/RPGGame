import SpriteKit

class Hero {
    var spriteNode: SKSpriteNode = SKSpriteNode()
    
    var moveAmount: CGFloat = 16
    
    var currentHealth: Int = 100
    var maxHealth: Int = 100
    
    var inputSpell: String = ""
    var texture: SKTexture = SKTexture(imageNamed: "character-left")
    var facingDirection = ""
    
    func setupSpriteNode() {
        spriteNode.physicsBody?.categoryBitMask = bitMask.person.rawValue
        spriteNode.physicsBody?.contactTestBitMask = bitMask.sand.rawValue | bitMask.trapdoor.rawValue
        spriteNode.physicsBody?.collisionBitMask = bitMask.wall.rawValue | bitMask.npc.rawValue | bitMask.box.rawValue
        spriteNode.physicsBody?.allowsRotation = false
        spriteNode.physicsBody?.affectedByGravity = false
    }
    
    func move(direction: Direction) {
       
        let moveAction: SKAction
        
        switch direction {
        case .left:
            texture = SKTexture(imageNamed: "character-left")
            spriteNode.texture = texture
            facingDirection = "left"
            moveAction = SKAction.moveBy(x: -moveAmount, y: 0, duration: 0.1)
            
        case .right:
            texture = SKTexture(imageNamed: "character-right")
            spriteNode.texture = texture
            facingDirection = "right"
            moveAction = SKAction.moveBy(x: moveAmount, y: 0, duration: 0.1)
            
        case .up:
            texture = SKTexture(imageNamed: "character-up")
            spriteNode.texture = texture
            facingDirection = "up"
            moveAction = SKAction.moveBy(x: 0, y: moveAmount, duration: 0.1)
            
        case .down:
            texture = SKTexture(imageNamed: "character-down")
            spriteNode.texture = texture
            facingDirection = "down"
            moveAction = SKAction.moveBy(x: 0, y: -moveAmount, duration: 0.1)
        }
        spriteNode.run(moveAction)
    }
}
