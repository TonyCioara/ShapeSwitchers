
import SpriteKit

//  Enum lanes
enum Lane: Int {
    case left = 0,
    center = 1,
    right = 2
}

//  Enum shapes
enum Shape {
    case circle, square, triangle
}

class Player: SKSpriteNode {
    
//    Setup animations
    
//    Set up lanes
    var lane: Lane = .center {
        didSet {
            if lane == .left {
                position.x = -110
            } else if lane == .center {
                position.x = 0
            } else {
                position.x = 110
            }
        }
    }
    
//    Set up shapes
    var shape: Shape = .circle {
        didSet {
            if shape == .circle {
                self.physicsBody?.collisionBitMask = 1
                self.physicsBody?.contactTestBitMask = 1
            } else if shape == .square {
                self.physicsBody?.collisionBitMask = 1
                self.physicsBody?.contactTestBitMask = 1
            } else {
                self.physicsBody?.collisionBitMask = 1
                self.physicsBody?.contactTestBitMask = 1
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
