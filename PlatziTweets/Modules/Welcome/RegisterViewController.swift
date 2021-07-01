//
//  RegisterViewController.swift
//  PlatziTweets
//
//  Created by Pedro Rodríguez on 30/06/21.
//

import UIKit
import NotificationBannerSwift

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
    
    
    /*
     TODO:
     Agregar los textfiel y action al botón
     separar la acción en un metodo a parte para el action
     mostrar el banner de error en caso de que el textfield esté vació
     agregar banner para eventos en la contraseña
     agregar banner para evento de login
     */

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
        
        performSegue(withIdentifier: "showHome", sender: nil)
    }
}
