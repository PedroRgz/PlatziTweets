//
//  RegisterViewController.swift
//  PlatziTweets
//
//  Created by Pedro Rodríguez on 30/06/21.
//

import UIKit

class RegisterViewController: UIViewController {
    //MARK: -Outlets
    @IBOutlet weak var registerButton:UIButton!
    
    
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
}
