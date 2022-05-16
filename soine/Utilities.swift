//
//  Utilities.swift
//  soine
//
//  Created by 倉知諒 on 2022/04/23.
//

import UIKit
import CoreData

class Utilities {
    
    //背景画像を設定
    //  playerView:プレイヤービュー
    //  setImage:背景画像
    static func settingBackground(playerView : inout UIView, _image : UIImage,scale:CGFloat)  {
//        print("settingBackground method called!")
        print("playerViewWidth : \(playerView.frame.size.width) , playerViewHeight : \(playerView.frame.size.height)")
        print("引数scale:\(scale)")
        print("image orientation : \(_image.imageOrientation.rawValue)")
        // 画像の縦横サイズを取得
        let imgWidth:CGFloat = _image.size.width
        let imgHeight:CGFloat = _image.size.height
        print("image width : \(imgWidth) , height : \(imgHeight)")
        let image = _image
        let imageView = UIImageView(image:image)
//        imageView.alpha = 0.6
        
        // 画像サイズをスクリーン幅に合わせる
        let rect:CGRect =
            CGRect(x:0, y:0, width:imgWidth * scale, height:imgHeight * scale)
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
    }
}
