//
//  TweetViewController.swift
//  Twitter
//
//  Created by Christopher Mena on 3/5/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var wordCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Text View properties
        tweetTextView.delegate = self
        tweetTextView.becomeFirstResponder()
        updateUI()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func tweetButtonPressed(_ sender: UIBarButtonItem) {
        if (!tweetTextView.text.isEmpty) {
            TwitterAPICaller.client?.postTweet(tweetString: tweetTextView.text, success: {
                self.dismiss(animated: true, completion: nil)
            }, failure: { (error) in
                print("Error posting tweet \(error)")
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    

}

extension TweetViewController {
    //Stubs
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= 280
    }
    func textViewDidChange(_ textView: UITextView) {
        wordCountLabel.text = String(textView.text.count)
    }
}

extension TweetViewController {
    //Functions
    func updateUI() {
        tweetTextView.layer.borderWidth = 1
        tweetTextView.layer.borderColor = UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 1).cgColor
        tweetTextView.layer.cornerRadius = 15
        wordCountLabel.text = "0"
        getImage()
    }
    
    func getImage() {
        let param = ["include_entities":false]
        TwitterAPICaller.client?.getCredentials(parameters: param, success: { (user: NSDictionary) in
            let imageUrl = URL(string: user["profile_image_url_https"] as? String ?? "")
            let data = try? Data(contentsOf: imageUrl!)
            if let imageData = data {
                self.profileImageView.image = UIImage(data: imageData)
                self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
                self.profileImageView.clipsToBounds = true
            }
        }, failure: { (error) in
            print(error)
        })
    }
}
