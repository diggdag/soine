//
//  SettingCategoryViewController.swift
//  soine
//
//  Created by 倉知諒 on 2022/05/29.
//

import UIKit
import CoreData
import GoogleMobileAds

class SettingCategoryViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    var targetId:Int16? = nil
    var appDelegate:AppDelegate!
    var viewContext:NSManagedObjectContext!
    var editMode:EditMode = .add
    var bannerView: GADBannerView!
    var bannerView2: GADBannerView!
    @IBOutlet weak var okBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        viewContext = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()

        if editMode == .edit {
            okBtn.setTitle("更新", for: .normal)
            request.predicate = NSPredicate(format: "categoryId = %d", targetId!)
        
            do {
                let fetchResults = try viewContext.fetch(request)
                textField.text = fetchResults[0].name
            } catch  let e as NSError{
                print("error !!! : \(e)")
            }
        }
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeMediumRectangle)
        bannerView.adUnitID = "ca-app-pub-5418872710464793/4286888233"
        bannerView.rootViewController = self
        addBannerViewToView(bannerView)
        bannerView.load(GADRequest())
        
        bannerView2 = GADBannerView(adSize: kGADAdSizeMediumRectangle)
        bannerView2.adUnitID = "ca-app-pub-5418872710464793/4286888233"
        bannerView2.rootViewController = self
        addBannerViewToView2(bannerView2)
        bannerView2.load(GADRequest())
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    @IBAction func touchDown_ok(_ sender: Any) {
        let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
        if editMode == .edit {
            request.predicate = NSPredicate(format: "categoryId = %d", targetId!)
        }
        do{
            let fetchResults = try viewContext.fetch(request)
            if editMode == .edit {
                fetchResults[0].name = textField.text
                try viewContext.save()
            }
            else{
                let next_id = getNextId()
                let soineData = NSEntityDescription.entity(forEntityName: "CategoryData", in: viewContext)
                let record = NSManagedObject(entity: soineData!, insertInto: viewContext) as! CategoryData
                record.categoryId = next_id
                record.name = textField.text
                appDelegate.saveContext()
                targetId = next_id
            }
        } catch let e as NSError{
            print("error !!! : \(e)")
        }
        let parentVC = presentingViewController?.children[2] as! CategoryEditingViewController
        parentVC.refreshData()
        dismiss(animated: true, completion: nil)
    }
    func getMaxId() -> Int16? {
        var max_id:Int16?
        do{
            let request_max: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
            request_max.fetchLimit = 1
            let sortDescriptor = NSSortDescriptor(key: "categoryId", ascending: false)
            let sortDescriptors = [sortDescriptor]
            request_max.sortDescriptors = sortDescriptors
            let fetchResults = try viewContext.fetch(request_max)
            if fetchResults.count != 0 {
                max_id = fetchResults[0].categoryId
            }
        } catch let e as NSError{
            print("error !!! : \(e)")
        }
        return max_id
    }
    func getNextId() -> Int16 {
        var max_id = getMaxId()
        if max_id == nil {
            max_id = 0
        }
        else{
            max_id = max_id! + 1
        }
        return max_id!
    }
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
          [NSLayoutConstraint(item: bannerView,
                              attribute: .bottom,
                              relatedBy: .equal,
                              toItem: bottomLayoutGuide,
                              attribute: .top,
                              multiplier: 1,
                              constant: 0),
           NSLayoutConstraint(item: bannerView,
                              attribute: .centerX,
                              relatedBy: .equal,
                              toItem: view,
                              attribute: .centerX,
                              multiplier: 1,
                              constant: 0)
          ])
       }
    func addBannerViewToView2(_ banner: GADBannerView) {
        banner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(banner)
        view.addConstraints(
          [NSLayoutConstraint(item: banner,
                              attribute: .bottom,
                              relatedBy: .equal,
                              toItem: bannerView,
                              attribute: .top,
                              multiplier: 1,
                              constant: 0),
           NSLayoutConstraint(item: banner,
                              attribute: .centerX,
                              relatedBy: .equal,
                              toItem: view,
                              attribute: .centerX,
                              multiplier: 1,
                              constant: 0)
          ])
       }
}
