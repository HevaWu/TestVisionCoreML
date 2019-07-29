//
//  ChoosePhotoViewController.swift
//  TestVisionCoreML
//
//  Created by He Wu on 2019/07/29.
//  Copyright © 2019 He Wu. All rights reserved.
//

import UIKit

class ChoosePhotoViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBAction func choosePhotoAction(_ sender: UIButton) {
        presentPhotoPicker(sourceType: .photoLibrary)
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

extension ChoosePhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Handling Image Picker Selection
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        // showClassifications(for: image)
    }
}
