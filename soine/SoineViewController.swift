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
                        let voiceData = result.value(forKey: "voiceData") as? VoiceData
                        voice = voiceData?.fileData
//                        voiceName = result.value(forKey: "voiceName") as? String
                        voiceFileExtention = result.value(forKey: "voiceFileExtention") as? String
                    }
                }
            }
            
            //画像をセットする
            Utilities.settingBackground(playerView: &imageView, _image: image ?? UIImage(),scale: scale,initial: true)
            
            //ここからボイス
            audioPlayer = try AVAudioPlayer(data: voice!,fileTypeHint: voiceFileExtention)

            // AVAudioPlayerのデリゲートをセット
            audioPlayer.delegate = self

            // 音声の再生
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch  let e as NSError{
            print("error !!! : \(e)")
        }
    }
}
///////////////////////////
///extentions
/////////////////////////
extension SoineViewController: AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        print("call audioPlayerDidFinishPlaying !!!")
    }
}
