//
//  JSONStorage.swift
//  Pods
//
//  Created by Антон Поляков on 22/02/2017.
//
//

import Foundation


public class JSONStorageDAO<Translator: JSONStorageTranslatorProtocol>: DAOProtocol {
    
    public typealias Entry = Translator.Entry
    public typealias Entity = Translator.Entity
    
    public let translator: Translator
    private var database: JSONDataBase
    
    public required init(translator: Translator, jsonDataBase: JSONDataBase) {
        self.translator = translator
        database = jsonDataBase
    }
    
    //MARK: Persisting
    
    @discardableResult public func persist(_ entity: Entity) -> Bool {
        let entry = self.translator.toEntry(entity)
        database.persist(entry)
        return true
    }
    
    @discardableResult public func persist(_ entities: [Entity]) -> Bool {
        let entries = self.translator.toEntries(entities)
        database.persist(entries)
        return true
    }
    
    //MARK: Reading
    
    @discardableResult public func read(id: String) -> Entity? {
        if let entry = database.object(ofType: Entry.self, forPrimaryKey: id) {
            return self.translator.toEntity(entry)
        }
        return nil
    }
    
    @discardableResult public func read(predicate: NSPredicate?) -> [Entity] {
        let entries = database.objects(Entry.self, predicate: predicate)
        return self.translator.toEntities(entries)
    }
    
    //MARK: Erasing
    
    @discardableResult public func erase(id: String) -> Bool {
        self.database.erase(ofType: Entry.self, forPrimaryKey: id)
        return true
    }
    
    @discardableResult public func erase() -> Bool {
        self.database.eraseAll()
        return true
    }
    
}

