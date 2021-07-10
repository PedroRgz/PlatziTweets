
//IMPORTANTE
//LAS CELDAS NUNCA DEBEN INVOCAR VIEWCONTROLLERS -> tendremos que avisarle a la tabla que debe abrir un video

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
    
    //MARK: -IBActions
    @IBAction func openVideoAction(){
        guard let videoUrl = videoUrl else {
            return
        }
        
        needsToShowVideo?(videoUrl)
    }
    
    //MARK: -Properties
    private var videoUrl:URL?
    var needsToShowVideo:((_ url:URL) -> Void)? //será una función opcional que se ejecuta en el controlador de la tabla

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
        
        videoButton.isHidden = !post.hasVideo
        videoUrl = URL(string: post.videoUrl)
        
        if post.hasImage{
            //configurar imagen
            imageImageView.isHidden = false
            imageImageView.kf.setImage(with: URL(string: post.imageUrl))
        }else{
            imageImageView.isHidden = true
        }
    }
    
}
