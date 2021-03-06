//
//  RealmDAO.swift
//  DAO
//
//  Created by Антон Поляков on 13/02/2017.
//  Copyright © 2017 Антон Поляков. All rights reserved.
//

import RealmSwift
import Foundation

public class RealmDAO<Translator: RealmTranslatorProtocol>: DAOProtocol {
    
    public typealias Entry = Translator.Entry
    public typealias Entity = Translator.Entity
    
    public let translator: Translator
    private let dataBase: Realm
    
    public required init(translator: Translator, realm: Realm) {
        self.translator = translator
        self.dataBase = realm
    }
    
    //MARK: Persisting
    
    @discardableResult public func persist(_ entity: Entity) -> Bool {
        do {
            try dataBase.write { [unowned self] in
                self.persistWithoutSaving(entity)
            }
        } catch {
            return false
        }
        return true
    }
    
    @discardableResult public func persist(_ entities: [Entity]) -> Bool {
        do {
            try dataBase.write { [unowned self] in
                entities.forEach{ self.persistWithoutSaving($0) }
            }
        } catch {
            return false
        }
        return true
    }
    
    private func persistWithoutSaving(_ entity: Entity) -> Void {
        let pk = entity.identifier
        let oldEntry = dataBase.object(ofType: Entry.self, forPrimaryKey: pk)
        if let oldEntry = oldEntry {
            self.dataBase.delete(oldEntry)
        }
        let entry = translator.toEntry(entity)
        dataBase.add(entry)
    }
    
     //MARK: Reading
    
    public func read(id: String) -> Entity? {
        if let entity = dataBase.object(ofType: Entry.self, forPrimaryKey: id) {
            return translator.toEntity(entity)
        }
        return nil
    }
    
    public func read(predicate: NSPredicate?) -> [Entity] {
        var result = dataBase.objects(Translator.Entry.self)
        
        if let predicate = predicate {
            result = result.filter(predicate)
        }
        
        let entries = Array(result)
        return translator.toEntities(entries)
    }
    
    //MARK: Erasing
    
    @discardableResult public func erase(id: String) -> Bool {
        let entry = dataBase.object(ofType: Entry.self, forPrimaryKey: id)
        guard entry != nil else { return false }
        do {
            try dataBase.write {
                self.dataBase.delete(entry!)
            }
        } catch {
            return false
        }
        return true
    }
    
    @discardableResult public func erase() -> Bool {
        let entries = dataBase.objects(Translator.Entry.self)
        do {
            try dataBase.write { [unowned self] in
                self.dataBase.delete(entries)
            }
        } catch {
            return false
        }
        return true
    }
}

