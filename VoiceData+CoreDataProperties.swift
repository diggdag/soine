//
//  VoiceData+CoreDataProperties.swift
//  
//
//  Created by 倉知諒 on 2022/07/06.
//
//

import Foundation
import CoreData


extension VoiceData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VoiceData> {
        return NSFetchRequest<VoiceData>(entityName: "VoiceData")
    }

    @NSManaged public var fileData: Data?
    @NSManaged public var id: Int16
    @NSManaged public var soineData: SoineData?

}
