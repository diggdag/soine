//
//  SoineData+CoreDataProperties.swift
//  
//
//  Created by 倉知諒 on 2022/07/06.
//
//

import Foundation
import CoreData


extension SoineData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SoineData> {
        return NSFetchRequest<SoineData>(entityName: "SoineData")
    }

    @NSManaged public var id: Int16
    @NSManaged public var picture: Data?
    @NSManaged public var scale: Float
    @NSManaged public var voiceFileExtention: String?
    @NSManaged public var voiceLoopCount: Int16
    @NSManaged public var voiceLoopFlg: Bool
    @NSManaged public var voiceName: String?
    @NSManaged public var categoryData: CategoryData?
    @NSManaged public var voiceData: VoiceData?

}
