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
    var datas: [SoineData] = []
    var selectedData:SoineData?
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
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewContext = appDelegate.persistentContainer.viewContext
        datas = []
        let request: NSFetchRequest<SoineData> = SoineData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        let sortDescriptors = [sortDescriptor]
        request.sortDescriptors = sortDescriptors
        do {
            let fetchResults = try viewContext.fetch(request)
            for result: AnyObject in fetchResults {
                datas.append(result as! SoineData)
            }
        } catch let e as NSError{
            print("error !!! : \(e)")
        }
        tableView.reloadData()
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
    
}
extension ViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let account: SoineData = datas[indexPath.row]

        let cell: TableViewCell_list = tableView.dequeueReusableCell(withIdentifier: "TableViewCell_list") as! TableViewCell_list
    
        let image:UIImage = UIImage(data: account.picture!)!
        
        var voiceName: String = ""
        if account.voiceFilePath != nil {
            voiceName = (account.voiceFilePath?.lastPathComponent)!
        }
            
        cell.setCell(data: Data_list(
            voiceName: voiceName, category: image))
    
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        cell.btn.tag = indexPath.row
        cell.btn.addTarget(self, action: #selector(self.pushButton(_:)), for: .touchUpInside)
        return cell
    }
    @objc private func pushButton(_ sender:UIButton)
    {
        let row = sender.tag
        selectedData = datas[row]
        self.performSegue(withIdentifier: "toSoine", sender: nil)
    }
    
}
extension ViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        selectedData = datas[indexPath.row]
        self.performSegue(withIdentifier: "toSetting", sender: nil)
    }
}
