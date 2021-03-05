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
        tweetTextView.layer.borderWidth = 1
        tweetTextView.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1).cgColor
        wordCountLabel.text = "0"
        //getImage()
        credentials()
    }
    
    func getImage() {
        let imageUlr = UserDefaults.standard.url(forKey: "imageURL") ?? URL(string: "")
        let data = try? Data(contentsOf: imageUlr!)
        if let imageData = data {
            profileImageView.image = UIImage(data: imageData)
            profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
            profileImageView.clipsToBounds = true
        }
    }
    
    func credentials() {
        let param = ["include_entities":false]
        TwitterAPICaller.client?.getCredentials(parameters: param, success: { (user: NSDictionary) in
            print(user["id"])
        }, failure: { (error) in
            print(error)
        })
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TweetViewController {
    func textLimit(existingText: String?, newText: String, limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        return isAtLimit
    }
    //Stubs
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= 280 // Change limit based on your requirement.
    }
    func textViewDidChange(_ textView: UITextView) {
        wordCountLabel.text = String(textView.text.count)
    }
}
