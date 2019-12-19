//
//  ViewController.swift
//  machineLearningImage
//
//  Created by MacxbookPro on 15.12.2019.
//  Copyright © 2019 MacxbookPro. All rights reserved.
//

import UIKit
//import CoreML
import CoreML
import Vision

class ViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    var chosenImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    //get the picture
    @IBAction func changeButtonClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker,animated: true,completion: nil)
    }
    //after getting pictrue
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)// bunu kapatir
        
        if let ciImage = CIImage(image: imageView.image!) {
            //biz daha onceleri hep UIImage ile calistmistik ancak ml islemlerini yapabilmek icin
            //CIImage'a ihtiyacimiz var burada if let diyerek almaya calistik ardindan da yularida tanimladigimiz degiskene atadik ki global kullanabilelim
            
            chosenImage = ciImage
            
        }
        //kullanici sectigi gibi bu ortaya cikar
        recognizeImage(image: chosenImage)
    }
    
    //match the pics with true ones
    func recognizeImage(image : CIImage){
        
        resultLabel.text = "Finding..."
        //1) Request olusturdugumuz yer
        
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            //modeli sectik
            let request = VNCoreMLRequest(model: model) { (vnrequest, error) in
                
                if let results = vnrequest.results as? [VNClassificationObservation] {//yine bir any objesi
                    if results.count > 0 {
                        let topResult = results.first //en ust sonuc en iyi tahmini verir
                        
                        DispatchQueue.main.async {
                            //
                            let confidanceLavel = (topResult!.confidence) * 100
                            //bu sonuc 0.25 gibi bir sonuc veriyor biz %25 gormek istedigimiz icin bunu 100'le carptik
                            let rounded = Int(confidanceLavel * 100) / 100
                            self.resultLabel.text = "\(rounded)% it's \(topResult!.identifier)"
                            }
                        }
                    }
            }
            //2) Handler req. calistiracagimiz yer
                   let handler = VNImageRequestHandler(ciImage: image)
                   DispatchQueue.global(qos: .userInteractive).async {
                    do {
                         try handler.perform([request])
                    }catch{
                        print("error")
                    }
                   
            }
            
        }
       
    }
     
}

