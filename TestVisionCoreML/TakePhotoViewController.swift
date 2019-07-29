//
//  TakePhotoViewController.swift
//  TestVisionCoreML
//
//  Created by He Wu on 2019/07/29.
//  Copyright © 2019 He Wu. All rights reserved.
//

import UIKit

final class TakePhotoViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBAction func takePhotoAction(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        presentPhotoPicker(sourceType: .camera)
    }
    
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
}

extension TakePhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Handling Image Picker Selection
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        // showClassifications(for: image)
    }
}
