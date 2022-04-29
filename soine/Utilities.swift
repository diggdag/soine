//
//  Utilities.swift
//  soine
//
//  Created by 倉知諒 on 2022/04/23.
//

import UIKit
import CoreData

class Utilities {
    
    //背景設定初期メソッド（DBから読み込む）
    static func setBackground_init(playerView : inout UIView,_id:Int16,toSoine:Bool = false)  {
//        print("setBackground_init method called!")
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
                    
                    if id == _id {
                        image = UIImage(data: result.value(forKey: "picture") as! Data)
                        
                        // from soine
//                        if toSoine {
//                            // スクリーンの縦横サイズを取得
//                            let playerViewWidth:CGFloat = playerView.frame.size.width
//                            let playerViewHeight:CGFloat = playerView.frame.size.height
//                            print("playerViewWidth : \(playerViewWidth) , playerViewHeight : \(playerViewHeight)")
//
//                            // 画像の縦横サイズを取得
//                            let imgWidth:CGFloat = image!.size.width
//                            let imgHeight:CGFloat = image!.size.height
//                            print("imgWidth : \(imgWidth) , imgHeight : \(imgHeight)")
//
//                            //スケール
//                            let scaleW = playerViewWidth / imgWidth
//                            let scaleH = playerViewHeight / imgHeight
//                            print("scale width : \(scaleW) , scale height : \(scaleH)")
//
//                            scale = scaleW
//                        }
//                        else{
                            scale = result.value(forKey: "scale") as! CGFloat
//                        }
                        
                    }
                }
            }
            self.settingBackground(playerView: &playerView, _image: image ?? UIImage(),scale: scale,initial: true)
        } catch {
        }
    }
    //背景画像を設定
    //  playerView:プレイヤービュー
    //  setImage:背景画像
    static func settingBackground(playerView : inout UIView, _image : UIImage,scale:CGFloat,initial:Bool = false)  {
//        print("settingBackground method called!")
        print("playerViewWidth : \(playerView.frame.size.width) , playerViewHeight : \(playerView.frame.size.height)")
        print("引数scale:\(scale)")
        print("image orientation : \(_image.imageOrientation.rawValue)")
        
        // 画像の縦横サイズを取得
        let imgWidth:CGFloat = _image.size.width
        let imgHeight:CGFloat = _image.size.height
        
        print("image width : \(imgWidth) , height : \(imgHeight)")
        
        var image = _image
        
//        if imgWidth > imgHeight {
//            print("!!! width > height !!!")
//            image = UIImage(cgImage: _image.cgImage!, scale: _image.scale, orientation: .up)
//            print("fixed -> orientation : \(image.imageOrientation.rawValue) , width : \(image.size.width) , height : \(image.size.height)")
//        }
//        let image = self.fixOrientation(img: _image)
//        print("image orientation after : \(image.imageOrientation.rawValue)")
        
        let imageView = UIImageView(image:image)
//        imageView.alpha = 0.6
        
        // 画像サイズをスクリーン幅に合わせる
        let rect:CGRect =
            CGRect(x:0, y:0, width:imgWidth * scale, height:imgHeight * scale)
//        let rect:CGRect =
//            CGRect(x:0, y:0, width:playerView.frame.size.width, height:playerView.frame.size.height)
        
        imageView.frame = rect;
        
        // UIImageViewのインスタンスをビューに追加
        imageView.tag = 100
        
        //画像のviewを削除
        if let viewWithTag = playerView.viewWithTag(100){
            viewWithTag.removeFromSuperview()
        }
        
        if playerView.subviews.count == 0 {
            playerView.addSubview(imageView)
        }
        else{
            var b:Bool = true
            for subView in playerView.subviews{
                if b{
                    playerView.addSubview(imageView)
                    b=false
                }
                playerView.addSubview(subView)
            }
        }
    }
    static func fixOrientation(img: UIImage) -> UIImage {
        print("image width : \(img.size.width) , height : \(img.size.height)")
        if (img.imageOrientation == .up) {
            return img
        }
        
        return UIImage(cgImage: img.cgImage!, scale: img.scale, orientation: .up)
//        return img.imageOrientation = .right
//            
//        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
//        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
//        img.draw(in: rect)
//            
//        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//            
//       return normalizedImage
    }
}
