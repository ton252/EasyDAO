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
    private var database: Dictionary<String, Any>
    
    public required init(translator: Translator, jsonName: String) {
        self.translator = translator
        database = [:]
        //self.dataBase = realm
    }
    
    //MARK: Persisting
    
    @discardableResult public func persist(_ entity: Entity) -> Bool {
        //var database =
        return true
    }
    
    @discardableResult public func persist(_ entities: [Entity]) -> Bool {
        return true
    }
    
    private func persistWithoutSaving(_ entity: Entity) -> Void {
        
    }
    
    //MARK: Reading
    
    @discardableResult public func read(id: String) -> Entity? {
        return nil
    }
    
    @discardableResult public func read(predicate: NSPredicate?) -> [Entity] {
        return []
    }
    
    //MARK: Erasing
    
    @discardableResult public func erase(id: String) -> Bool {
        return true
    }
    
    @discardableResult public func erase() -> Bool {
        return true
    }
    
    //MARK: Helpers
    
//    private func createDatabase() throws -> Void {
//        
//        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        
//        guard let documentsDirectory = paths.first else {
//            throw JSONStorageDAOError.couldntFindDocumetsPath
//        }
//        
//        do {
//            try FileManager.default.createDirectory(atPath: documentsDirectory, withIntermediateDirectories: false, attributes: nil)
//        } catch let error as NSError {
//            throw JSONStorageDAOError.couldntCreateDataBaseFile
//        }
//        
//    }
//    
//    private func synchronized(lock: AnyObject, closure: () -> ()) {
//        objc_sync_enter(lock)
//        closure()
//        objc_sync_exit(lock)
//    }
    
    
}

//enum JSONStorageDAOError: Error {
//    case couldntFindDocumetsPath
//    case couldntCreateDataBaseFile
//}

