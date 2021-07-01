//
//  LoginViewController.swift
//  PlatziTweets
//
//  Created by Pedro Rodríguez on 30/06/21.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

class LoginViewController: UIViewController {
    //MARK: -Outlets
    @IBOutlet weak var loginButton:UIButton!
    @IBOutlet weak var emailTextField:UITextField!
    @IBOutlet weak var passwordTextField:UITextField!
    
    //MARK: -Actions
    @IBAction func loginBtnAction(){
        view.endEditing(true)
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
        
        
        //Primer debemos realizar el request
        let request = LoginRequest(email: email, password: password)
        
        //Iniciamos la carga
        SVProgressHUD.show()
        
        //Llamada a la libreria de red
        SN.post(endpoint: EndPoints.login,
                model: request) { (response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
            
            //detenemos la carga
            SVProgressHUD.dismiss()
            
            //debemos manejar los cases que hay para SNResultWithEntity
            switch response{
            case .success(let user):
                //Se pudo realizar el login
                NotificationBanner(subtitle: "Bienvenido \(user.user.names)",
                                   style: .success).show()
                
            case .error(let error):
                //se produce un error, no se puede manejar su componente
                return
            case .errorResult(let entity):
                //el error es manejable y devuelve una respuesta
                return
            }
        }
        
        
        //performSegue(withIdentifier: "showHome", sender: nil)
        
    }

}
