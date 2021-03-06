//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Christopher Mena on 3/5/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetTableViewCell
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)
        let screenName = "@" + (user["screen_name"] as? String ?? "")
        
        //let rtCound = tweetArray[indexPath.row]["retweet_count"] as? Int ?? 0
        //let fvCount = tweetArray[indexPath.row]["favorite_count"] as? Int ?? 0
        cell.userNameLabel.text = user["name"] as? String
        cell.tweetContentLabel.text = tweetArray[indexPath.row]["text"] as? String
        cell.tweetContentLabel.sizeToFit()
        cell.screenNameLabel.text = screenName
        //cell.retweetCountLabel.text = "\(rtCound)"
        //cell.favoriteCountLabel.text = "\(fvCount)"
        let data = try? Data(contentsOf: imageUrl!)
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width / 2
            cell.profileImageView.clipsToBounds = true
        }
        
        //Favoited
        cell.setFavorite(tweetArray[indexPath.row]["favorited"] as? Bool ?? false)
        cell.tweetId = tweetArray[indexPath.row]["id"] as? Int ?? -1
        //Retweeted
        cell.setRetweeted(tweetArray[indexPath.row]["retweeted"] as? Bool ?? false)
        return cell
    }
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let myRefreshControl = UIRefreshControl()
    
    var tweetArray = [NSDictionary]()
    var numberOfTweets: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Calling viewDidAppear")
        self.loadTweets()
    }
    
    func updateUI() {
        let param = ["include_entities":false]
        TwitterAPICaller.client?.getCredentials(parameters: param, success: { (user: NSDictionary) in
            let imageUrl = URL(string: user["profile_image_url_https"] as? String ?? "")
            let data = try? Data(contentsOf: imageUrl!)
            if let imageData = data {
                self.profileImageView.image = UIImage(data: imageData)
                self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
                self.profileImageView.clipsToBounds = true
                self.nameLabel.text = user["name"] as? String ?? ""
                self.descriptionLabel.text = user["description"] as? String ?? ""
                self.usernameLabel.text = "@\(user["screen_name"] as? String ?? "")"
                self.getBannerImage(user["id"] as? Int ?? 0)
            }
        }, failure: { (error) in
            print(error)
        })
    }
    
    func getBannerImage(_ name: Int) {
        let param = ["user_id": name]
        TwitterAPICaller.client?.getBannerImage(parameters: param, success: { (images: NSDictionary) in
            let sizes = images["sizes"]! as! NSDictionary
            let retina = sizes["mobile_retina"] as! NSDictionary
            let imageUrl = URL(string: retina["url"] as? String ?? "")
            let data = try? Data(contentsOf: imageUrl!)
            if let imageData = data {
                self.bannerImageView.image = UIImage(data: imageData)
            }
            
        }, failure: { (error) in
            print("Could not load images")
        })
    }
    
    //Pull tweets
    @objc func loadTweets() {
        print("In loadstweets")
        numberOfTweets = 20
        let myParams = ["count": numberOfTweets!]
        // Call API
        TwitterAPICaller.client?.getUserTweets(parameters: myParams, success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
        }, failure: { (error) in
            print(error)
        })
    }
    
    // Infinite scroll, load more tweets
    func loadMoreTweets() {
        numberOfTweets += 20
        let myParams = ["count": numberOfTweets!]
        //Call API
        TwitterAPICaller.client?.getUserTweets(parameters: myParams, success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            print(tweets)
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
        }, failure: { (Error) in
            print("Failed to get more tweets")
        })
    }
}
