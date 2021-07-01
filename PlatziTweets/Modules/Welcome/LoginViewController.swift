//
//  LoginViewController.swift
//  PlatziTweets
//
//  Created by Pedro Rodríguez on 30/06/21.
//

import UIKit
import NotificationBannerSwift

class LoginViewController: UIViewController {
    //MARK: -Outlets
    @IBOutlet weak var loginButton:UIButton!
    @IBOutlet weak var emailTextField:UITextField!
    @IBOutlet weak var passwordTextField:UITextField!
    
    //MARK: -Actions
    @IBAction func loginBtnAction(){
        performLogin()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    
    //MARK: - Métodos privados
    private func setupUI(){
        //en este método se realizarán las modificaciones que se quieran realizar a la pantalla
        
        //para hacer el boton redondo
        loginButton.layer.cornerRadius = 25
    }
    
    private func performLogin(){
        guard let email = emailTextField.text,
                          !email.isEmpty,
                          email.contains("@") else {
            NotificationBanner(title: "Error",
                               subtitle: "Email inválido",
                               style: .warning).show()
            
            return
        }
        
        guard let password = passwordTextField.text,
                             !password.isEmpty else {
            NotificationBanner(title: "Error",
                               subtitle: "Ingresa tu contraseña",
                               style: .warning).show()
            return
        }
        
    }

}
