//
//  Country+CoreDataProperties.swift
//  CoredataMultithreaded
//
//  Created by Mahir Abdi on 25/04/16.
//  Copyright © 2016 kaushal. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Country {

    @NSManaged var country_id: String?
    @NSManaged var name: String?
    @NSManaged var newRelationship: NSManagedObject?

}
