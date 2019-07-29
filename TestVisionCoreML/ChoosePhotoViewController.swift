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
    
    var objectDetectionOverlay: CALayer! = nil
    lazy var objectDetectRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: YOLOv3Tiny().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] (request, error) in
                self?.processObjectDetectRequest(request, error: error)
            })
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setObjectDetectionOverlay()
    }
    
    private func setObjectDetectionOverlay() {
        objectDetectionOverlay = CALayer()
        objectDetectionOverlay.name = "ObjectDetectionOverlay"
        objectDetectionOverlay.bounds = CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageView.frame.height)
        objectDetectionOverlay.position = CGPoint(x: imageView.bounds.midX, y: imageView.bounds.midY)
        imageView.layer.addSublayer(objectDetectionOverlay)
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
    
    private func processObjectDetectRequest(_ request: VNRequest, error: Error?) {
        DispatchQueue.main.async(execute: { [unowned self] in
            guard let results = request.results else {
                self.mlResultContent.text = "Unable to get model's result. \n\(error?.localizedDescription)"
                return
            }
            
            let mlresults = results as! [VNRecognizedObjectObservation]
            if mlresults.isEmpty {
                self.mlResultContent.text = "Nothing Recognized"
            } else if let topResults = mlresults.first?.labels.prefix(4) {
                let descriptions = topResults.map { result in
                    return String(format: "  (%.2f) %@", result.confidence, result.identifier)
                }
                self.mlResultContent.text = "Object Detection:\n" + descriptions.joined(separator: "\n")
            }
            
//            // perform all the UI updates on the main queue
//            if let results = request.results {
//                self.drawObjectDetectResults(results)
//            }
        })
    }
    
    private func drawObjectDetectResults(_ results: [Any]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        objectDetectionOverlay.sublayers = nil // remove all the old recogized objects
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else { continue }
            let topLabelObservation = objectObservation.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(imageView.frame.width), Int(imageView.frame.height))
            
            let shapeLayer = createObjectDetectShapeLayer(objectBounds)
            let textLayer = createObjectDetectTextLayer(objectBounds, identifier: topLabelObservation.identifier, confidence: topLabelObservation.confidence)
            
            shapeLayer.addSublayer(textLayer)
            objectDetectionOverlay.addSublayer(shapeLayer)
        }
//        updateObjectDetectLayerTransit()
        CATransaction.commit()
    }
    
    private func createObjectDetectShapeLayer(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }
    
    private func createObjectDetectTextLayer(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
        let largeFont = UIFont(name: "Helvetica", size: 24.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        // rotate the layer into screen orientation and scale and mirror
        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        return textLayer
    }
    
    private func updateObjectDetectLayerTransit() {
        let bounds = imageView.bounds
        var scale: CGFloat
        
        let xScale: CGFloat = bounds.size.width / imageView.frame.height
        let yScale: CGFloat = bounds.size.height / imageView.frame.width
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // rotate the layer into screen orientation and scale and mirror
        objectDetectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        // center the layer
        objectDetectionOverlay.position = CGPoint (x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
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
        mlResultContent.text = "Analyzing..."
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else {
            fatalError("Failed to create \(CIImage.self) from \(image)")
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.objectDetectRequest])
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
    }
}
