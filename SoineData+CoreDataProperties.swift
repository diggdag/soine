//
//  SoineData+CoreDataProperties.swift
//  
//
//  Created by 倉知諒 on 2022/04/29.
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
    @NSManaged public var voice: Data?
    @NSManaged public var voiceName: String?
    @NSManaged public var voiceFileExtention: String?

}
