//
//  AddPostViewController.swift
//  PlatziTweets
//
//  Created by Pedro Rodríguez on 02/07/21.
//

import UIKit

class AddPostViewController: UIViewController {
    
    //MARK: -IBOutlests
    @IBOutlet weak var newTweetTextView:UITextView!
    
    //MARK: -IBActions
    @IBAction func addPostAction(){
        
    }
    
    @IBAction func dismissTweet(){
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
