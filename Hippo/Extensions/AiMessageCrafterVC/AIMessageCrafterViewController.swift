//
//  Untitled.swift
//  HippoAgent
//
//  Created by Neha on 25/03/25.
//  Copyright © 2025 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

struct AIChatOption {
    let label: String
    let value: Int
}

class AIMessageCrafterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var message = ""
    var channelId = 0
    var selectedLanguage = "English"
    
    var viewModel = AiMessageViewModel()
    var closeCallback: ((String)->())?
    var callback: ((String)->())?
    var summaryCallback: ((String)->())?
    
    private let options: [AIChatOption] = [
        AIChatOption(label: "Translate to...", value: 7),
        AIChatOption(label: "More concise", value: 3),
        AIChatOption(label: "My tone of voice", value: 1),
        AIChatOption(label: "More Friendly", value: 2),
        AIChatOption(label: "More Formal", value: 4),
        AIChatOption(label: "Rephrase", value: 5),
        AIChatOption(label: "Expand", value: 6),
        AIChatOption(label: "Fix grammar & spelling", value: 8),
        AIChatOption(label: "Summarize Conversation", value: 9)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let bundle = Bundle(for: AiMessageTableViewCell.self)
        let nib = UINib(nibName: "AiMessageTableViewCell", bundle: bundle)
        tableView.register(nib, forCellReuseIdentifier: "AiMessageTableViewCell")
        
        tableView.backgroundColor = .white
        isModalInPresentation = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AiMessageTableViewCell", for: indexPath) as! AiMessageTableViewCell
        
        let item = options[indexPath.row]
        cell.optionLabel.text = item.label
        cell.setData(value: item.value)
        
        let validMessage = hasMoreThanThreeLetters(message)
        
        if item.value == 7 {   // Translate cell
            cell.languageButton.alpha = validMessage ? 1.0 : 0.4
            cell.languageButton.tag = validMessage ? 1 : 0
            
            cell.languageButton.isUserInteractionEnabled = true
            
            cell.callback = { lang in
                self.selectedLanguage = lang
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let option = options[indexPath.row]
        
        // For ANY action except translate, message must be valid
        if option.value != 7 {
            if message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                showAlert(title: "", message: "Message is empty", actionComplete: nil)
                return
            }
            if !hasMoreThanThreeLetters(message) {
                showAlert(title: "", message: "Message should be more than 3 letters", actionComplete: nil)
                return
            }
        }
        
        // Option 1: Translate → use selectedLanguage
        if option.value == 7 {
            generateContent(contentType: 7, message: message, language: selectedLanguage)
            return
        }
        
        // Option 2: Summarize → custom handling
        if option.value == 9 {
            generateContent(contentType: 9, message: message, language: selectedLanguage)
            return
        }
        
        // Other AI operations
        generateContent(contentType: option.value,
                        message: message,
                        language: selectedLanguage)
    }
    
    func generateContent(contentType: Int, message: String, language: String) {
        
        let loader = UIActivityIndicatorView(style: .large)
        loader.center = view.center
        loader.startAnimating()
        view.addSubview(loader)
        
        viewModel.generateContent(contentType: contentType, message: message, language: language, channelId: channelId) { success, newMessage in
            
            loader.stopAnimating()
            loader.removeFromSuperview()
            
            if contentType == 1 {
                self.showAlert(title: "", message: "Your tone of message is \(newMessage)") { _ in
                    self.closeCallback?("")
                    self.dismiss(animated: true)
                }
                return
            }
            
            if contentType == 9 {
                self.summaryCallback?(newMessage)
                self.dismiss(animated: true)
                return
            }
            
            if success {
                self.callback?(newMessage)
                self.dismiss(animated: true)
            } else {
                self.showAlert(title: "", message: newMessage, actionComplete: nil)
            }
        }
    }
    
    
    func hasMoreThanThreeLetters(_ text: String) -> Bool {
        return text.filter { $0.isLetter }.count > 3
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        closeCallback?("")
        dismiss(animated: true)
    }
}
