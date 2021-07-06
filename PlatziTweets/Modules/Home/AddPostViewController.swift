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
        uploadMediaToFirebase(thereIsVideo: videoButton.isHidden, thereIsImage: previewImageView.isHidden)
    }
    
    @IBAction func dismissTweet(){
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Properties
    private var imagePicker:UIImagePickerController?
    //private var downloadUrlImageFromFirebase:String?
    private var currentVideoUrl:URL?
    

    //MARK: - App's Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoButton.isHidden = true
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
    
    //TODO: combinar uploadPhoto y uploadVideo en una sola funcion, con ayuda de parámetros
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
        
        var downloadVideoUrl:String?
        var downloadImageUrl:String?
        
        if !thereIsVideo{
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
                                SVProgressHUD.dismiss()
                                if let errorFromFirebase = error{
                                    NotificationBanner(title: "Error",
                                                       subtitle: "\(errorFromFirebase.localizedDescription)",
                                                       style: .danger).show()
                                    return
                                }
                                
                                //si no hubo algún error en el proceso, obtendremos la URL de descarga
                                folderReference.downloadURL { (url: URL?, error: Error?) in
                                    downloadVideoUrl = url?.absoluteString ?? ""
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
                            downloadImageUrl = url?.absoluteString ?? ""
                        }
                    }
                }
            }
        }
        
        savePost(imageURL: downloadImageUrl, videoURL: downloadVideoUrl)
    }
    
    private func savePost(imageURL:String?, videoURL:String?){
        
        //validar que el campo de texto no esté vacío
        guard let newTweet = newTweetTextView.text,
              !newTweet.isEmpty else {
            NotificationBanner(title: "Campo vacío",
                               subtitle: "Ingresa un nuevo tweet 😄",
                               style: .warning).show()
            return
        }
        
        //Crear request
        let request = PostRequest(text: newTweet, imageUrl: imageURL, videoUrl: nil, location: nil)
        
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
    /*private func savePostWithoutImage(){
        
        //validar que el campo de texto no esté vacío
        guard let newTweet = newTweetTextView.text,
              !newTweet.isEmpty else {
            NotificationBanner(title: "Campo vacío",
                               subtitle: "Ingresa un nuevo tweet 😄",
                               style: .warning).show()
            return
        }
        
        //Crear request
        let request = PostRequest(text: newTweet, imageUrl: nil, videoUrl: nil, location: nil)
        
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
    }*/
}

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
