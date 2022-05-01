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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("-------------- SoineViewController viewDidLoad --------------")
        var image:UIImage? = nil
        var scale:CGFloat = CGFloat(1)
        var voiceFilePath:URL?
        

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
                if (CFURLStartAccessingSecurityScopedResource(voiceFilePath! as CFURL)) {
                
                    let fileName = voiceFilePath!.lastPathComponent
                    let fileExtention = voiceFilePath!.pathExtension
                    let fileData = try Data(contentsOf: voiceFilePath!)
                    
                    
                    print("Data : \(fileData)")
                    audioPlayer = try AVAudioPlayer(data: fileData,fileTypeHint: fileExtention)

                    // AVAudioPlayerのデリゲートをセット
                    audioPlayer.delegate = self

                    // 音声の再生
                    audioPlayer.prepareToPlay()
                    audioPlayer.play()
                    CFURLStopAccessingSecurityScopedResource(voiceFilePath! as CFURL)
                }
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
