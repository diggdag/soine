//
//  CategoryData+CoreDataProperties.swift
//  
//
//  Created by 倉知諒 on 2022/07/06.
//
//

import Foundation
import CoreData


extension CategoryData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryData> {
        return NSFetchRequest<CategoryData>(entityName: "CategoryData")
    }

    @NSManaged public var categoryId: Int16
    @NSManaged public var name: String?
    @NSManaged public var soineData: NSSet?

}

// MARK: Generated accessors for soineData
extension CategoryData {

    @objc(addSoineDataObject:)
    @NSManaged public func addToSoineData(_ value: SoineData)

    @objc(removeSoineDataObject:)
    @NSManaged public func removeFromSoineData(_ value: SoineData)

    @objc(addSoineData:)
    @NSManaged public func addToSoineData(_ values: NSSet)

    @objc(removeSoineData:)
    @NSManaged public func removeFromSoineData(_ values: NSSet)

}
