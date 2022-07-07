//
//  SettingsTableViewController.swift
//  SettingsInAppExample
//
//  Created by Sakura on 2018/03/07.
//  Copyright © 2018年 Sakura. All rights reserved.
//

import UIKit
import Photos
import MediaPlayer
import CoreData
import UniformTypeIdentifiers
import AVFoundation
import Toast_Swift
import GoogleMobileAds

class SettingsTableViewController: UITableViewController{
    var categories:[CategoryData] = []

    @IBOutlet weak var bg: UIView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var voiceLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var loopFlag: UISwitch!
    @IBOutlet weak var interval: UISlider!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var loopFlagTitleLabel: UILabel!
    @IBOutlet weak var intervalTitleLabel: UILabel!
    var targetId:Int16? = nil
    
    var appDelegate:AppDelegate!
    var viewContext:NSManagedObjectContext!
    var categoryId:Int16? = nil
    var ActivityIndicator: UIActivityIndicatorView!
    var scale:CGFloat? = nil
    var imageData:Data? = nil//image file data
    var fileName:String? = nil
    var fileExtention:String? = nil
    var fileData:Data? = nil//voice file data
    var selectedRow:Int = 0
    var voiceLoopCount:Int = 1
    
    var bannerView: GADBannerView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        viewContext = appDelegate.persistentContainer.viewContext
        pickerView.dataSource = self
        pickerView.delegate = self
        
        // ActivityIndicatorを作成＆中央に配置
        ActivityIndicator = UIActivityIndicatorView()
        ActivityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        ActivityIndicator.center = self.view.center

        // クルクルをストップした時に非表示する
        ActivityIndicator.hidesWhenStopped = true

        // 色を設定
        ActivityIndicator.style = UIActivityIndicatorView.Style.medium

        //Viewに追加
        self.view.addSubview(ActivityIndicator)
        
        let backButton = UIBarButtonItem()
        backButton.title = "もどる"
        navigationItem.backBarButtonItem = backButton
        
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-5418872710464793/9454905695"
        bannerView.rootViewController = self
        addBannerViewToView(bannerView)
        bannerView.load(GADRequest())
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var image:UIImage? = nil
//        var scale:CGFloat = CGFloat(1)
//        var voiceName: String?
        let request: NSFetchRequest<SoineData> = SoineData.fetchRequest()
        
        loopFlag.isEnabled = false
        loopFlagTitleLabel.isEnabled = false
        
        interval.isEnabled = false
        intervalLabel.isEnabled = false
        intervalTitleLabel.isEnabled = false
        
        if targetId != nil {
            request.predicate = NSPredicate(format: "id = %d", targetId!)
        
            do {
                let fetchResults = try viewContext.fetch(request)
                if fetchResults.count != 0 {
                    for result: AnyObject in fetchResults {
                        let picture = result.value(forKey: "picture")
                        image = picture == nil ? UIImage() : UIImage(data: picture as! Data)
                        let soineData = result as! SoineData
                        
                        scale = CGFloat(soineData.scale)
                        imageData = soineData.picture
                        fileName = soineData.voiceName
                        fileExtention = soineData.voiceFileExtention
                        fileData = soineData.voiceData?.fileData
                        categoryId = soineData.categoryData?.categoryId
                        loopFlag.setOn(soineData.voiceLoopFlg, animated: false)
                        voiceLoopCount = Int(soineData.voiceLoopCount)
                        intervalLabel.text = "\(voiceLoopCount)回"
                        interval.setValue(Float(voiceLoopCount), animated: false)
                    }
                }
            } catch  let e as NSError{
                print("error !!! : \(e)")
            }
            //画像をセットする
            Utilities.settingBackground(playerView: &bg, _image: image ?? UIImage(),scale: scale!/2)
            if fileName != nil {
                voiceLabel.text = fileName
                loopFlag.isEnabled = true
                loopFlagTitleLabel.isEnabled = true
                if !loopFlag.isOn {
                    interval.isEnabled = true
                    intervalLabel.isEnabled = true
                    intervalTitleLabel.isEnabled = true
                }
            }
        }
        // アプリのバージョン
        if let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionLabel.text = version
        }
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
        
        //picker view
        selectedRow = 0
        pickerView.selectRow(0, inComponent: 0, animated: false)
        if targetId != nil && categoryId != nil{
            for (i,category) in categories.enumerated() {
                if categoryId == category.categoryId {
                    pickerView.selectRow(i + 1, inComponent: 0, animated: false)
                    selectedRow = i + 1
                    break
                }
            }
        }
        pickerView.reloadAllComponents()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // セクションの数を返します
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // それぞれのセクション毎に何行のセルがあるかを返します
        switch section {
        case 0: // 「設定」のセクション
            return 9
        case 1: // 「その他」のセクション
            return 0//要らないから表示しない
        default: // ここが実行されることはないはず
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                //画像
                callPhotoLibrary()
            }
            else if indexPath.row == 2 {
                //ボイス
//                let vc = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], in: .open) // とりあえずPDFを指定。.open以外にも.importとかいろいろあるので適宜変えてください。
//                vc.delegate = self
//                present(vc, animated: true, completion: nil)
                let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.wav,UTType.mp3])
                documentPicker.delegate = self
                self.present(documentPicker, animated: true, completion: nil)
//                callSoundLibrary()
                
                // クルクルスタート
                ActivityIndicator.startAnimating()
                // セルの選択を解除
//                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    @IBAction func touchDown_save(_ sender: Any) {
        var adCount = 0
        var dataCount = 0
        let request: NSFetchRequest<SoineData> = SoineData.fetchRequest()
        let request_ad: NSFetchRequest<SoineData> = SoineData.fetchRequest()
        do {
            request.predicate = NSPredicate(format: "adFlg = true")
            var fetchResults = try viewContext.fetch(request)
            adCount = fetchResults.count
            fetchResults = try viewContext.fetch(request_ad)
            dataCount = fetchResults.count
        }
        catch  let e as NSError{
            print("error !!! : \(e)")
        }
        
        if (addAd(dataCount: dataCount, adCount: adCount))
        {
            save(adFlag: true)//add ad
        }
        save(adFlag: false)
        
        let screenSizeWidth = UIScreen.main.bounds.width
        let screenSizeHeight = UIScreen.main.bounds.height
        let offsetY = self.tableView.contentOffset.y
        var hosei = offsetY
        if hosei < 0 {
            hosei = 0
        }
        print("tableview offset y : \(offsetY)")
        self.view.makeToast("ほぞん完了！", point: CGPoint(x: screenSizeWidth/2, y: screenSizeHeight/2+hosei), title: nil, image: nil, completion: nil)
    }
    func addAd(dataCount:Int,adCount:Int) -> Bool {
        let interval = 5
        let tekiseisu = Int(dataCount/interval)
        print("adCount : \(adCount),tekiseisu : \(tekiseisu)")
        return adCount < tekiseisu
    }
    func save(adFlag:Bool){
        let request: NSFetchRequest<SoineData> = SoineData.fetchRequest()
        let request_cat: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
        if targetId != nil {
//                request.predicate = NSPredicate(format: "id = \(targetId)")
            request.predicate = NSPredicate(format: "id = %d", targetId!)
        }
        
        var change = false
        //create voice data
        let entity_voice = NSEntityDescription.entity(forEntityName: "VoiceData", in: viewContext)
        let record_voice = NSManagedObject(entity: entity_voice!, insertInto: viewContext) as! VoiceData
//                record_voice.id = targetId!
        record_voice.fileData = fileData
        
        if selectedRow != 0 {
            request_cat.predicate = NSPredicate(format: "categoryId = %d", categories[selectedRow - 1].categoryId)
        }
        if adFlag {
            var rand = Int.random(in: 0...(categories.count - 1))
            var request: NSFetchRequest<SoineData> = SoineData.fetchRequest()
            request.predicate = NSPredicate(format: "categoryData.categoryId = %d", categories[rand].categoryId)
            do {
                var fetchResults = try viewContext.fetch(request)
                var upper = 10//フェールセーフ
                while upper > 0 {
                    if fetchResults.count != 0 {
                        let request2: NSFetchRequest<SoineData> = SoineData.fetchRequest()
                        request2.predicate = NSPredicate(format: "categoryData.categoryId = %d and adFlg = true", categories[rand].categoryId)
                        let fetchResults2 = try viewContext.fetch(request2)
                        if fetchResults2.count == 0 {
                            break
                        }
                        else{
                            print("loop - rand : \(rand)")
                            upper = upper - 1
                        }
                    }
                    else{
                        print("loop - rand : \(rand)")
                        upper = upper - 1
                    }
                    rand = Int.random(in: 0...(categories.count - 1))
                    request = SoineData.fetchRequest()
                    request.predicate = NSPredicate(format: "categoryData.categoryId = %d", categories[rand].categoryId)
                    fetchResults = try viewContext.fetch(request)
                }
                if upper <= 0 {
                    print("ループ上限")
                }
            } catch  let e as NSError{
                print("error !!! : \(e)")
            }
//            rand = Int.random(in: 0...(categories.count - 1))
            print("rand : \(rand)")
            request_cat.predicate = NSPredicate(format: "categoryId = %d", categories[rand].categoryId)
        }
        do {
            let fetchResults = try viewContext.fetch(request)
            let fetchResults_cat = try viewContext.fetch(request_cat)
            //change
            if(fetchResults.count != 0 && targetId != nil && !adFlag){
                change=true
                for result: AnyObject in fetchResults {
                    let record = result as! SoineData
                    record.id = targetId!
                    
                    //image
                    record.picture = imageData
                    if scale != nil {
                        record.scale = Float(scale!)
                    }
                    
                    //voice
                    record.voiceName = fileName
                    record.voiceFileExtention = fileExtention
                    record_voice.id = targetId!
                    record.voiceData = record_voice
                    record.voiceLoopFlg = loopFlag.isOn
                    record.voiceLoopCount = Int16(voiceLoopCount)
                    
                    //category
                    if selectedRow == 0 {
                        record.categoryData = nil
                    }
                    else{
                        record.categoryData = fetchResults_cat[0]
                    }
                    
                }
                try viewContext.save()
            }
            
            //add
            //ad - add
            //ad - change
            if !change || adFlag {
                let next_id = getNextId()
                let soineData = NSEntityDescription.entity(forEntityName: "SoineData", in: viewContext)
                let record = NSManagedObject(entity: soineData!, insertInto: viewContext) as! SoineData
                record.id = next_id
                
                //image
                record.picture = imageData
                if scale != nil {
                    record.scale = Float(scale!)
                }
                
                //voice
                record.voiceName = fileName
                record.voiceFileExtention = fileExtention
                record_voice.id = next_id
                record.voiceData = record_voice
                record.voiceLoopFlg = loopFlag.isOn
                record.voiceLoopCount = Int16(voiceLoopCount)
                
                //category
                if selectedRow == 0 && !adFlag{
                    record.categoryData = nil
                }
                else{
                    record.categoryData = fetchResults_cat[0]
                }
                
                //ad
                record.adFlg = adFlag
                
                appDelegate.saveContext()
                
                if !adFlag {
                    targetId = next_id
                }
            }
        } catch let e as NSError{
            print("error !!! : \(e)")
        }
    }
    @IBAction func editingChanged_interval(_ sender: Any) {
    }
    @IBAction func valueChanged_loopFlg(_ sender: Any) {
        interval.setNeedsLayout()
        interval.isEnabled = !loopFlag.isOn
        intervalLabel.isEnabled = !loopFlag.isOn
        intervalTitleLabel.isEnabled = !loopFlag.isOn
        
//        let indexPath = IndexPath(row: 5, section: 0)
//        tableView.reloadRows(at: [indexPath], with: .none)
    }
    @IBAction func valueChanged_interval(_ sender: Any) {
        print("interval value : \(interval.value)")
        voiceLoopCount = Int(round(interval.value))
        intervalLabel.text = "\(voiceLoopCount)回"
//        interval.setValue(v, animated: false)
    }
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("touchesEnded")
//    }
    
    deinit {
    // UserDefaultsの変更の監視を解除する
        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
    }
    
    //フォトライブラリを呼び出すメソッド
    func callPhotoLibrary(){
        //権限の確認
        requestAuthorizationOn()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            
            let picker = UIImagePickerController()
            picker.modalPresentationStyle = UIModalPresentationStyle.popover
            picker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //以下を設定することで、写真選択後にiOSデフォルトのトリミングViewが開くようになる
//            picker.allowsEditing = true
            if let popover = picker.popoverPresentationController {
                popover.sourceView = self.view
                popover.sourceRect = self.view.frame // ポップオーバーの表示元となるエリア
                popover.permittedArrowDirections = UIPopoverArrowDirection.any
            }
            self.present(picker, animated: true, completion: nil)
        }
    }
    // 写真へのアクセスがOFFのときに使うメソッド
    func requestAuthorizationOn(){
        var status:PHAuthorizationStatus
        if #available(iOS 14, *) {
            let accessLebel:PHAccessLevel = .addOnly
            status = PHPhotoLibrary.authorizationStatus(for: accessLebel)
        } else {
            // Fallback on earlier versions
            status = PHPhotoLibrary.authorizationStatus()
        }
        // authorization
        if (status != .authorized) {
//            if (status == PHAuthorizationStatus.denied) {
            //アクセス不能の場合。アクセス許可をしてもらう。snowなどはこれを利用して、写真へのアクセスを禁止している場合は先に進めないようにしている。
            //アラートビューで設定変更するかしないかを聞く
            let alert = UIAlertController(title: "写真へのアクセスを許可",
                                          message: "写真へのアクセスを許可する必要があります。設定を変更してください。",
                                          preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "設定変更", style: .default) { (_) -> Void in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString ) else {
                    return
                }
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
            alert.addAction(settingsAction)
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel) { _ in
                // ダイアログがキャンセルされた。つまりアクセス許可は得られない。
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    func getMaxId() -> Int16? {
        var max_id:Int16?
        do{
            let request_max: NSFetchRequest<SoineData> = SoineData.fetchRequest()
            request_max.fetchLimit = 1
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
            let sortDescriptors = [sortDescriptor]
            request_max.sortDescriptors = sortDescriptors
            let fetchResults = try viewContext.fetch(request_max)
            if fetchResults.count != 0 {
                max_id = fetchResults[0].id
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
}

///////////////////////////
///extentions
//////////////////////
///
//extension SettingsTableViewController:AVAudioPlayerDelegate{
//
//}
extension SettingsTableViewController:UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        // クルクルストップ
        ActivityIndicator.stopAnimating()
        if (CFURLStartAccessingSecurityScopedResource(url as CFURL)) {
            print(url) // ここにURLが入っている
            fileName = url.lastPathComponent
            fileExtention = url.pathExtension
            
            do {
                print("canOpenURL : \(UIApplication.shared.canOpenURL(url))")
                print("extention : \(fileExtention)")
                // AVAudioPlayerのインスタンス化
                fileData = try Data(contentsOf: url)
                
                print("Data : \(fileData)")
                
                
                
            } catch let e as NSError{
                print("error !!! : \(e)")
            }
            voiceLabel.text = fileName
            
            //enable change
            loopFlag.isEnabled = true
            loopFlagTitleLabel.isEnabled = true
            
            let indexPath = IndexPath(row: 2, section: 0)
            tableView.reloadRows(at: [indexPath], with: .none)
            CFURLStopAccessingSecurityScopedResource(url as CFURL) // <- and here
        }
        else {
            print("Permission error!")
        }
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController){
        // クルクルストップ
        ActivityIndicator.stopAnimating()
    }
}
extension SettingsTableViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let _image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
//            var predicate:NSPredicate
            // スクリーンの縦横サイズを取得
            let playerViewWidth:CGFloat = bg.frame.size.width
            print("frame width : \(playerViewWidth)")
//            print("playerViewWidth : \(playerViewWidth) , playerViewHeight : \(bg.frame.size.height)")
            
            // 画像の縦横サイズを取得
            let imgWidth:CGFloat = _image.size.width
            let imgHeight:CGFloat = _image.size.height
//            print("imgWidth : \(imgWidth)")
            print("image orientation : \(_image.imageOrientation.rawValue) , width : \(imgWidth) , height : \(imgHeight)")
            
            var image = _image
            //向き補正
//            if _image.imageOrientation != .up {
//                print("!!! image orientation do not up !!!")
//                image = UIImage(cgImage: _image.cgImage!, scale: _image.scale, orientation: .up)
//            }
            
            scale = playerViewWidth / imgWidth
            print("register scale : \(scale)")
            imageData = image.reSizeImage(size: CGSize(width: imgWidth, height: imgHeight))!.pngData()
            print("image data : \(imageData)")
            
            
            //背景設定
            Utilities.settingBackground(playerView: &bg, _image: image,scale: scale!/2)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension SettingsTableViewController:UIPickerViewDataSource,UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count + 1
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "-"
        }
        else{
            return categories[row - 1].name
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("pickerView didSelectRow")
        selectedRow = row
    }
}
