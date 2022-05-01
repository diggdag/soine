//
//  TableViewCell_list.swift
//  soine
//
//  Created by 倉知諒 on 2022/04/30.
//

import UIKit
class TableViewCell_list: UITableViewCell {
    @IBOutlet weak var soineImg: UIImageView!
    @IBOutlet weak var voiceName: UILabel!
    @IBOutlet weak var btn: UIButton!
    func setCell(data: Data_list) {
        voiceName.text = data.voiceName
        soineImg.image = data.soineImg
    }
}

class Data_list {
    var voiceName: String
    var soineImg: UIImage
    init(voiceName: String, category: UIImage) {
        self.voiceName = voiceName
        self.soineImg = category
    }
}
