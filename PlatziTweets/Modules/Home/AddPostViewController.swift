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
import FirebaseStorage
//las siguiente librerias son para trabajar con el reproductor de video
import AVFoundation
import AVKit
import MobileCoreServices
import CoreLocation

class AddPostViewController: UIViewController {
    
    //MARK: -IBOutlests
    @IBOutlet weak var newTweetTextView:UITextView!
    @IBOutlet weak var previewImageView:UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    
    //MARK: -IBActions
    @IBAction func openCameraAction() {
        //creamos la alerta para permitirle al usuario seleccionar entre subir un video o imagen
        let alert = UIAlertController(title: "Cámara",
                                      message: "Selecciona una opción",
                                      preferredStyle: UIAlertController.Style.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Foto", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { _ in
            self.openVideoCamera()
        }))
        
        //opcion para cancelar y pueda salir del selector
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func openVideoPreviewAction() {
        guard let recordedVideoUrl = currentVideoUrl else {
            return
        }
        
        //instanciamos el video
        let avPlayer = AVPlayer(url: recordedVideoUrl)
        //instanciamos el controlador que despliega la pantalla para reproducir el video
        let avPlayerController = AVPlayerViewController()
        avPlayerController.player = avPlayer
        
        present(avPlayerController, animated: true) {
            //cuando se presente la pantalla, el video comenzará a reproducirse automáticamente
            avPlayerController.player?.play()
        }
    }
    
    @IBAction func addPostAction(){
        uploadMediaToFirebase(thereIsVideo: !videoButton.isHidden, thereIsImage: !previewImageView.isHidden)
    }
    
    @IBAction func dismissTweet(){
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Properties
    private var imagePicker:UIImagePickerController?
    //private var downloadUrlImageFromFirebase:String?
    private var currentVideoUrl:URL?
    private var downloadVideoUrl:String?
    private var downloadImageUrl:String?
    //propiedades para manejar la ubicación
    private var locationManager:CLLocationManager?
    private var userLocation:CLLocation?

    //MARK: - App's Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoButton.isHidden = true
        requestLocation()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    
    //MARK: - Private methods
    private func openCamera(){
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .photo
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagePicker = imagePicker else {
            return
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func openVideoCamera(){
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.mediaTypes = [kUTTypeMovie as String]
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .video
        imagePicker?.videoQuality = .typeMedium
        imagePicker?.videoMaximumDuration = TimeInterval(5) //segundos
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagePicker = imagePicker else {
            return
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    /*private func uploadPhotoToFirebase(){
        //nos aseguramos que hay una foto en el ImageView
        //comprimimos la imagen
        guard let imageSaved = previewImageView.image,
              let imageSavedData:Data = imageSaved.jpegData(compressionQuality: 0.1) else {
            return
        }
        
        //indicamos la carga para el proceso de subida de la imagen a firebase
        SVProgressHUD.show()
        
        //configuración para guardar la foto en firebase
        let metadataConfig = StorageMetadata()
        //le indicamos a metadata que su contenido será de tipo imagen jpg
        metadataConfig.contentType = "image/jpg"
        
        //referencia para el storage de firebase
        let storageFirebase = Storage.storage()
        
        //nombre de la imagen que subiremos... no pueden tener el mismo nombre si no se reemplazarán
        let imageName = Int.random(in: 100...1000)
        
        //indicamos en qué parte de nuestro storage de firebase se guardará
        let folderReference = storageFirebase.reference(withPath: "phtos-from-tweets/\(imageName).jpg")
        
        //subimos la foto... pero en un hilo diferente, porque será un proceso pesado y largo
        DispatchQueue.global(qos: .background).async {
            folderReference.putData(imageSavedData, metadata: metadataConfig) { (metadata: StorageMetadata?, error: Error?) in
                
                //Al momento en el que se entra a éste bloque, el proceso ha terminado... ya sea si la operación fue exitosa o tuvo un error
                //Dado esto, tendremos que regresar el hilo principal
                DispatchQueue.main.async {
                    //Detenemos la carga
                    SVProgressHUD.dismiss()
                    if let errorFromFirebase = error{
                        NotificationBanner(title: "Error",
                                           subtitle: "\(errorFromFirebase.localizedDescription)",
                                           style: .danger).show()
                        return
                    }
                    
                    //si no hubo algún error en el proceso, obtendremos la URL de descarga
                    folderReference.downloadURL { (url: URL?, error: Error?) in
                        let downloadUrl = url?.absoluteString ?? ""
                        self.savePost(imageURL: downloadUrl, videoURL: nil)
                    }
                }
            }
        }
    }*/
    
    /*private func uploadVideoToFirebase(){
        //nos aseguramos que hay una foto en el ImageView
        //comprimimos la imagen
        guard let currentVideoSavedUrl = currentVideoUrl,
              let videoData:Data = try? Data(contentsOf: currentVideoSavedUrl) else {
            return
        }
        
        //indicamos la carga para el proceso de subida de la imagen a firebase
        SVProgressHUD.show()
        
        //configuración para guardar la foto en firebase
        let metadataConfig = StorageMetadata()
        //le indicamos a metadata que su contenido será de tipo imagen jpg
        metadataConfig.contentType = "video/mp4"
        
        //referencia para el storage de firebase
        let storageFirebase = Storage.storage()
        
        //nombre del video que subiremos... no pueden tener el mismo nombre si no se reemplazarán
        let videoName = Int.random(in: 100...1000)
        
        //indicamos en qué parte de nuestro storage de firebase se guardará
        let folderReference = storageFirebase.reference(withPath: "videos-from-tweets/\(videoName).mp4")
        
        //subimos la video... pero en un hilo diferente, porque será un proceso pesado y largo
        DispatchQueue.global(qos: .background).async {
            folderReference.putData(videoData, metadata: metadataConfig) { (metadata: StorageMetadata?, error: Error?) in
                
                //Al momento en el que se entra a éste bloque, el proceso ha terminado... ya sea si la operación fue exitosa o tuvo un error
                //Dado esto, tendremos que regresar el hilo principal
                DispatchQueue.main.async {
                    //Detenemos la carga
                    SVProgressHUD.dismiss()
                    if let errorFromFirebase = error{
                        NotificationBanner(title: "Error",
                                           subtitle: "\(errorFromFirebase.localizedDescription)",
                                           style: .danger).show()
                        return
                    }
                    
                    //si no hubo algún error en el proceso, obtendremos la URL de descarga
                    folderReference.downloadURL { (url: URL?, error: Error?) in
                        let downloadUrl = url?.absoluteString ?? ""
                        self.savePost(imageURL: nil, videoURL: downloadUrl)
                    }
                }
            }
        }
    }*/
    
    
    private func uploadMediaToFirebase(thereIsVideo:Bool, thereIsImage:Bool){
        
        if thereIsVideo && !thereIsImage{
            //nos aseguramos que hay una foto en el ImageView
            //comprimimos la imagen
            guard let currentVideoSavedUrl = currentVideoUrl,
                  let videoData:Data = try? Data(contentsOf: currentVideoSavedUrl) else {
                return
            }
            
            //indicamos la carga para el proceso de subida de la imagen a firebase
            SVProgressHUD.show()
            
            //configuración para guardar la foto en firebase
            let metadataConfig = StorageMetadata()
            //le indicamos a metadata que su contenido será de tipo imagen jpg
            metadataConfig.contentType = "video/mp4"
            
            //referencia para el storage de firebase
            let storageFirebase = Storage.storage()
            
            //nombre del video que subiremos... no pueden tener el mismo nombre si no se reemplazarán
            let videoName = Int.random(in: 100...1000)
            
            //indicamos en qué parte de nuestro storage de firebase se guardará
            let folderReference = storageFirebase.reference(withPath: "videos-from-tweets/\(videoName).mp4")
            
            //subimos la video... pero en un hilo diferente, porque será un proceso pesado y largo
            DispatchQueue.global(qos: .background).async {
                folderReference.putData(videoData, metadata: metadataConfig) { (metadata: StorageMetadata?, error: Error?) in
                    
                    //Al momento en el que se entra a éste bloque, el proceso ha terminado... ya sea si la operación fue exitosa o tuvo un error
                    //Dado esto, tendremos que regresar el hilo principal
                    DispatchQueue.main.async {
                        //Detenemos la carga
                        SVProgressHUD.dismiss()
                        if let errorFromFirebase = error{
                            NotificationBanner(title: "Error",
                                               subtitle: "\(errorFromFirebase.localizedDescription)",
                                               style: .danger).show()
                            return
                        }
                        
                        //si no hubo algún error en el proceso, obtendremos la URL de descarga
                        folderReference.downloadURL { (url: URL?, error: Error?) in
                            let downloadUrl = url?.absoluteString ?? ""
                            self.savePost(imageURL: nil, videoURL: downloadUrl)
                        }
                    }
                }
            }
        }
        
        else if thereIsImage && !thereIsVideo{
            
            //nos aseguramos que hay una foto en el ImageView
            //comprimimos la imagen
            guard let imageSaved = previewImageView.image,
                  let imageSavedData:Data = imageSaved.jpegData(compressionQuality: 0.1) else {
                return
            }
            
            //indicamos la carga para el proceso de subida de la imagen a firebase
            SVProgressHUD.show()
            
            //configuración para guardar la foto en firebase
            let metadataConfig = StorageMetadata()
            //le indicamos a metadata que su contenido será de tipo imagen jpg
            metadataConfig.contentType = "image/jpg"
            
            //referencia para el storage de firebase
            let storageFirebase = Storage.storage()
            
            //nombre de la imagen que subiremos... no pueden tener el mismo nombre si no se reemplazarán
            let imageName = Int.random(in: 100...1000)
            
            //indicamos en qué parte de nuestro storage de firebase se guardará
            let folderReference = storageFirebase.reference(withPath: "phtos-from-tweets/\(imageName).jpg")
            
            //subimos la foto... pero en un hilo diferente, porque será un proceso pesado y largo
            DispatchQueue.global(qos: .background).async {
                folderReference.putData(imageSavedData, metadata: metadataConfig) { (metadata: StorageMetadata?, error: Error?) in
                    
                    //Al momento en el que se entra a éste bloque, el proceso ha terminado... ya sea si la operación fue exitosa o tuvo un error
                    //Dado esto, tendremos que regresar el hilo principal
                    DispatchQueue.main.async {
                        //Detenemos la carga
                        SVProgressHUD.dismiss()
                        if let errorFromFirebase = error{
                            NotificationBanner(title: "Error",
                                               subtitle: "\(errorFromFirebase.localizedDescription)",
                                               style: .danger).show()
                            return
                        }
                        
                        //si no hubo algún error en el proceso, obtendremos la URL de descarga
                        folderReference.downloadURL { (url: URL?, error: Error?) in
                            let downloadUrl = url?.absoluteString ?? ""
                            self.savePost(imageURL: downloadUrl, videoURL: nil)
                        }
                    }
                }
            }
            
        }
        
        else if thereIsImage && thereIsVideo{
            //TODO: subir simultaneamente ambos
        }
        
        else{
            savePost(imageURL: nil, videoURL: nil)
        }
        
        /*
        if !thereIsVideo{
            //nos aseguramos que hay una foto en el ImageView
                    //comprimimos la imagen
                    guard let currentVideoSavedUrl = currentVideoUrl,
                        let videoData:Data = try? Data(contentsOf: currentVideoSavedUrl) else {
                        return
                    }
                    
                    //indicamos la carga para el proceso de subida de la imagen a firebase
                    //SVProgressHUD.show()
                    
                    //configuración para guardar la foto en firebase
                    let metadataConfig = StorageMetadata()
                    //le indicamos a metadata que su contenido será de tipo imagen jpg
                    metadataConfig.contentType = "video/MP4"
                    
                    //referencia para el storage de firebase
                    let storageFirebase = Storage.storage()
                    
                    //nombre del video que subiremos... no pueden tener el mismo nombre si no se reemplazarán
                    let videoName = Int.random(in: 100...1000)
                    
                    //indicamos en qué parte de nuestro storage de firebase se guardará
                    let folderReference = storageFirebase.reference(withPath: "videos-from-tweets/\(videoName).mp4")
                    
                    //subimos la video... pero en un hilo diferente, porque será un proceso pesado y largo
                    DispatchQueue.global(qos: .background).async {
                        folderReference.putData(videoData, metadata: metadataConfig) { (metadata: StorageMetadata?, error: Error?) in
                            
                            //Al momento en el que se entra a éste bloque, el proceso ha terminado... ya sea si la operación fue exitosa o tuvo un error
                            //Dado esto, tendremos que regresar el hilo principal
                            DispatchQueue.main.async {
                                //Detenemos la carga
                                //SVProgressHUD.dismiss()
                                if let errorFromFirebase = error{
                                    NotificationBanner(title: "Error",
                                                    subtitle: "\(errorFromFirebase.localizedDescription)",
                                                    style: .danger).show()
                                    return
                                }
                                
                                //si no hubo algún error en el proceso, obtendremos la URL de descarga
                                folderReference.downloadURL { (url: URL?, error: Error?) in
                                    self.downloadVideoUrl = url?.absoluteString ?? ""
                                }
                            }
                        }
                    }
        }
        
        if !thereIsImage{
            //nos aseguramos que hay una foto en el ImageView
            //comprimimos la imagen
            guard let imageSaved = previewImageView.image,
                let imageSavedData:Data = imageSaved.jpegData(compressionQuality: 0.1) else {
                return
            }
            
            //indicamos la carga para el proceso de subida de la imagen a firebase
            //SVProgressHUD.show()
            
            //configuración para guardar la foto en firebase
            let metadataConfig = StorageMetadata()
            //le indicamos a metadata que su contenido será de tipo imagen jpg
            metadataConfig.contentType = "image/jpg"
            
            //referencia para el storage de firebase
            let storageFirebase = Storage.storage()
            
            //nombre de la imagen que subiremos... no pueden tener el mismo nombre si no se reemplazarán
            let imageName = Int.random(in: 100...1000)
            
            //indicamos en qué parte de nuestro storage de firebase se guardará
            let folderReference = storageFirebase.reference(withPath: "phtos-from-tweets/\(imageName).jpg")
            
            //subimos la foto... pero en un hilo diferente, porque será un proceso pesado y largo
            DispatchQueue.global(qos: .background).async {
                folderReference.putData(imageSavedData, metadata: metadataConfig) { (metadata: StorageMetadata?, error: Error?) in
                    
                    //Al momento en el que se entra a éste bloque, el proceso ha terminado... ya sea si la operación fue exitosa o tuvo un error
                    
                    //si no hubo algún error en el proceso, obtendremos la URL de descarga
                    folderReference.downloadURL { (url: URL?, error: Error?) in
                        self.downloadImageUrl = url?.absoluteString ?? ""
                    }
                    
                    //Dado esto, tendremos que regresar el hilo principal
                    DispatchQueue.main.async {
                        //Detenemos la carga
                        //SVProgressHUD.dismiss()
                        if let errorFromFirebase = error{
                            NotificationBanner(title: "Error",
                                            subtitle: "\(errorFromFirebase.localizedDescription)",
                                            style: .danger).show()
                            return
                        }
                        
                    }
                }
            }
        }
        */
    }
    
    /*private func uploadMediaFileFirebase(postText: String, imageSaved: UIImage?, currentVideoURL: URL?) {

            var fileData: Data? = nil
            var contentType: String? = nil
            let fileName = Int.random(in: 100...10000)
            var filePath: String? = nil
            var isVideo: Bool = false

            //Case when is an image
            if let imageSaved = imageSaved, let imageSavedData = imageSaved.jpegData(compressionQuality: 0.1) {
                fileData = imageSavedData
                contentType = "image/jpg"
                filePath = "tweets/\(fileName).jpg"
            }

            //Case when is a video
            else if let currentVideoURL = currentVideoURL, let videoData: Data = try? Data(contentsOf: currentVideoURL) {
                fileData = videoData
                contentType = "video/mp4"
                filePath = "video-tweets/\(fileName).mp4"
                isVideo = true
            }

            guard let newFileData = fileData, let newFilePath = filePath else {
                    return
            }

            SVProgressHUD.show()
            let metadataConfig = StorageMetadata()
            metadataConfig.contentType = contentType
            let storage = Storage.storage()
            let folderReference = storage.reference(withPath: newFilePath)
            DispatchQueue.global(qos: .background).async {
                folderReference.putData(newFileData, metadata: metadataConfig) { (metadata: StorageMetadata?, error: Error?) in
                    if let error = error {
                        NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .warning).show()
                        return
                    }
                    folderReference.downloadURL { (url: URL?, error: Error?) in
                        SVProgressHUD.dismiss()
                        let finalUrl = url?.absoluteString ?? ""
                        self.savePost(imageURL: isVideo ? nil : finalUrl,
                                      videoURL: isVideo ? finalUrl : nil )
                    }
                }
            }
        }*/
    
    private func savePost(imageURL:String?, videoURL:String?){
        
        //Creamos un request para la localización
        var postLocation:PostRequesLocation?
        if let tempUserLocation = userLocation {
            postLocation = PostRequesLocation(longitude: tempUserLocation.coordinate.longitude,
                                              latitude: tempUserLocation.coordinate.latitude)
        }
        
        
//        //validar que el campo de texto no esté vacío
//        guard let newTweet = newTweetText, //modificación de newTweetTextView.text
//              !newTweet.isEmpty else {
//            NotificationBanner(title: "Campo vacío",
//                               subtitle: "Ingresa un nuevo tweet 😄",
//                               style: .warning).show()
//            return
//        }
        
        //Crear request
        let request = PostRequest(text: newTweetTextView.text, imageUrl: imageURL, videoUrl: videoURL, location: postLocation)
        
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
    
    private func requestLocation(){
        //Primero debemos verificar que el usuario tenga activado su GPS y esté disponible
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        
        //una vez verificado la disponibilidad, instanciamos nuestra clase
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        //mientras más acertada sea la ubicación, más exigente en batería será la app
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation() //apenas haya oportunidad, la ubicación será actualizada
    }
}

//MARK: - ImagePickerDelegate, NavigationDelegate
extension AddPostViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //cerramos la cámara
        imagePicker?.dismiss(animated: true, completion: nil)
        
        //capturar imagen para desplegarla
        if info.keys.contains(.originalImage){
            previewImageView.isHidden = false
            
            //obtenemos la imagen que fue tomada
            previewImageView.image = info[.originalImage] as? UIImage
            
        }
        
        //desplegamos el video si fue grabado
        if info.keys.contains(.mediaURL), let recordedVideoUrl = (info[.mediaURL] as? URL)?.absoluteURL{
            currentVideoUrl = recordedVideoUrl
            videoButton.isHidden = false
        }
    }
}

//MARK: -CLLocationManagerDelegate
extension AddPostViewController:CLLocationManagerDelegate{
    //obtendremos los resultados de la geolocalización
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //recibieremos un arreglo con varios datos de ubicación, el último valor es el que habla de la ubicación con más precisión
        guard let bestLocation = locations.last else {
            return
        }
        
        //a partir de aquí, ya tenemos guardada la ubicación del usuario
        userLocation = bestLocation //la asignamos a nuestra variable global
        
        //sería conveniente tener un plan de respaldo por si el usuario no permite activar los servicios de ubicación... si esta es necesaria para que nuestra app funcione de la mejor manera
        
        
    }
}
