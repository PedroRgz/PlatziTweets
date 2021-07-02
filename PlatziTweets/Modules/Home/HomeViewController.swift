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

class HomeViewController: UIViewController {
    
    //MARK: -IBOutlets
    @IBOutlet weak var tableView:UITableView!

    //MARK: -Properties
    private let cellId = "TweetTableViewCell"
    private var dataSource = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        getPosts()
    }
    
    private func setupUI(){
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
    }
    
    private func getPosts(){
        //indicamos la carga
        SVProgressHUD.show()
        
        //llamada a la API
        SN.get(endpoint: EndPoints.getPost){(response: SNResultWithEntity<[Post], ErrorResponse>) in
            //termina la carga
            SVProgressHUD.dismiss()
            
            switch response{
            case .success(let posts):
                self.dataSource = posts
                self.tableView.reloadData()
                
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
        }
        
        return cell
    }
}
