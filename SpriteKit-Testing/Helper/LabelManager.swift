//
//  LabelManager.swift
//  RPGTest
//
//  Created by Alfred Jhonatan on 05/06/24.
//

import SpriteKit
import GameplayKit

class LabelManager : SKLabelNode, ObservableObject {
    func setLabelAboveHero(label: SKLabelNode, hero: SKSpriteNode) {
        let labelOffset = CGFloat(16)
        label.position = CGPoint(x: hero.position.x, y: hero.position.y + hero.size.height / 2 + labelOffset)
    }
    
    func updateLabel(label: SKLabelNode, typedText : String) {
        label.text = typedText
    }
}
