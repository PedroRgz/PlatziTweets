//
//  HomeViewController.swift
//  PlatziTweets
//
//  Created by Pedro Rodríguez on 01/07/21.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift
import AVKit

class HomeViewController: UIViewController {
    
    //MARK: -IBOutlets
    @IBOutlet weak var tableView:UITableView!
    
    //MARK: -Properties
    private let cellId = "TweetTableViewCell"
    private var dataSource = [Post]()
    
    //MARK: -App's lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getPosts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: - Override
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //este método será llamado cuando se haga una transición entre pantallas (solo con storyboards)
        //tenemos que validar que sea el segue que deseamos y se dirija a la pantalla que queremos
        
        //si el segue es el que deseamos y se puede crear una instancia de la pantalla que queremos, entonces...
        if segue.identifier == "showMap", let mapViewController = segue.destination as? MapViewController{
            //le pasamos los post que se han descargado para mostrar en la tabla, pero solo los que tienen ubicación
            mapViewController.posts = dataSource.filter{ $0.hasLocation }
        }
    }
    
    //MARK: - Private functions
    private func setupUI(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
    }
    
    private func getPosts(){
        //indicamos la carga
        SVProgressHUD.show()
        
        //llamada a la API
        SN.get(endpoint: EndPoints.getPost){(response: SNResultWithEntity<[Post], ErrorResponse>) in
            //termina la carga
            //SVProgressHUD.dismiss()
            
            switch response{
            case .success(let posts):
                self.dataSource = posts
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
                
            case .error(let error):
                //se produce un error, no se puede manejar su componente
                SVProgressHUD.dismiss()
                NotificationBanner(title: "Error",
                                   subtitle: "\(error.localizedDescription)",
                                   style: .danger).show()
            case .errorResult(let entity):
                SVProgressHUD.dismiss()
                //el error es manejable y devuelve una respuesta
                NotificationBanner(title: "Error",
                                   subtitle: "\(entity.error)",
                                   style: .danger).show()
            }
            
        }
    }
    
    private func deletePostAt(indexPath:IndexPath){
        //Indicar que se inicia la carga
        SVProgressHUD.show()
        
        //obtenemos el ID del post que se borrará
        let postId = dataSource[indexPath.row].id
        
        //preparar el endpoint que realizará la acción de borrar
        let endpoint = EndPoints.delete + postId
        
        //realizar la solicitud del servicio
        SN.delete(endpoint: endpoint) { (response: SNResultWithEntity<GeneralResponse, ErrorResponse>) in
            
            //termina la carga
            SVProgressHUD.dismiss()
            
            switch response{
            case .success:
                //Borrar el post del dataSource
                self.dataSource.remove(at: indexPath.row)
                
                //eliminar el tweet de la tabla
                self.tableView.deleteRows(at: [indexPath], with: .left)
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

//MARK: -UITableViewDataSource
extension HomeViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        if let cell = cell as? TweetTableViewCell{
            //Se realizará la configuración de la celda
            cell.setupCellWith(post: dataSource[indexPath.row])
            
            cell.needsToShowVideo={ url in
                //... Se ejecutará el ViewController que en la celda no se puede, por buena práctica
                //instanciamos el video
                let avPlayer = AVPlayer(url: url)
                //instanciamos el controlador que despliega la pantalla para reproducir el video
                let avPlayerController = AVPlayerViewController()
                avPlayerController.player = avPlayer
                
                self.present(avPlayerController, animated: true) {
                    //cuando se presente la pantalla, el video comenzará a reproducirse automáticamente
                    avPlayerController.player?.play()
                }
            }
        }
        
        return cell
    }
    
}

//MARK: -UITableViewDelegate
extension HomeViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowAction.Style.destructive, title: "Borrar") { _, _ in
            //codigo para borrar el tweet
            self.deletePostAt(indexPath: indexPath)
        }
        
        return [deleteAction]
    }
    
    
    //TODO: utilizar keychain para obtener el usuario y no darle la opción de editar la celda que no esté asociada a su email
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return dataSource[indexPath.row].author.email == "pedro.r@platzi.com"
    }
}
