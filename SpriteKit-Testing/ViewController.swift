import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    var preloadedScenes: [GKScene] = []
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            let window = NSApplication.shared.windows.first
            
            // Preload all scenes
            preloadScenes()
            
            // Present the first scene or any specific scene
            if let firstScene = preloadedScenes.first?.rootNode as? GameScene {
                firstScene.scaleMode = .aspectFit
                
                if let view = self.skView {
                    view.presentScene(firstScene)
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
            
            window?.toggleFullScreen(nil)
        }
    
    func preloadScenes() {
            let sceneNames = ["GameScene", "firstRoom"] // Add your SKS file names here
            
            for sceneName in sceneNames {
                if let scene = GKScene(fileNamed: sceneName) {
                    preloadedScenes.append(scene)
                } else {
                    print("Failed to load scene: \(sceneName)")
                }
            }
        }
}

