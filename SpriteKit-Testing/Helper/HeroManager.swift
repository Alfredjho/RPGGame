import SpriteKit
import GameplayKit

class HeroManager: SKSpriteNode, ObservableObject {
    var heroFacingDirection = ""
    var sceneManager = SceneManager()
    
    func moveHero(direction: Direction, hero: SKSpriteNode) {
        let moveDistance: CGFloat = 16.0 // Adjust the movement distance as needed

        switch direction {
        case .up:
            // Move character up
            hero.texture = SKTexture(imageNamed: "character-up")
            let moveUpAction = SKAction.moveBy(x: 0, y: moveDistance, duration: 0.2)
            hero.run(moveUpAction)
            heroFacingDirection = "up"
        case .down:
            // Move character down
            hero.texture = SKTexture(imageNamed: "character-down")
            let moveDownAction = SKAction.moveBy(x: 0, y: -moveDistance, duration: 0.2)
            hero.run(moveDownAction)
            heroFacingDirection = "down"
        case .left:
            // Move character left
            hero.texture = SKTexture(imageNamed: "character-left")
            let moveLeftAction = SKAction.moveBy(x: -moveDistance, y: 0, duration: 0.2)
            hero.run(moveLeftAction)
            heroFacingDirection = "left"
        case .right:
            // Move character right
            hero.texture = SKTexture(imageNamed: "character-right")
            let moveRightAction = SKAction.moveBy(x: moveDistance, y: 0, duration: 0.2)
            hero.run(moveRightAction)
            heroFacingDirection = "right"
        }
    }
    

}
