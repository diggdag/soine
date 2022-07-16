//
//  ViewController.swift
//  soine
//
//  Created by 倉知諒 on 2022/04/22.
//

import UIKit
import Photos
import CoreData
import Toast_Swift
import GoogleMobileAds
import AppTrackingTransparency

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var datas: [[SoineData]] = []
//    var categories:[CategoryData] = []
    var sections: [CategoryDataDisplay] = []
    var selectedData:SoineData?
    
    var appDelegate:AppDelegate!
    var viewContext:NSManagedObjectContext!
    var existNonCategorize = false
    var bannerView: GADBannerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController viewDidLoad")
        // Do any additional setup after loading the view.
        
        //写真アクセス許可
        if #available(iOS 14, *) {
            let accessLebel:PHAccessLevel = .readWrite
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
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let backButton = UIBarButtonItem()
        backButton.title = "もどる"
        navigationItem.backBarButtonItem = backButton
        
        // In this case, we instantiate the banner with desired ad size.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(self.myEvent),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        settingAd()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewController viewWillAppear")
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        viewContext = appDelegate.persistentContainer.viewContext
        refrechData()
        
    }
    @objc func myEvent() {
        if #available(iOS 14, *) {
            if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    GADMobileAds.sharedInstance().start(completionHandler: nil)
//                    self.settingAd()
                })
            }
//            else{
//                settingAd()
//            }
        }
        else {
            // Fallback on earlier versions
            GADMobileAds.sharedInstance().start(completionHandler: nil)
//            settingAd()
        }
    }
    func settingAd() {
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"//test ad
        bannerView.adUnitID = "ca-app-pub-5418872710464793/4324956840"
        bannerView.rootViewController = self
        addBannerViewToView(bannerView)
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [Consts.ADMOB_TEST_DEVICE_ID,Consts.ADMOB_TEST_DEVICE_ID_SE2]
        bannerView.load(GADRequest())
    }
    func refrechData() {
        updateIsNonCategorize()
        appendSections()
        datas = []
        for _ in 0..<sections.count {
            datas.append([])
        }
        var loopCnt = sections.count
        if existNonCategorize {
            loopCnt = loopCnt - 1
        }
        let request: NSFetchRequest<SoineData> = SoineData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        let sortDescriptors = [sortDescriptor]
        request.sortDescriptors = sortDescriptors
        do {
            let fetchResults = try viewContext.fetch(request)
            for result: AnyObject in fetchResults {
                let soineData = result as! SoineData
                var insert = false
                for i in 0 ..< loopCnt {
                    if soineData.categoryData?.categoryId == sections[i].categoryId {
                        datas[i].append(soineData)
                        insert = true
                    }
                }
                if !insert {
                    datas[datas.count - 1].append(soineData)
                }
            }
        } catch let e as NSError{
            print("error !!! : \(e)")
        }
        tableView.reloadData()
//        UIView.transition(with: tableView, duration: 1.0, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
    }
    func appendSections() {
        sections = []
        let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "categoryId", ascending: true)
        let sortDescriptors = [sortDescriptor]
        request.sortDescriptors = sortDescriptors
        do {
            let fetchResults = try viewContext.fetch(request)
            for result: AnyObject in fetchResults {
                let categoryData = result as! CategoryData
                if categoryData.soineData != nil && categoryData.soineData!.count != 0 {
                    sections.append(CategoryDataDisplay(_categoryId: categoryData.categoryId, _name: categoryData.name!))
                }
            }
            if existNonCategorize {
                sections.append(CategoryDataDisplay(_categoryId: nil, _name: "ほか"))
            }
        } catch let e as NSError{
            print("error !!! : \(e)")
        }
    }
    func updateIsNonCategorize() {
        existNonCategorize = false
        let request: NSFetchRequest<SoineData> = SoineData.fetchRequest()
        do{
            let fetchResults = try viewContext.fetch(request)
            for result: AnyObject in fetchResults {
                let soineData = result as! SoineData
                if soineData.categoryData == nil {
                    existNonCategorize = true
                }
            }
        } catch let e as NSError{
            print("error !!! : \(e)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSoine" {
            let nextVC = segue.destination as! SoineViewController
            if selectedData != nil {
                nextVC.targetId = selectedData!.id
            }
        }
        else if segue.identifier == "toSetting" {
            let nextVC = segue.destination as! SettingsTableViewController
            if selectedData != nil {
                nextVC.targetId = selectedData!.id
            }
        }
    }
    @IBAction func touchDown_add(_ sender: Any) {
        selectedData = nil
        self.performSegue(withIdentifier: "toSetting", sender: nil)
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
extension ViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let soineData: SoineData = datas[indexPath.section][indexPath.row]
        if soineData.adFlg {
            let cell: TableViewCell_list_ad = tableView.dequeueReusableCell(withIdentifier: "TableViewCell_list_ad") as! TableViewCell_list_ad
//            cell.setCell(unitId: "ca-app-pub-3940256099942544/2934735716", rootViewController: self)
            cell.setCell(unitId: "ca-app-pub-5418872710464793/1165352137", rootViewController: self, _id: soineData.id)
            
//            let bannerViewCell:GADBannerView!
//
//            bannerViewCell = GADBannerView(adSize: kGADAdSizeLargeBanner)
//            bannerViewCell.adUnitID = "ca-app-pub-3940256099942544/2934735716"
//            bannerViewCell.rootViewController = self
//            cell.addSubview(bannerViewCell)
//            bannerViewCell.load(GADRequest())
            return cell
        }
        let cell: TableViewCell_list = tableView.dequeueReusableCell(withIdentifier: "TableViewCell_list") as! TableViewCell_list
        let image:UIImage = soineData.picture == nil ? UIImage() : UIImage(data: soineData.picture!)!
        let voiceName: String = soineData.voiceName == nil ? "" : soineData.voiceName!
//        let categoryId: String = soineData.categoryData == nil ? "" : String(soineData.categoryData!.categoryId)
        cell.setCell(data: Data_list(
            voiceName: (Consts.DEBUG_FLG ? "\(soineData.id):\(voiceName)":"\(voiceName)"), category: image, scale: CGFloat(soineData.scale)))//\(String(soineData.id)):
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        cell.btn.isHidden = false
        if soineData.voiceName == nil {
            cell.btn.isHidden = true
        }
        else{
            cell.btn.tag = (indexPath.section * 1000) + indexPath.row
            cell.btn.addTarget(self, action: #selector(self.pushButton(_:)), for: .touchUpInside)
        }
        return cell
    }
    @objc private func pushButton(_ sender:UIButton)
    {
        let row = sender.tag % 1000
        let section = sender.tag / 1000
        selectedData = datas[section][row]
        self.performSegue(withIdentifier: "toSoine", sender: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var rtn :[String] = []
        for sec in sections {
//            rtn.append(String(sec.name?.prefix(3)))
            rtn.append(String(sec.name!.prefix(3)))
        }
        return rtn
    }
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if Consts.DEBUG_FLG {
            let id = sections[section].categoryId ?? 999
            let name = sections[section].name ?? ""
            
            return "\(id):\(name)"
        }
        else{
            return sections[section].name
        }
    }
}
extension ViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        selectedData = datas[indexPath.section][indexPath.row]
        self.performSegue(withIdentifier: "toSetting", sender: nil)
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .delete
        }
        return .none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let request: NSFetchRequest<SoineData> = SoineData.fetchRequest()
            request.predicate = NSPredicate(format: "id = %d", datas[indexPath.section][indexPath.row].id)
            do{
                let fetchResults = try viewContext.fetch(request)
                viewContext.delete(fetchResults[0])
                try viewContext.save()
            } catch let e as NSError{
                print("error !!! : \(e)")
            }
            
            let screenSizeWidth = UIScreen.main.bounds.width
            let screenSizeHeight = UIScreen.main.bounds.height
            self.view.makeToast("削除しました", point: CGPoint(x: screenSizeWidth/2, y: screenSizeHeight/2), title: nil, image: nil, completion: nil)
            
            refrechData()
        }
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("(\(sourceIndexPath.section),\(sourceIndexPath.row))->(\(destinationIndexPath.section),\(destinationIndexPath.row))")
        //セクション間移動
        if sourceIndexPath.section != destinationIndexPath.section {
            refrechData()
            return
        }
        let category = datas[sourceIndexPath.section][sourceIndexPath.row]
        datas[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        datas[sourceIndexPath.section].insert(category, at: destinationIndexPath.row)
        var data_tmp: [SoineData] = []
        let next_id = Utilities.getNextId(viewContext: viewContext)
        for (i,data) in datas[sourceIndexPath.section].enumerated() {
//            data.id = Int16(i) + next_id
            data.id = Int32(datas[sourceIndexPath.section].count - 1 - i) + next_id
            data_tmp.append(data)
        }
        datas[sourceIndexPath.section] = data_tmp
        do{
            try viewContext.save()
        } catch let e as NSError{
            print("error !!! : \(e)")
        }
        refrechData()
    }

}
