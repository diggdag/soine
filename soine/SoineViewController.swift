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
        var voice: Data?
//        var voiceName: String?
        var voiceFileExtention: String?
        var loopFlag: Bool = true
        var voiceLoopCount:Int16 = 1
        
        

        var appDelegate:AppDelegate!
        var viewContext:NSManagedObjectContext!

        appDelegate = UIApplication.shared.delegate as? AppDelegate
        viewContext = appDelegate.persistentContainer.viewContext

        let request: NSFetchRequest<SoineData> = SoineData.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", targetId)

        do {
            let fetchResults = try viewContext.fetch(request)
            if fetchResults.count != 0 {
                for result: AnyObject in fetchResults {
                    if result.value(forKey: "picture") != nil {
                        image = UIImage(data: result.value(forKey: "picture") as! Data)
                    }
                    if result.value(forKey: "scale") != nil {
                        scale = result.value(forKey: "scale") as! CGFloat
                    }
                    let voiceData = result.value(forKey: "voiceData") as? VoiceData
                    voice = voiceData?.fileData
//                        voiceName = result.value(forKey: "voiceName") as? String
                    voiceFileExtention = result.value(forKey: "voiceFileExtention") as? String
                    if result.value(forKey: "voiceLoopFlg") != nil {
                        loopFlag = result.value(forKey: "voiceLoopFlg") as! Bool
                    }
                    if result.value(forKey: "voiceLoopCount") != nil {
                        voiceLoopCount = result.value(forKey: "voiceLoopCount") as! Int16
                    }
                }
            }
            
            //画像をセットする
            Utilities.settingBackground(playerView: &imageView, _image: image ?? UIImage(),scale: scale)
            
            //ここからボイス
            audioPlayer = try AVAudioPlayer(data: voice!,fileTypeHint: voiceFileExtention)

            // AVAudioPlayerのデリゲートをセット
            audioPlayer.delegate = self
            
            print("loop flag : \(loopFlag)")
            print("loop count : \(voiceLoopCount)")
            // 音声の再生
            var loopCnt = -1
            if !loopFlag {
                loopCnt = Int(voiceLoopCount-1)
            }
            audioPlayer.numberOfLoops = loopCnt
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch  let e as NSError{
            print("error !!! : \(e)")
        }
    }
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
}
///////////////////////////
///extentions
/////////////////////////
extension SoineViewController: AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        print("call audioPlayerDidFinishPlaying !!!")
    }
}
