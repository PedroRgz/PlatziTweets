//
//  TweetTableViewCell.swift
//  PlatziTweets
//
//  Created by Pedro Rodríguez on 01/07/21.
//

import UIKit
import Kingfisher

class TweetTableViewCell: UITableViewCell {
    
    //MARK: -IBOutlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var imageImageView: UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var daleLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCellWith(post:Post){
        nameLabel.text = post.author.names
        nicknameLabel.text = post.author.nickname
        messageLabel.text = post.text
        
        if post.hasImage{
            //configurar imagen
            imageImageView.kf.setImage(with: URL(string: post.imageUrl))
        }else{
            imageImageView.isHidden = true
        }
    }
    
}
