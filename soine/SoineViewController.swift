//
//  SoineViewController.swift
//  soine
//
//  Created by 倉知諒 on 2022/04/23.
//

import UIKit
import CoreData
import Photos

class SoineViewController: UIViewController {
    @IBOutlet weak var image: UIView!
    var appDelegate:AppDelegate!
    var viewContext:NSManagedObjectContext!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("-------------- SoineViewController viewDidLoad --------------")
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        viewContext = appDelegate.persistentContainer.viewContext
        Utilities.setBackground_init(playerView: &image, _id: 0,toSoine: true)
    }
}
