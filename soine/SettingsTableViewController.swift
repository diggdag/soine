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
    
    var appDelegate:AppDelegate!
    var viewContext:NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        viewContext = appDelegate.persistentContainer.viewContext
        var image:UIImage? = nil
        var scale:CGFloat = CGFloat(1)
        var voiceName: String?
        let query: NSFetchRequest<SoineData> = SoineData.fetchRequest()

        do {
            let fetchResults = try viewContext.fetch(query)
            if fetchResults.count != 0 {
                for result: AnyObject in fetchResults {
                    let id: Int16 = result.value(forKey: "id") as! Int16

                    if Consts.IMAGE_ID_SOINE == id {
                        image = UIImage(data: result.value(forKey: "picture") as! Data)
                        scale = result.value(forKey: "scale") as! CGFloat
                        voiceName = result.value(forKey: "voiceName") as? String
                    }
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
        
//        Utilities.setBackground_init(playerView: &bg, _id: 0)
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
    
    func callSoundLibrary() {
        let pickerController = MPMediaPickerController(mediaTypes: .music)
        pickerController.prompt = "Select Song"
        pickerController.delegate = self
        present(pickerController, animated: true)
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
        print(url) // ここにURLが入っている
        let fileName = url.lastPathComponent
        let fileExtention = url.pathExtension
//        let audioPath = Bundle.main.path(forResource: url.path, ofType:"wav")!
//        let audioUrl = URL(fileURLWithPath: audioPath)
//        let audioUrl = URL(string: url.path)!
//        let audioUrl = URL(fileURLWithPath: url.path)
        
        
        do {
            print("canOpenURL : \(UIApplication.shared.canOpenURL(url))")
            print("extention : \(fileExtention)")
            // AVAudioPlayerのインスタンス化
//            let audioPlayer = try AVAudioPlayer(contentsOf: url,fileTypeHint: url.pathExtension)
            let fileData = try Data(contentsOf: url)
            
            print("Data : \(fileData)")
            
            let request: NSFetchRequest<SoineData> = SoineData.fetchRequest()
            var predicate:NSPredicate
            predicate = NSPredicate(format: "id = \(Consts.IMAGE_ID_SOINE)")
            request.predicate = predicate
            var change = false
            //change
            let fetchResults = try viewContext.fetch(request)
            if(fetchResults.count != 0){
                change = true
                for result: AnyObject in fetchResults {
                    let record = result as! NSManagedObject
                    record.setValue(Consts.IMAGE_ID_SOINE, forKey: "id")
                    record.setValue(fileName, forKey: "voiceName")
                    record.setValue(fileExtention, forKey: "voiceFileExtention")
                    record.setValue(fileData, forKey: "voice")
                }
                try viewContext.save()
            }
            //add
            if !change {
                let background = NSEntityDescription.entity(forEntityName: "SoineData", in: viewContext)
                let newRecord = NSManagedObject(entity: background!, insertInto: viewContext)
                newRecord.setValue(Consts.IMAGE_ID_SOINE, forKey: "id")
                newRecord.setValue(fileName, forKey: "voiceName")
                newRecord.setValue(fileExtention, forKey: "voiceFileExtention")
                newRecord.setValue(fileData, forKey: "voice")
                appDelegate.saveContext()
            }
//            let audioPlayer = try AVAudioPlayer(contentsOf: url)//要らん処理
        } catch let e as NSError{
            print("error !!! : \(e)")
        }
        voiceLabel.text = fileName
    }
}
extension SettingsTableViewController:MPMediaPickerControllerDelegate{
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        let theChosenSong = mediaItemCollection.items[0]
        let songTitle = theChosenSong.value(forProperty: MPMediaItemPropertyTitle) as? String
        let assetURL = theChosenSong.value(forProperty: MPMediaItemPropertyAssetURL) as? URL
        var songAsset: AVURLAsset? = nil
        if let assetURL = assetURL {
            songAsset = AVURLAsset(url: assetURL, options: nil)
        }
    }
}
extension SettingsTableViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let _image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            let request: NSFetchRequest<SoineData> = SoineData.fetchRequest()
            var predicate:NSPredicate
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
            
            predicate = NSPredicate(format: "id = \(Consts.IMAGE_ID_SOINE)")
            request.predicate = predicate
            
            var change = false
            
//            let imageData = UIImage.pngData(image.reSizeImage(size: CGSize(width: imgWidth, height: imgHeight))!)
                        
            let imageData = image.reSizeImage(size: CGSize(width: imgWidth, height: imgHeight))!.pngData()
            print("image data : \(imageData)")
            
            //change
            do {
                let fetchResults = try viewContext.fetch(request)
                if(fetchResults.count != 0){
                    change=true
                    for result: AnyObject in fetchResults {
                        let record = result as! NSManagedObject
                        record.setValue(Consts.IMAGE_ID_SOINE, forKey: "id")
                        record.setValue(imageData, forKey: "picture")
//                        record.setValue(image.pngData(), forKey: "picture")
                        record.setValue(scale, forKey: "scale")
                    }
                    try viewContext.save()
                }
            } catch {
            }
            //add
            if !change {
                let background = NSEntityDescription.entity(forEntityName: "SoineData", in: viewContext)
                let newRecord = NSManagedObject(entity: background!, insertInto: viewContext)
                newRecord.setValue(Consts.IMAGE_ID_SOINE, forKey: "id")
                newRecord.setValue(imageData, forKey: "picture")
                newRecord.setValue(scale, forKey: "scale")
                appDelegate.saveContext()
            }
            
            //背景設定
            Utilities.settingBackground(playerView: &bg, _image: image,scale: scale)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

