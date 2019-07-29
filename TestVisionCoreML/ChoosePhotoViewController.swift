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
    @IBOutlet var imageView: UIImageView!
    @IBAction func choosePhotoAction(_ sender: UIButton) {
        presentPhotoPicker(sourceType: .photoLibrary)
    }
    @IBOutlet var mlResultContainerView: UIStackView!
    @IBOutlet var mlResultContent: UILabel!
    
    private lazy var coreMLRequest: VNCoreMLRequest = {
        do {
            // Use "MobileNet" model
            // Could change the model at here.
            let model = try VNCoreMLModel(for: MobileNet().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] (request, error) in
                self?.processCoreMLRequest(request, error: error)
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
    
    private func processCoreMLRequest(_ request: VNRequest, error: Error?) {
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
    
    private func showMLResults(for image: UIImage) {
        mlResultContent.text = "Analyzing..."
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else {
            fatalError("Failed to create \(CIImage.self) from \(image)")
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.coreMLRequest])
            } catch {
                fatalError("Failed to perform classification. \n\(error.localizedDescription)")
            }
        }
    }
}

extension ChoosePhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Handling Image Picker Selection
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        showMLResults(for: image)
    }
}
