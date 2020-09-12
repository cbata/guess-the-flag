//
//  ViewController.swift
//  Guess the Flag
//
//  Created by Chris Bata on 9/1/20.
//

import UIKit
import GameKit

class ViewController: UIViewController, GKGameCenterControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var gameCenterButton: UIButton!
    var scoreLabel: UILabel!
    var feedbackGenerator: UINotificationFeedbackGenerator? = nil
    
    var countries = [String]()
    var score: Int64 = 0
    var correctAnswer = 0
    var questionsAsked = 0
    let maxQuestions = 4
    var lastCountry = ""
    var leaderboards = [GKLeaderboard]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreLabel = UILabel()
        scoreLabel.text = "Score: \(score)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Score: \(score)", style: .plain, target: self, action: .startOver)
        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1

        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor

        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "uk", "us"]
        
        feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator?.prepare()
        
        gameCenterButton.isEnabled = false
        
        authenticateLocalPlayer()
                
        askQuestion()
    }
    
    func askQuestion(action: UIAlertAction! = nil) {
        questionsAsked += 1
        
        repeat {
            countries.shuffle()
            correctAnswer = Int.random(in: 0...2)
        } while lastCountry == countries[correctAnswer]
        
        lastCountry = countries[correctAnswer]
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        title = countries[correctAnswer].uppercased()

        navigationItem.rightBarButtonItem?.title = "Score: \(score)"
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        var message = ""
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
            feedbackGenerator?.notificationOccurred(.success)
        } else {
            title = "Wrong"
            message = "That's the flag of \(countries[sender.tag].uppercased())\n"
            feedbackGenerator?.notificationOccurred(.error)
        }
        
        if questionsAsked == maxQuestions {
            reportScore(score: score)
            
            GKNotificationBanner.show(withTitle: title, message: message + "Your final score is \(score) out of \(maxQuestions). Starting over.", duration: 1, completionHandler: {
                self.startOver()
            })
        } else {
            GKNotificationBanner.show(withTitle: title, message: message + "Your score is \(score)", duration: 0.75, completionHandler: {
                self.askQuestion()
            })
        }
    }
    
    @objc func clearScore(action: UIAlertAction! = nil) {
        score = 0
        questionsAsked = 0
        navigationItem.rightBarButtonItem?.title = "Score: \(score)"
    }
    
    @objc func startOver(action: UIAlertAction! = nil) {
        clearScore()
        askQuestion()
    }
    
    @IBAction func openGameCenter(_ sender: Any) {
        let gc = GKGameCenterViewController()
        gc.delegate = self
        
        present(gc, animated: true, completion: nil)
    }
    
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = { (vc: UIViewController?, error: Error?) -> Void in
            if let viewController = vc {
                self.showAuthenticationViewController(viewController)
            } else if localPlayer.isAuthenticated {
                self.gameCenterButton.isEnabled = true
            } else {
                self.disableGameCenter()
            }
        }
            
    }
    
    func authenticateHandler(vc: UIViewController?, error: Error?) -> Void {
        
    }
    
    func showAuthenticationViewController(_ vc: UIViewController) {
        present(vc, animated: true, completion: nil)
    }
    
    func disableGameCenter() {
        gameCenterButton.isEnabled = false
    }
    
    @IBAction func showLeaderboard(_ sender: Any) {
        GKLeaderboard.loadLeaderboards(completionHandler: { leaderboards, error in
            let gameCenterController = GKGameCenterViewController()
            gameCenterController.gameCenterDelegate = self
            gameCenterController.viewState = .leaderboards;
            gameCenterController.leaderboardTimeScope = .today;
            gameCenterController.leaderboardIdentifier = "firstLeaderboardID"
            self.present(gameCenterController, animated: true, completion:nil)
        })
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func reportScore(score: Int64) {
        let scoreReporter = GKScore(leaderboardIdentifier: "firstLeaderboardID")
        scoreReporter.value = score
        scoreReporter.context = 0
        
        GKScore.report([scoreReporter], withCompletionHandler: { error in
            if let error = error {
                print("error reporting score \(error)")
            }
        })
    }
}

extension Selector {
    static let clearScore = #selector(ViewController.clearScore)
    static let startOver = #selector(ViewController.startOver)
}

