//
//  MapViewController.swift
//  PlatziTweets
//
//  Created by Pedro Rodríguez on 07/07/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    //MARK: -IBOutlets
    @IBOutlet weak var mapContainer:UIView!
    
    //MARK: -Properties
    var posts = [Post]()
    private var map:MKMapView?

    //MARK: -App's Lifecylcle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
         aquí llamaremos al metodo en donde se configura el mapa, ya que cuando asignamos medidas
         de las vistas a través del código, estas pueden ser influenciadas por el ciclo de vida
         en el que se encuentra la app... por esto, es mejor asignar estas llamadas en el ciclo de DidApper
         */
        
        setupMap()
    }
    
    //MARK: -Private Methods
    private func setupMap(){
        //instanciamos las clase de mapKit
        //es necesario delimitar el tamaño de nuestro mapa, para eso utilizamos la referencia al view que lo contendrá
        map = MKMapView(frame: mapContainer.bounds)
        
        //ahora agregamos la subview a la view -> nuestro mapa instanciado
        mapContainer.addSubview(map ?? UIView()) //no pueden pasar parámetros opcionales
        
        setupMarkers()
    }
    
    private func setupMarkers(){
        posts.forEach { item in
            let marker = MKPointAnnotation() //nos servirá para poner el marcador en el mapa
            marker.coordinate = CLLocationCoordinate2D(latitude: item.location.latitude,
                                                       longitude: item.location.longitude)
            
            //agremamos detalles al marcador
            marker.title = item.text
            marker.subtitle = item.author.names
            
            //agregamos el marcador a nuestro mapa
            map?.addAnnotation(marker)
        }
        
        //personalizamos la vista que tendrá el mapa... mostraremos el dónde fue publicado el último tweet
        guard let newestTweet = posts.first else {
            return
        }
        
        let newestPostLocation = CLLocationCoordinate2D(latitude: newestTweet.location.latitude,
                                                        longitude: newestTweet.location.longitude)
        
        //como buena práctica, daremos valor a uno de los parámetros opcionales a través del guard
        guard let headingForMapCamera = CLLocationDirection(exactly: 12) else {
            return
        }
        
        //asignamos la vista inicial del mapa
        map?.camera = MKMapCamera(lookingAtCenter: newestPostLocation,
                                  fromDistance: 70,
                                  pitch: .zero,
                                  heading: headingForMapCamera)
    }

}
