//
//  TakePhotoViewController.swift
//  TestVisionCoreML
//
//  Created by He Wu on 2019/07/29.
//  Copyright © 2019 He Wu. All rights reserved.
//

import UIKit

final class TakePhotoViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
    }
    
    init() {
        super.init(nibName: "BaseViewController", bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TakePhotoViewController: BaseViewControllerDelegate {
    func tapPhotoPickerButton(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        presentPhotoPicker(sourceType: .camera)
    }
    
    func setPhotoPickerButtonTitle() -> String {
        return "Take Photo"
    }
}
