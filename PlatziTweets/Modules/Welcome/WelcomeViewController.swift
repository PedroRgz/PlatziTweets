//
//  WelcomeViewController.swift
//  PlatziTweets
//
//  Created by Pedro Rodríguez on 30/06/21.
//

import UIKit

class WelcomeViewController: UIViewController {
    //MARK: -Outlets
    @IBOutlet weak var loginButton:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        //aquí es donde debe llamarse a la configuración de la pantalla
        setupUI()
        
    }
    
    private func setupUI(){
        //en este método se realizarán las modificaciones que se quieran realizar a la pantalla
        
        //para hacer el boton redondo
        loginButton.layer.cornerRadius = 25
    }

}
