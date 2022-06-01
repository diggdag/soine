//
//  ViewController.swift
//  soine
//
//  Created by 倉知諒 on 2022/04/22.
//

import UIKit
import Photos
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var datas: [[SoineData]] = []
//    var categories:[CategoryData] = []
    var sections: [String] = []
    var selectedData:SoineData?
    
    var appDelegate:AppDelegate!
    var viewContext:NSManagedObjectContext!
    var existNonCategorize = false
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController viewDidLoad")
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
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewController viewWillAppear")
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        viewContext = appDelegate.persistentContainer.viewContext
        refrechData()
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
                    if soineData.categoryData?.name == sections[i] {
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
                    sections.append(categoryData.name!)
                }
            }
            if existNonCategorize {
                sections.append("ほか")
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

        let cell: TableViewCell_list = tableView.dequeueReusableCell(withIdentifier: "TableViewCell_list") as! TableViewCell_list
    
        let image:UIImage = soineData.picture == nil ? UIImage() : UIImage(data: soineData.picture!)!
        let voiceName: String = soineData.voiceName == nil ? "" : soineData.voiceName!
        
            
        cell.setCell(data: Data_list(
            voiceName: "\(voiceName)", category: image, scale: CGFloat(soineData.scale)))//\(String(soineData.id)):
    
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        cell.btn.tag = (indexPath.section * 1000) + indexPath.row
        cell.btn.addTarget(self, action: #selector(self.pushButton(_:)), for: .touchUpInside)
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
        return sections
    }
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
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
            refrechData()
        }
    }
}
