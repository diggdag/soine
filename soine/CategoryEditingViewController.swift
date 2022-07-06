//
//  CategoryEditingViewController.swift
//  soine
//
//  Created by 倉知諒 on 2022/05/29.
//

import UIKit
import CoreData
import GoogleMobileAds
class CategoryEditingViewController:UIViewController{
    var categories:[CategoryData] = []
    var selectedData:CategoryData?
    @IBOutlet weak var tableView: UITableView!
    var appDelegate:AppDelegate!
    var viewContext:NSManagedObjectContext!
    
    var bannerView: GADBannerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelectionDuringEditing = true
        
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeLargeBanner)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        addBannerViewToView(bannerView)
        bannerView.load(GADRequest())
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewController viewWillAppear")
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        viewContext = appDelegate.persistentContainer.viewContext
        refreshData()
    }
    func refreshData() {
        
        categories = []
        let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "categoryId", ascending: true)
        let sortDescriptors = [sortDescriptor]
        request.sortDescriptors = sortDescriptors
        do {
            let fetchResults = try viewContext.fetch(request)
            for result: AnyObject in fetchResults {
                categories.append(result as! CategoryData)
            }
        } catch let e as NSError{
            print("error !!! : \(e)")
        }
        tableView.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCategorySetting" {
            let nextVC = segue.destination as! SettingCategoryViewController
            if selectedData != nil {
                nextVC.targetId = selectedData!.categoryId
                nextVC.editMode = .edit
            }
        }
    }
    
    @IBAction func toushDown_edit(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
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
}
///////////////////////////
///extentions
/////////////////////////
extension CategoryEditingViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryData: CategoryData = categories[indexPath.row]
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let cell = UITableViewCell()
        if #available(iOS 14.0, *) {
            // iOS14以降の推奨
            var content = cell.defaultContentConfiguration()
            content.text = categoryData.name
            cell.contentConfiguration = content
        } else {
            // iOS13以前
            cell.textLabel?.text = categoryData.name
        }
        return cell
    }
    
    
}
extension CategoryEditingViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedData = categories[indexPath.row]
        self.performSegue(withIdentifier: "toCategorySetting", sender: nil)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
            request.predicate = NSPredicate(format: "categoryId = %d", categories[indexPath.row].categoryId)
//            let request_soine: NSFetchRequest<SoineData> = SoineData.fetchRequest()
//            request_soine.predicate = NSPredicate(format: "categoryId = %d", categories[indexPath.row].categoryId)
            do{
                let fetchResults = try viewContext.fetch(request)
                let category = fetchResults[0] as CategoryData
                if category.soineData != nil {
                    for soine in category.soineData! {
                        (soine as! SoineData).categoryData = nil
                    }
                }
                viewContext.delete(fetchResults[0])
                
                try viewContext.save()
            } catch let e as NSError{
                print("error !!! : \(e)")
            }
            refreshData()
        }
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("\(sourceIndexPath.row)->\(destinationIndexPath.row)")
        let category = categories[sourceIndexPath.row]
        categories.remove(at: sourceIndexPath.row)
        categories.insert(category, at: destinationIndexPath.row)
        var categories_tmp: [CategoryData] = []
        for (i,data) in categories.enumerated() {
            data.categoryId = Int16(i)
//            data.categoryId = Int16(categories.count - 1 - i)
            categories_tmp.append(data)
        }
        categories = categories_tmp
//        tableView.reloadData()
        do{
            try viewContext.save()
        } catch let e as NSError{
            print("error !!! : \(e)")
        }
        refreshData()
    }

}
