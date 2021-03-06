//
//  CoreDataTranslatorProtocol.swift
//  DAO
//
//  Created by Антон Поляков on 14/02/2017.
//  Copyright © 2017 Антон Поляков. All rights reserved.
//

import CoreData

public protocol CoreDataTranslatorProtocol: TranslatorProtocol, NSCopying {
    associatedtype Entry: NSManagedObject
    var context: NSManagedObjectContext? { get set }
}
