
import SpriteKit

enum ObstacleType: Int {
    case nonePass = 1,
    trianglePass = 2,
    circlePass = 3,
    squarePass = 4,
    allPass = 5
}
class GameScene: SKScene {
    
    var player: Player!
    
//    Turns true in touches began -- turns false in swipe. Used for taps
    var tap = false
    
//    Array with all obstacle possibilities -- created in createObstacleArray func
    var obstacleArray: [String] = []
    
//    Array with all passable obstacle types
    var obstaclePassArray: [String] = ["trianglePass", "circlePass", "squarePass", "allPass"]
    
//   Swipe gestures
    override func didMove(to view: SKView) {
        
        player = childNode(withName: "//player") as? Player
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view?.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view?.addGestureRecognizer(swipeLeft)
        
//          calle obstacle possibility array func
        createObstacleArray()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tap = true
    }
    
//    Change lanes (swipe)
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            tap = false
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                if player.lane.rawValue < 2 {
                    player.lane = Lane(rawValue: player.lane.rawValue + 1)!
                }
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                if player.lane.rawValue > 0 {
                    player.lane = Lane(rawValue: player.lane.rawValue - 1)!
                }
            default:
                break
            }
        }
    }
    
//    Taps if swipe function wasn't called after TouchesBegan
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if tap == true {
            
            createObstacle() // Test 
            
            switch player.shape {
            case .circle:
                player.shape = .square
                player.run(SKAction(named: "CircleToSquare")!)
                print ("changed shape to square")
            case .square:
                player.shape = .triangle
                player.run(SKAction(named: "SquareToTriangle")!)
                print ("changed shape to triangle")
            case .triangle:
                player.shape = .circle
                player.run(SKAction(named: "TriangleToCircle")!)
                print ("changed shape to circle")
            }
        }
    }
    
//    Create Array -- contains all the possible obstacles
    func createObstacleArray () {
        
//        Create array with all obstacle possiblities
//        % of solid obstacles
        for _ in 1...76 {
            obstacleArray.append ("nonePass")
        }
//        % of triangle gates
        for _ in 1...6 {
            obstacleArray.append("trianglePass")
        }
//        % of circle gates
        for _ in 1...6 {
            obstacleArray.append("circlePass")
        }
//        % of square gates
        for _ in 1...6 {
            obstacleArray.append("squarePass")
        }
//        % of empty gates
        for _ in 1...6 {
            obstacleArray.append("allPass")
        }
    }
    
//    Create 3 obstacles (1 row)
    func createObstacle () {
        
//        Array containing 3 obstacles
        var currentObstacleArray: [String] = []
        
//        Assigns 3 random values to currentObstacleArray from obstacleArray
        for _ in 1...3 {
             let rand1 = Int(arc4random_uniform(100))
            currentObstacleArray.append (obstacleArray[rand1])
        }
        
//        If 3 obstacles are the same replace 1 with a member of obstaclePassArray
        if currentObstacleArray[0] == currentObstacleArray[1] && currentObstacleArray[0] == currentObstacleArray[2] {
            let rand2 = Int(arc4random_uniform(3))
            let rand3 = Int(arc4random_uniform(4))
            currentObstacleArray[rand2] = obstaclePassArray[rand3]
        }
        
//        Test
        for currentObstacleArr in currentObstacleArray {
            print ("\(currentObstacleArr) ")
        }
    }
}
