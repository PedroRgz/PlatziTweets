//
//  AddPostViewController.swift
//  PlatziTweets
//
//  Created by Pedro Rodríguez on 02/07/21.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift

class AddPostViewController: UIViewController {
    
    //MARK: -IBOutlests
    @IBOutlet weak var newTweetTextView:UITextView!
    
    //MARK: -IBActions
    @IBAction func addPostAction(){
        savePost()
    }
    
    @IBAction func dismissTweet(){
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func savePost(){
        //validar que el campo de texto no esté vacío
        guard let newTweet = newTweetTextView.text,
              !newTweet.isEmpty else {
            NotificationBanner(title: "Campo vacío",
                               subtitle: "Ingresa un nuevo tweet 😄",
                               style: .warning).show()
            return
        }
        
        //Crear request
        let request = PostRequest(text: newTweet, imageUrl: nil, videoUrl: nil, location: nil)
        
        //indicar la carga
        SVProgressHUD.show()
        
        //llamada al servicio del post
        SN.post(endpoint: EndPoints.post,
                model: request) { (response: SNResultWithEntity<Post, ErrorResponse>) in
            //cerrar indicador de carga
            SVProgressHUD.dismiss()
            
            //implementar el switch de los casos posibles de recibir
            switch response{
            case .success:
                //si la acción fue exitosa, la pantalla solamente se cerrará
                self.dismiss(animated: true, completion: nil)
                
            case .error(let error):
                //se produce un error, no se puede manejar su componente
                NotificationBanner(title: "Error",
                                   subtitle: "\(error.localizedDescription)",
                                   style: .danger).show()
            case .errorResult(let entity):
                //el error es manejable y devuelve una respuesta
                NotificationBanner(title: "Error",
                                   subtitle: "\(entity.error)",
                                   style: .danger).show()
            }
        }
    }
}
