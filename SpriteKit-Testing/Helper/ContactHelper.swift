import SpriteKit

enum bitMask: UInt32 {
    case person = 0x1
    case sand = 0x5
    case wall = 0x2
    case fireball = 0x4
    case trapdoor = 0x8
    case npc = 0x16
    case box = 0x32
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == (bitMask.fireball.rawValue | bitMask.box.rawValue) {
            if let fireballNode = contact.bodyA.node as? SKSpriteNode, contact.bodyA.categoryBitMask == bitMask.fireball.rawValue , fireballNode.name == "fireball" {
                fireballNode.removeFromParent()
                print("remove fireball")
            } else if let fireballNode = contact.bodyB.node as? SKSpriteNode, contact.bodyB.categoryBitMask == bitMask.fireball.rawValue , fireballNode.name == "fireball" {
                fireballNode.removeFromParent()
                print("remove fireball")
            }

            if let boxNode = contact.bodyA.node as? SKSpriteNode, contact.bodyA.categoryBitMask == bitMask.box.rawValue, boxNode.name == "box" {
                boxNode.removeFromParent()
                print("remove box")
            } else if let boxNode = contact.bodyB.node as? SKSpriteNode, contact.bodyB.categoryBitMask == bitMask.box.rawValue, boxNode.name == "box" {
                boxNode.removeFromParent()
                print("remove box")
            }
        }
        
        if contactMask == (bitMask.person.rawValue | bitMask.trapdoor.rawValue) {
            print("Player is on the trapdoor!")
        }
        
        if contactMask == (bitMask.person.rawValue | bitMask.npc.rawValue) {
            print("Player collided with NPC!")
            isCollidingWithNPC = true
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if contactMask == (bitMask.person.rawValue | bitMask.npc.rawValue) {
            if let bodyA = contact.bodyA.node as? SKSpriteNode, let bodyB = contact.bodyB.node as? SKSpriteNode {
                // Cek apakah bodyA atau bodyB adalah NPC
                if bodyA == npc || bodyB == npc {
                    // Berikan sedikit waktu untuk memastikan kolisi benar-benar berakhir
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        // Cek kembali apakah pemain masih dalam kolisi dengan NPC
                        if !self.hero.frame.intersects(self.npc.frame) {
                            self.isCollidingWithNPC = false
                            print("Player ended collision with NPC")
                        }
                    }
                }
            }
        }
    }



}
