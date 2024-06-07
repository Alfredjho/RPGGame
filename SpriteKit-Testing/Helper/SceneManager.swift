import SpriteKit

class SceneManager: ObservableObject {
    
    func changeScene(to sceneName: String, in view: SKView?, transitionDuration: TimeInterval = 1, hero: Hero) {
        guard let view = view else { return }

        if let newScene = GameScene(fileNamed: sceneName) {
            newScene.scaleMode = .aspectFill
            newScene.hero = hero
            let transition = SKTransition.fade(withDuration: transitionDuration)
            view.presentScene(newScene, transition: transition)
        } else {
            print("Error: Could not load \(sceneName).sks")
        }
    }

}
