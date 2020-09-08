//
//  ViewController.swift
//  Guess the Flag
//
//  Created by Chris Bata on 9/1/20.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    var scoreLabel: UILabel!
    var feedbackGenerator: UINotificationFeedbackGenerator? = nil
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var questionsAsked = 0
    let maxQuestions = 4
    var lastCountry = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreLabel = UILabel()
        scoreLabel.text = "Score: \(score)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Score: \(score)", style: .plain, target: self, action: .startOver)
        
//         without using a Selector extension
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Score: \(score)", style: .plain, target: self, action: #selector(self.clearScore))

        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1

        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor

        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "uk", "us"]
        
        feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator?.prepare()
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
        
//        appending score to title makes the text jump around too much since title is centered
//        title = countries[correctAnswer].uppercased() + "  Score: \(score)"
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
            let ac = UIAlertController(title: title, message: message + "Your final score is \(score) out of \(maxQuestions).\nStarting over.", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: startOver))
            present(ac, animated: true)

        } else {
            let ac = UIAlertController(title: title, message: message + "Your score is \(score)", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
            present(ac, animated: true)
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
}

extension Selector {
    static let clearScore = #selector(ViewController.clearScore)
    static let startOver = #selector(ViewController.startOver)
}

