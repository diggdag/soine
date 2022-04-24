//
//  Background+CoreDataProperties.swift
//  
//
//  Created by 倉知諒 on 2022/04/23.
//
//

import Foundation
import CoreData


extension Background {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Background> {
        return NSFetchRequest<Background>(entityName: "Background")
    }

    @NSManaged public var picture: Data?
    @NSManaged public var id: Int16
    @NSManaged public var scale: Float

}
