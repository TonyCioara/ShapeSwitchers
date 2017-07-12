
import SpriteKit

enum GameSceneState {
    case active, gameOver
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: Player!
    
//    Turns true in touches began -- turns false in swipe. Used for taps
    var tap = false
    
//    Array with all obstacle possibilities -- created in createObstacleArray func
    var obstacleArray: [String] = []
    
//    Array with all passable obstacle types
    var obstaclePassArray: [String] = ["trianglePass", "circlePass", "squarePass", "allPass"]
    
//    Declaration of obstacle variables
    var nonePass: SKSpriteNode!
    var trianglePass: SKSpriteNode!
    var squarePass: SKSpriteNode!
    var circlePass: SKSpriteNode!
    var allPass: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
//    Declaration of ScrollLayer
    var scrollLayer: SKNode!
    
//    Declaration of scrollSpeed -- fixedDelta -- spawnTimer -- addToY
    let scrollSpeed: CGFloat = 100
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    var spawnTimer: CFTimeInterval = 0
    var addToY: CGFloat = 0
    var score = 0
    var contactMade = 0
    
//     Game management 
    var gameState: GameSceneState = .active
    
    override func didMove(to view: SKView) {
        
//        add reference - player
        player = childNode(withName: "//player") as? Player
        
//        add references - obstacles
        nonePass = childNode(withName: "//NonePass") as? SKSpriteNode
        trianglePass = childNode(withName: "//TrianglePass") as? SKSpriteNode
        squarePass = childNode(withName: "//SquarePass") as? SKSpriteNode
        circlePass = childNode(withName: "//CirclePass") as? SKSpriteNode
        allPass = childNode(withName: "//AllPass") as? SKSpriteNode
        scoreLabel = self.childNode(withName: "ScoreLabel") as! SKLabelNode
        
//         add reference - scrollLayer
        scrollLayer = self.childNode(withName: "scrollLayer")
        
//        Swipe gestures
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view?.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view?.addGestureRecognizer(swipeLeft)
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        scoreLabel.text = "\(score)"
        
//          obstacle possibility array func
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
                if player.lane.rawValue < 2 {
                    player.lane = Lane(rawValue: player.lane.rawValue + 1)!
                }
            case UISwipeGestureRecognizerDirection.left:
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
            
            switch player.shape {
            case .circle:
                player.shape = .square
                player.run(SKAction(named: "CircleToSquare")!)
            case .square:
                player.shape = .triangle
                player.run(SKAction(named: "SquareToTriangle")!)
            case .triangle:
                player.shape = .circle
                player.run(SKAction(named: "TriangleToCircle")!)
            }
        }
    }
 
    //    Update obstacles
    func updateObstacles() {
        
        scrollLayer.position.y -= scrollSpeed * CGFloat(fixedDelta)
        addToY += scrollSpeed * CGFloat(fixedDelta)
        
//        Spawn obstacles
        if spawnTimer >= 2.3 {
            createObstacle()
            spawnTimer = 0
        }
        
//         Loop through obstacle layer nodes
        for obstacle in scrollLayer.children as! [SKSpriteNode] {
            
//             Get obstacle node position, convert node position to scene space
            let obstaclePosition = scrollLayer.convert(obstacle.position, to: self)
            
//             Check if obstacle has left the scene
            if obstaclePosition.y <= -40 {
//                 Remove obstacle node from obstacle layer
                obstacle.removeFromParent()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        spawnTimer += fixedDelta
        updateObstacles()
//        Kill player
        if player.position.y < 0 {
            gameOver()
        } else if contactMade == 1 {
            score += 1
            contactMade = 0
//             Update score label 
            scoreLabel.text = String(score)
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
        
        addObstaclesToScene(currentObstacleArray: currentObstacleArray)
    }
    
    func addObstaclesToScene (currentObstacleArray: [String]) {
        var currentObstacle: String?
        for laneCount in 0...2 {
            
            // declare variable for shape as currentObstacleArray[laneCount]
            currentObstacle = currentObstacleArray[laneCount]
            
//            Check for shape in the array then copy the respective shape in-game
//            Set X position for the new obstacle to its repective lane
//            Set Y position to 700
            switch currentObstacle! {
            case "nonePass":
                let newObstacle = nonePass.copy() as! SKSpriteNode
                newObstacle.position.x = CGFloat(laneCount * 110 + 50)
                newObstacle.position.y = CGFloat(700 + addToY)
                scrollLayer.addChild(newObstacle)
            case "trianglePass":
                let newObstacle = trianglePass.copy() as! SKSpriteNode
                newObstacle.position.x = CGFloat(laneCount * 110 + 50)
                newObstacle.position.y = CGFloat(700 + addToY)
                scrollLayer.addChild(newObstacle)
            case "squarePass":
                let newObstacle = squarePass.copy() as! SKSpriteNode
                newObstacle.position.x = CGFloat(laneCount * 110 + 50)
                newObstacle.position.y = CGFloat(700 + addToY)
                scrollLayer.addChild(newObstacle)
            case "circlePass":
                let newObstacle = circlePass.copy() as! SKSpriteNode
                newObstacle.position.x = CGFloat(laneCount * 110 + 50)
                newObstacle.position.y = CGFloat(700 + addToY)
                scrollLayer.addChild(newObstacle)
            case "allPass":
                let newObstacle = allPass.copy() as! SKSpriteNode
                newObstacle.position.x = CGFloat(laneCount * 110 + 50)
                newObstacle.position.y = CGFloat(700 + addToY)
                scrollLayer.addChild(newObstacle)
            default:
                break
            }
        }
    }
    
    func gameOver() {
        player.run(SKAction(named: "PlayerDeath")!)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        contactMade = 1
    }
}
