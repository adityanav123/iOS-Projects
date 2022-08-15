//
//  ViewController.swift
//  TouchDeerGame
//
//  Created by Aditya Navphule on 06/08/22.
//

import UIKit

class ViewController: UIViewController {
    
    // labels
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var ScoreLabel: UILabel!
    @IBOutlet weak var GameMessageLabel: UILabel!
    @IBOutlet weak var HighscoreLabel: UILabel!
    
    // Images
    @IBOutlet weak var deer1: UIImageView!
    @IBOutlet weak var deer2: UIImageView!
    @IBOutlet weak var deer3: UIImageView!
    @IBOutlet weak var deer4: UIImageView!
    @IBOutlet weak var deer5: UIImageView!
    @IBOutlet weak var deer6: UIImageView!
    @IBOutlet weak var deer7: UIImageView!
    @IBOutlet weak var deer8: UIImageView!
    @IBOutlet weak var deer9: UIImageView!
    
    var score = 0
    var highscore = 0
    
    // Timer
    var timer = Timer()
    var countDownForGame = 0
    
    // animate deer
    var deerHideTimer = Timer()
    var deerArray = [UIImageView]() // Image array.
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ScoreLabel.text = "Score: \(score)"
        // retrieve high score
        let storeHighScore = UserDefaults.standard.object(forKey: "highscore")
        if storeHighScore == nil {
            highscore = 0
            HighscoreLabel.text = "Highscore: \(highscore)"
        }
        
        if let newScore = storeHighScore as? Int {
            highscore = newScore
            HighscoreLabel.text = "Highscorer: \(highscore)"
        }
        
        
        // enable touch sensation in the images
        deer1.isUserInteractionEnabled = true
        deer2.isUserInteractionEnabled = true
        deer3.isUserInteractionEnabled = true
        deer4.isUserInteractionEnabled = true
        deer5.isUserInteractionEnabled = true
        deer6.isUserInteractionEnabled = true
        deer7.isUserInteractionEnabled = true
        deer8.isUserInteractionEnabled = true
        deer9.isUserInteractionEnabled = true
        
        // generate the gesture recognizer
        let recognizer_deer1 = UITapGestureRecognizer(target: self, action: #selector(increaseScore))
        let recognizer_deer2 = UITapGestureRecognizer(target: self, action: #selector(increaseScore))
        let recognizer_deer3 = UITapGestureRecognizer(target: self, action: #selector(increaseScore))
        let recognizer_deer4 = UITapGestureRecognizer(target: self, action: #selector(increaseScore))
        let recognizer_deer5 = UITapGestureRecognizer(target: self, action: #selector(increaseScore))
        let recognizer_deer6 = UITapGestureRecognizer(target: self, action: #selector(increaseScore))
        let recognizer_deer7 = UITapGestureRecognizer(target: self, action: #selector(increaseScore))
        let recognizer_deer8 = UITapGestureRecognizer(target: self, action: #selector(increaseScore))
        let recognizer_deer9 = UITapGestureRecognizer(target: self, action: #selector(increaseScore))
        
        // add gesture to image.
        deer1.addGestureRecognizer(recognizer_deer1)
        deer2.addGestureRecognizer(recognizer_deer2)
        deer3.addGestureRecognizer(recognizer_deer3)
        deer4.addGestureRecognizer(recognizer_deer4)
        deer5.addGestureRecognizer(recognizer_deer5)
        deer6.addGestureRecognizer(recognizer_deer6)
        deer7.addGestureRecognizer(recognizer_deer7)
        deer8.addGestureRecognizer(recognizer_deer8)
        deer9.addGestureRecognizer(recognizer_deer9)
        
        // animate deer
        deerArray = [deer1, deer2, deer3, deer4, deer5, deer6, deer7, deer8, deer9]
        
        
        
        // timer code
        countDownForGame = 10
        TimeLabel.text = "\(countDownForGame)"
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(repeatTheGame), userInfo: nil, repeats: true)
        deerHideTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(hideDeer), userInfo: nil, repeats: true)
       
        hideDeer() // hide all deers initially.
    }

        
    @objc func increaseScore() {
        score += 1
        ScoreLabel.text = "Score: \(score)"
    }
    
    
    @objc func repeatTheGame() {
        countDownForGame-=1
        TimeLabel.text = "\(countDownForGame)"
        
        if countDownForGame == 0 {
            timer.invalidate() // break the timer
            deerHideTimer.invalidate() // break the animation
            
            for deer_image in deerArray {
                deer_image.isHidden = true
            }
            
            if self.highscore < self.score {
                self.highscore = self.score
                HighscoreLabel.text = "Highscore: \(self.highscore)"
                // Save to Device
                UserDefaults.standard.set(self.highscore, forKey: "highscore")
            }
            
            
            
            TimeLabel.text = "time over"
            
            let exitAlert = UIAlertController(title: "Game Over", message: "Your Score is: \(score)", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "exit", style: UIAlertAction.Style.cancel, handler: nil)
            let replayButton = UIAlertAction(title: "replay", style: UIAlertAction.Style.default) { (UIAlertAction) in
                print("player wants to play again")
                // replay function
                self.score = 0
                self.ScoreLabel.text = "Score: \(self.score)"
                self.countDownForGame = 10
                self.TimeLabel.text = "\(self.countDownForGame)"
                
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.repeatTheGame), userInfo: nil, repeats: true)
                self.deerHideTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.hideDeer), userInfo: nil, repeats: true)
                
            }
            // add button to alert
            exitAlert.addAction(okButton)
            exitAlert.addAction(replayButton)
            
            self.present(exitAlert, animated: true, completion: nil)
            
        }
    }
    
    
    @objc func hideDeer() {
        for deer_image in deerArray {
            deer_image.isHidden = true
        }
        let random_deer = Int(arc4random_uniform(UInt32(deerArray.count - 1))) // 0 - 8 randomly
        deerArray[random_deer].isHidden = false // deer visible
    }

}

