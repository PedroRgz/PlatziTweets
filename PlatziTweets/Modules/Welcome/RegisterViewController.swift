//
//  RegisterViewController.swift
//  PlatziTweets
//
//  Created by Pedro Rodríguez on 30/06/21.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

class RegisterViewController: UIViewController {
    //MARK: -Outlets
    @IBOutlet weak var registerButton:UIButton!
    @IBOutlet weak var nombreTextField:UITextField!
    @IBOutlet weak var emailTextField:UITextField!
    @IBOutlet weak var passwordTextField:UITextField!
    @IBOutlet weak var repeatedPasswordTextField:UITextField!
    
    
    //MARK: -Actions
    @IBAction func registerBtnAction(){
        view.endEditing(true)
        performRegister()
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func setupUI(){
        //en este método se realizarán las modificaciones que se quieran realizar a la pantalla
        
        //para hacer el boton redondo
        registerButton.layer.cornerRadius = 25
    }
    
    private func performRegister(){
        guard let email = emailTextField.text, !email.isEmpty, email.contains("@") else {
            NotificationBanner(title: "Error",
                               subtitle: "Email inválido",
                               style: .warning).show()
            return
        }
        
        guard let name = nombreTextField.text, !name.isEmpty else {
            NotificationBanner(title: "Error",
                               subtitle: "Nombre inválido",
                               style: .warning).show()
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            NotificationBanner(title: "Error",
                               subtitle: "Contraseña inválida",
                               style: .warning).show()
            return
        }
        
        guard let passwordRptd = repeatedPasswordTextField.text, !passwordRptd.isEmpty else {
            NotificationBanner(title: "Error",
                               subtitle: "Reescriba su contraseña",
                               style: .warning).show()
            return
        }
        
        if password != passwordRptd {
            NotificationBanner(title: "Error",
                               subtitle: "La contraseña no coincide",
                               style: .warning).show()
            return
        }
        
        //realizamos el request
        let request = RegisterRequest(email: email, password: password, names: name)
        
        //Iniciamos la carga...
        SVProgressHUD.show()
        
        //Hacemos la llamada al servicio de red
        SN.post(endpoint: EndPoints.register,
                model: request) { (response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
            
            //detenemos la carga
            SVProgressHUD.dismiss()
            
            //debemos manejar los cases que hay para SNResultWithEntity
            switch response{
            case .success(let user):
                //Se pudo realizar el login
                self.performSegue(withIdentifier: "showHome", sender: user)
                
                DispatchQueue.main.async {
                    FloatingNotificationBanner(title: "Sesión Iniciada",
                                               subtitle: "Bienvenido \(user.user.names)",
                                               style: .success).show()
                }
                
            case .error(_):
                //se produce un error, no se puede manejar su componente
                NotificationBanner(title: "Error",
                                   subtitle: "Hubo un problema al intentar validarte",
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
