import SpriteKit

enum bitMask: UInt32 {
    case person = 0x1
    case sand = 0x2
    case wall = 0x4
    case fireball = 0x8
    case trapdoor = 0x10
    case npc = 0x20
    case box = 0x40
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
            let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
            
            if contactMask == (bitMask.fireball.rawValue | bitMask.box.rawValue) {
                print("Fireball and box collision detected")
                
                // Debug prints for node names and bitmasks
                if let nodeA = contact.bodyA.node {
                    print("Node A: \(nodeA.name ?? "unknown"), Bitmask: \(contact.bodyA.categoryBitMask)")
                }
                if let nodeB = contact.bodyB.node {
                    print("Node B: \(nodeB.name ?? "unknown"), Bitmask: \(contact.bodyB.categoryBitMask)")
                }
                
                // Remove fireball node
                if let fireballNode = contact.bodyA.node as? SKSpriteNode, contact.bodyA.categoryBitMask == bitMask.fireball.rawValue, fireballNode.name == "fireball" {
                    fireballNode.removeFromParent()
                    print("Removed fireball A")
                } else if let fireballNode = contact.bodyB.node as? SKSpriteNode, contact.bodyB.categoryBitMask == bitMask.fireball.rawValue, fireballNode.name == "fireball" {
                    fireballNode.removeFromParent()
                    print("Removed fireball B")
                }
            
            }
            
            if contactMask == (bitMask.person.rawValue | bitMask.trapdoor.rawValue) {
                print("Player is on the trapdoor!")
                sceneManager.changeScene(to: "firstRoom", in: view, hero: self.hero)
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
                        if !self.hero.spriteNode.frame.intersects(self.npc.frame) {
                            self.isCollidingWithNPC = false
                            print("Player ended collision with NPC")
                        }
                    }
                }
            }
        }
    }



}

extension firstRoom: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
            let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
            
            if contactMask == (bitMask.fireball.rawValue | bitMask.box.rawValue) {
                print("Fireball and box collision detected")
                
                // Debug prints for node names and bitmasks
                if let nodeA = contact.bodyA.node {
                    print("Node A: \(nodeA.name ?? "unknown"), Bitmask: \(contact.bodyA.categoryBitMask)")
                }
                if let nodeB = contact.bodyB.node {
                    print("Node B: \(nodeB.name ?? "unknown"), Bitmask: \(contact.bodyB.categoryBitMask)")
                }
                
                // Remove fireball node
                if let fireballNode = contact.bodyA.node as? SKSpriteNode, contact.bodyA.categoryBitMask == bitMask.fireball.rawValue, fireballNode.name == "fireball" {
                    fireballNode.removeFromParent()
                    print("Removed fireball A")
                } else if let fireballNode = contact.bodyB.node as? SKSpriteNode, contact.bodyB.categoryBitMask == bitMask.fireball.rawValue, fireballNode.name == "fireball" {
                    fireballNode.removeFromParent()
                    print("Removed fireball B")
                }
            
            }
            
            if contactMask == (bitMask.person.rawValue | bitMask.trapdoor.rawValue) {
                print("Player is on the trapdoor!")
                sceneManager.changeScene(to: "GameScene", in: view, hero: hero)
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
                        if !self.hero.spriteNode.frame.intersects(self.npc.frame) {
                            self.isCollidingWithNPC = false
                            print("Player ended collision with NPC")
                        }
                    }
                }
            }
        }
    }

}
