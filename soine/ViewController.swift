//
//  ViewController.swift
//  soine
//
//  Created by 倉知諒 on 2022/04/22.
//

import UIKit
import Photos

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //写真アクセス許可
        if #available(iOS 14, *) {
            let accessLebel:PHAccessLevel = .addOnly
            PHPhotoLibrary.requestAuthorization(for: accessLebel){status in
                DispatchQueue.main.async() {
                }
            }
//            PHPhotoLibrary.authorizationStatus(for: accessLebel)
        }
        else {
            // Fallback on earlier versions
            PHPhotoLibrary.requestAuthorization(){status in
                DispatchQueue.main.async() {
                }
            }
        }
    }


}
