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
    @IBOutlet weak var imageView: UIView!
    
    var appDelegate:AppDelegate!
    var viewContext:NSManagedObjectContext!
    var audioPlayer:AVAudioPlayer!
    var targetId:Int16 = 0
    var voiceFilePath:URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("-------------- SoineViewController viewDidLoad --------------")
        //アプリがバックグラウンドになった時に呼ばれるメソッドを設定
        NotificationCenter.default.addObserver(self, selector: #selector(SoineViewController.didEnterBackgroundNotification(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SoineViewController.willTerminateNotification(_:)), name: UIApplication.willTerminateNotification, object: nil)
        var image:UIImage? = nil
        var scale:CGFloat = CGFloat(1)
        

        var appDelegate:AppDelegate!
        var viewContext:NSManagedObjectContext!

        appDelegate = UIApplication.shared.delegate as? AppDelegate
        viewContext = appDelegate.persistentContainer.viewContext

        let query: NSFetchRequest<SoineData> = SoineData.fetchRequest()

        do {
            let fetchResults = try viewContext.fetch(query)
            if fetchResults.count != 0 {
                for result: AnyObject in fetchResults {
                    let id: Int16 = result.value(forKey: "id") as! Int16

                    if targetId == id {
                        image = UIImage(data: result.value(forKey: "picture") as! Data)
                        scale = result.value(forKey: "scale") as! CGFloat
                                                
                        voiceFilePath = (result.value(forKey: "voiceFilePath") as? URL)!
                        break
                    }
                }
            }
            
            //画像をセットする
            Utilities.settingBackground(playerView: &imageView, _image: image ?? UIImage(),scale: scale,initial: true)
            
            //ここからボイス
            if voiceFilePath != nil {
                if voiceFilePath!.startAccessingSecurityScopedResource() {
//                    let fileName = voiceFilePath!.lastPathComponent
                    let fileExtention = voiceFilePath!.pathExtension
                    Task{
                        let fileData = try await self.read()
                        print("Data : \(fileData)")
                        audioPlayer = try AVAudioPlayer(data: fileData,fileTypeHint: fileExtention)

                        // AVAudioPlayerのデリゲートをセット
                        audioPlayer.delegate = self

                        // 音声の再生
                        audioPlayer.prepareToPlay()
                        audioPlayer.play()
                    }
//                    let fileData = try Data(contentsOf: voiceFilePath!)
                }
//                if (CFURLStartAccessingSecurityScopedResource(voiceFilePath! as CFURL)) {
//                    CFURLStopAccessingSecurityScopedResource(voiceFilePath! as CFURL)
//                }
                else {
                    print("Permission error!")
                }
            }
            //ここまでボイス
        } catch  let e as NSError{
            print("error !!! : \(e)")
        }
        
//        appDelegate = UIApplication.shared.delegate as? AppDelegate
//        viewContext = appDelegate.persistentContainer.viewContext
//        Utilities.setBackground_init(playerView: &imageView, _id: Consts.IMAGE_ID_SOINE,toSoine: true)
    }
    func read() async throws -> Data {
        let url = try await NSFileCoordinator().coordinate(readingItemAt: self.voiceFilePath!)
            return try Data(contentsOf: url)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("ViewController viewWillDisappear")
//        CFURLStopAccessingSecurityScopedResource(voiceFilePath! as CFURL)
//        voiceFilePath?.stopAccessingSecurityScopedResource()
    }
    
    @objc func didEnterBackgroundNotification(_ notification: NSNotification?) {
        print("ViewController didEnterBackgroundNotification")
//        CFURLStopAccessingSecurityScopedResource(voiceFilePath! as CFURL)
//        dismiss(animated: true)
    }
    @objc func willTerminateNotification(_ notification: NSNotification?) {
        print("ViewController willTerminateNotification")
//        CFURLStopAccessingSecurityScopedResource(voiceFilePath! as CFURL)
//        voiceFilePath?.stopAccessingSecurityScopedResource()
//        dismiss(animated: true)
    }
}
///////////////////////////
///extentions
//////////////////////
///
extension SoineViewController: AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        print("call audioPlayerDidFinishPlaying !!!")
    }
}
