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

class SettingsTableViewController: UITableViewController{

    @IBOutlet weak var bg: UIView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var voiceLabel: UILabel!
    var targetId:Int16? = nil
    
    var appDelegate:AppDelegate!
    var viewContext:NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        viewContext = appDelegate.persistentContainer.viewContext
        var image:UIImage? = nil
        var scale:CGFloat = CGFloat(1)
        var voiceName: String?
        let request: NSFetchRequest<SoineData> = SoineData.fetchRequest()

        if targetId != nil {
            request.predicate = NSPredicate(format: "id = %d", targetId!)
        
            do {
                let fetchResults = try viewContext.fetch(request)
                if fetchResults.count != 0 {
                    for result: AnyObject in fetchResults {
                        var picture = result.value(forKey: "picture")
                        image = picture == nil ? UIImage() : UIImage(data: picture as! Data)
                        scale = result.value(forKey: "scale") as! CGFloat
                        voiceName = result.value(forKey: "voiceName") as? String
                    }
                }
            } catch  let e as NSError{
                print("error !!! : \(e)")
            }
            //画像をセットする
            Utilities.settingBackground(playerView: &bg, _image: image ?? UIImage(),scale: scale,initial: true)
            if voiceName != nil {
                voiceLabel.text = voiceName
            }
        }
        // アプリのバージョン
        if let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionLabel.text = version
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // セクションの数を返します
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // それぞれのセクション毎に何行のセルがあるかを返します
        switch section {
        case 0: // 「設定」のセクション
            return 3
        case 1: // 「その他」のセクション
            return 2
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
            }
        }
    }

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
        if (CFURLStartAccessingSecurityScopedResource(url as CFURL)) {
            print(url) // ここにURLが入っている
            let fileName = url.lastPathComponent
            let fileExtention = url.pathExtension
            
            do {
                print("canOpenURL : \(UIApplication.shared.canOpenURL(url))")
                print("extention : \(fileExtention)")
                // AVAudioPlayerのインスタンス化
                let fileData = try Data(contentsOf: url)
                
                print("Data : \(fileData)")
                
                let request: NSFetchRequest<SoineData> = SoineData.fetchRequest()
//                var predicate:NSPredicate
//                predicate =
                if targetId != nil {
//                    request.predicate = NSPredicate(format: "id = \(targetId)")
                    request.predicate = NSPredicate(format: "id = %d", targetId!)
                }
                
                //create voice data
                let entity_voice = NSEntityDescription.entity(forEntityName: "VoiceData", in: viewContext)
                let record_voice = NSManagedObject(entity: entity_voice!, insertInto: viewContext) as! VoiceData
//                record_voice.id = targetId!
                record_voice.fileData = fileData
                
                var change = false
                //change
                let fetchResults = try viewContext.fetch(request)
                if(fetchResults.count != 0 && targetId != nil){
                    change = true
                    for result: AnyObject in fetchResults {
                        let record = result as! SoineData
                        record.id = targetId!
                        record.voiceName = fileName
                        record.voiceFileExtention = fileExtention
                        record_voice.id = targetId!
                        record.voiceData = record_voice
                    }
                    try viewContext.save()
                }
                //add
                if !change {
                    var next_id = getNextId()
                    
                    let soineData = NSEntityDescription.entity(forEntityName: "SoineData", in: viewContext)
                    let record = NSManagedObject(entity: soineData!, insertInto: viewContext) as! SoineData
                    record.id = next_id
                    record.voiceName = fileName
                    record.voiceFileExtention = fileExtention
                    record_voice.id = next_id
                    record.voiceData = record_voice
                    
                    appDelegate.saveContext()
                    targetId = next_id
                }
            } catch let e as NSError{
                print("error !!! : \(e)")
            }
            voiceLabel.text = fileName
            CFURLStopAccessingSecurityScopedResource(url as CFURL) // <- and here
        }
        else {
            print("Permission error!")
        }
    }
}
extension SettingsTableViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let _image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            let request: NSFetchRequest<SoineData> = SoineData.fetchRequest()
//            var predicate:NSPredicate
            // スクリーンの縦横サイズを取得
            let playerViewWidth:CGFloat = bg.frame.size.width
//            print("playerViewWidth : \(playerViewWidth) , playerViewHeight : \(bg.frame.size.height)")
            
            // 画像の縦横サイズを取得
            let imgWidth:CGFloat = _image.size.width
            let imgHeight:CGFloat = _image.size.height
//            print("imgWidth : \(imgWidth)")
            print("orientation : \(_image.imageOrientation.rawValue) , width : \(_image.size.width) , height : \(_image.size.height)")
            
            var image = _image
            //向き補正
//            if _image.imageOrientation != .up {
//                print("!!! image orientation do not up !!!")
//                image = UIImage(cgImage: _image.cgImage!, scale: _image.scale, orientation: .up)
//            }
            
            let scale:CGFloat = playerViewWidth / imgWidth
            
//            predicate =
            if targetId != nil {
//                request.predicate = NSPredicate(format: "id = \(targetId)")
                request.predicate = NSPredicate(format: "id = %d", targetId!)
            }
            
            
            var change = false
            
//            let imageData = UIImage.pngData(image.reSizeImage(size: CGSize(width: imgWidth, height: imgHeight))!)
                        
            let imageData = image.reSizeImage(size: CGSize(width: imgWidth, height: imgHeight))!.pngData()
            print("image data : \(imageData)")
            
            //change
            do {
                let fetchResults = try viewContext.fetch(request)
                if(fetchResults.count != 0 && targetId != nil){
                    change=true
                    for result: AnyObject in fetchResults {
                        let record = result as! SoineData
                        record.id = targetId!
                        record.picture = imageData
                        record.scale = Float(scale)
                    }
                    try viewContext.save()
                }
            } catch {
            }
            //add
            if !change {
                let next_id = getNextId()
                let soineData = NSEntityDescription.entity(forEntityName: "SoineData", in: viewContext)
                let record = NSManagedObject(entity: soineData!, insertInto: viewContext) as! SoineData
                record.id = next_id
                record.picture = imageData
                record.scale = Float(scale)
                appDelegate.saveContext()
                targetId = next_id
            }
            
            //背景設定
            Utilities.settingBackground(playerView: &bg, _image: image,scale: scale)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

