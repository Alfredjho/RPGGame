import SpriteKit

class SceneManager: ObservableObject {
    
    func changeScene(to sceneName: String, in view: SKView?, transitionDuration: TimeInterval = 1.0) {
        guard let view = view else { return }

        if let newScene = SKScene(fileNamed: sceneName) {
            newScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: transitionDuration)
            view.presentScene(newScene, transition: transition)
        } else {
            print("Error: Could not load \(sceneName).sks")
        }
    }

}
