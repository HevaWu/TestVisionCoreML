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

class ChoosePhotoViewController: BaseViewController {
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

extension ChoosePhotoViewController: BaseViewControllerDelegate {
    func tapPhotoPickerButton(_ sender: UIButton) {
        presentPhotoPicker(sourceType: .photoLibrary)
    }
    
    func setPhotoPickerButtonTitle() -> String {
        return "Choose Photo"
    }
}
