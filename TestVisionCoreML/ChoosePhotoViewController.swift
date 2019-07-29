//
//  ChoosePhotoViewController.swift
//  TestVisionCoreML
//
//  Created by He Wu on 2019/07/29.
//  Copyright © 2019 He Wu. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ChoosePhotoViewController: UIViewController {
    @IBAction func chooseButtonAction(_ sender: UIButton) {
        presentPhotoPicker(sourceType: .photoLibrary)
    }
    
    @IBOutlet var imageView: UIImageView!
    
    @IBAction func imageClassifyAction(_ sender: UIButton) {
        guard let image = imageView.image else {
            mlResultContent.text = "Please select a photo first."
            return
        }
        showImageClassifyResult(for: image)
    }
    
    @IBAction func objectDetectAction(_ sender: UIButton) {
        guard let image = imageView.image else {
            mlResultContent.text = "Please select a photo first."
            return
        }
        showObjectDetectResult(for: image)
    }
    
    @IBOutlet var mlResultContent: UILabel!
    
    lazy var imageClassifyRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: MobileNet().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] (request, error) in
                self?.processImageClassifyRequest(request, error: error)
            })
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // core ml model?
    }
    
    private func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true, completion: nil)
    }
    
    private func processImageClassifyRequest(_ request: VNRequest, error: Error?) {
        DispatchQueue.main.async { [unowned self] in
            guard let results = request.results else {
                self.mlResultContent.text = "Unable to get model's result. \n\(error?.localizedDescription)"
                return
            }
            
            // "MobileNet" model is image classification model.
            let mlresults = results as! [VNClassificationObservation]
            if mlresults.isEmpty {
                self.mlResultContent.text = "Nothing Recognized"
            } else {
                let topResults = mlresults.prefix(4)
                let descriptions = topResults.map { result in
                    return String(format: "  (%.2f) %@", result.confidence, result.identifier)
                }
                self.mlResultContent.text = "Classification:\n" + descriptions.joined(separator: "\n")
            }
        }
    }
    
    private func showImageClassifyResult(for image: UIImage) {
        mlResultContent.text = "Analyzing..."
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else {
            fatalError("Failed to create \(CIImage.self) from \(image)")
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.imageClassifyRequest])
            } catch {
                fatalError("Failed to perform classification. \n\(error.localizedDescription)")
            }
        }
    }
    
    private func showObjectDetectResult(for image: UIImage) {
        
    }
}

extension ChoosePhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Handling Image Picker Selection
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
    }
}
