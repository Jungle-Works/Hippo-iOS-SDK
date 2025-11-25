//
//  Untitled.swift
//  HippoAgent
//
//  Created by Neha on 25/03/25.
//  Copyright © 2025 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit


// MARK: - Struct
struct AIChatOption {
    let label: String
    let value: Int
}

// MARK: - AIMessageCrafterViewController

class AIMessageCrafterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Variables
    
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
      //  ,AIChatOption(label: "Summarize Ticket", value: 10)
    ]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        isModalInPresentation = true
        let bundle = Bundle(for: AiMessageTableViewCell.self)
        let nib = UINib(nibName: "AiMessageTableViewCell", bundle: bundle)
        tableView.register(nib, forCellReuseIdentifier: "AiMessageTableViewCell")
        tableView.backgroundColor = .white
        }
    
    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AiMessageTableViewCell", for: indexPath) as! AiMessageTableViewCell
        cell.setData(value: options[indexPath.row].value)
        cell.optionLabel?.text = options[indexPath.row].label
        if self.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !hasMoreThanThreeLetters(self.message) {
            cell.languageButton.isUserInteractionEnabled = false
        } else {
            cell.languageButton.isUserInteractionEnabled = true
        }
        cell.callback = { language in
            print(language)
            self.selectedLanguage = language
            self.generateContent(contentType: 7, message: self.message, language: language)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            return
        }
        if indexPath.row == options.count - 1 {
            let selectedOption = options[indexPath.row]
            self.generateContent(contentType: selectedOption.value, message: self.message, language: self.selectedLanguage)
            return
        }

        if message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.showAlert(title: "", message: "Message is empty", actionComplete: nil)
            return
        } else if !hasMoreThanThreeLetters(message) {
            self.showAlert(title: "", message: "Message should be more than 3 letters", actionComplete: nil)
            return
        }
        let selectedOption = options[indexPath.row]
        self.generateContent(contentType: selectedOption.value, message: self.message, language: self.selectedLanguage)

    }
    
    // MARK: - Api
    
    func generateContent(contentType: Int, message:String, language:String){
        let loader = UIActivityIndicatorView(style: .large)
            loader.center = self.view.center
            loader.startAnimating()
            self.view.addSubview(loader)
            
        viewModel.generateContent(contentType: contentType, message:message, language:language, channelId: channelId) { success, newMessage in
            loader.stopAnimating()
            if contentType == 1 {
                self.showAlert(title: "", message: "Your tone of message is \(newMessage)") {action in 
                      self.closeCallback?("")
                      self.dismiss(animated: true, completion: nil)
                  }
                   
            } else if contentType == 9 {
                self.summaryCallback?(newMessage)
                self.dismiss(animated: true, completion: nil)
            } else{
                if success {
                    self.callback?(newMessage)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showAlert(title: "", message: "\(newMessage)", actionComplete: nil)
                }
            }
        }
    }
    
    func hasMoreThanThreeLetters(_ text: String) -> Bool {
        let letters = text.filter { $0.isLetter }
        return letters.count > 3
    }
    
    
    // MARK: - Actions
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.closeCallback?("")
        dismiss(animated: true, completion: nil)
    }
}



