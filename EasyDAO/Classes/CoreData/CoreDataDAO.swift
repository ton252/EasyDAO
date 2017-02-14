//
//  CoreDataDAO.swift
//  DAO
//
//  Created by Антон Поляков on 14/02/2017.
//  Copyright © 2017 Антон Поляков. All rights reserved.
//

import CoreData

public class CoreDataDAO<Translator: CoreDataTranslator>: DAOProtocol {
    
    public typealias Entry = Translator.Entry
    public typealias Entity = Translator.Entity
    public typealias DataBase = NSPersistentContainer
    
    public var translator: Translator
    public var dataBase: DataBase
    
    public required init(translator: Translator, dataBase: DataBase) {
        self.translator = translator
        self.dataBase = dataBase
    }
    
    //MARK: Persisting Foreground
    
    @discardableResult public func persist(_ entity: Entity) -> Bool {
        let semafore = DispatchSemaphore(value: 0)
        var result = false
        persist(entity) { blockResult -> (Void) in
            result = blockResult
            semafore.signal()
        }
        semafore.wait()
        return result
    }
    
    @discardableResult public func persist(_ entities: [Entity]) -> Bool {
        let semafore = DispatchSemaphore(value: 0)
        var result = false
        persist(entities) { blockResult -> (Void) in
            result = blockResult
            semafore.signal()
        }
        semafore.wait()
        return result
    }
    
    //MARK: Persisting Background
    
    public func persist(_ entity: Entity, completion: @escaping (Bool)->(Void)) {
        self.performBackgroundTask { [unowned self] context in
            let request = Entry.fetchRequest()
            request.predicate = NSPredicate(format: "identifier = %@", entity.identifier)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            _ = try? context.execute(deleteRequest)
            
            let translator = self.translator.copy() as! Translator
            translator.context = context
            _ = translator.toEntry(entity)
            
            do {
                try context.save()
            } catch let error {
                print(error)
                completion(false)
            }
            completion(true)
        }
    }
    
    public func persist(_ entities: [Entity], completion: @escaping (Bool)->(Void)) {
        self.performBackgroundTask { [unowned self] context in
            let request = Entry.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            _ = try? context.execute(deleteRequest)
            
            let translator = self.translator.copy() as! Translator
            translator.context = context
            _ = translator.toEntries(entities)
            
            do {
                try context.save()
            } catch {
                completion(false)
            }
            completion(true)
        }
    }
    
    //MARK: Reading Foreground
    
    @discardableResult public func read(id: String) -> Entity? {
        let semafore = DispatchSemaphore(value: 0)
        var result: Entity? = nil
        read(id: id) { entity -> (Void) in
            result = entity
        }
        semafore.wait()
        return result
    }
    
    @discardableResult public func read() -> [Entity] {
        let semafore = DispatchSemaphore(value: 0)
        var result: [Entity] = []
        read { entities -> (Void) in
            result = entities
        }
        semafore.wait()
        return result
    }
    
    //MARK: Reading Background
    
    public func read(id: String, completion: @escaping (Entity?)->(Void)) {
        performBackgroundTask { [unowned self] context in
            if let result = self.read(id: id, inContext: context) {
                let entity = self.translator.toEntity(result)
                completion(entity)
            }
            completion(nil)
        }
    }
    
    public func read(completion: @escaping ([Entity])->(Void)) {
        performBackgroundTask { [unowned self] context in
            let result = self.read(predicate: nil, inContext: context)
            let entities = self.translator.toEntities(result)
            completion(entities)
        }
    }
    
    private func read(id: String, inContext context: NSManagedObjectContext) -> Entry? {
        let predicate = NSPredicate(format: "identifier = %@", id)
        return read(predicate: predicate, inContext: context).first
    }
    
    private func read(predicate: NSPredicate?, inContext context: NSManagedObjectContext) -> [Entry] {
        let request = Entry.fetchRequest()
        request.predicate = predicate
        do {
            let entries = try context.fetch(request) as? [Entry]
            return entries ?? []
        } catch {
            return []
        }
    }
    
    //MARK: Erasing
    
    @discardableResult public func erase(id: String) -> Bool {
        let semafore = DispatchSemaphore(value: 0)
        var result = false
        
        erase(id: id) { resultBlock -> (Void) in
            result = resultBlock
            semafore.signal()
        }
        semafore.wait()
        return result
    }
    
    @discardableResult public func erase() -> Bool {
        let semafore = DispatchSemaphore(value: 0)
        var result = false
        
        erase() { resultBlock -> (Void) in
            result = resultBlock
            semafore.signal()
        }
        semafore.wait()
        return result
    }
    
    //MARK: Erasing Background
    
    public func erase(id: String, completion: @escaping (Bool)->(Void)) {
        let request = Entry.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %@", id)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        performBackgroundTask { [unowned self] context in
            self.erase(request: deleteRequest, context: context, completion: completion)
        }
    }
    
    public func erase(completion: @escaping (Bool)->(Void)) {
        performBackgroundTask { [unowned self] context in
            let request = Entry.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            self.erase(request: deleteRequest, context: context, completion: completion)
        }
    }
    
    private func erase(request: NSBatchDeleteRequest,
                       context: NSManagedObjectContext,
                    completion: @escaping (Bool)->(Void)) {
        do {
            try context.execute(request)
            do {
                try context.save()
            } catch {
                completion(false)
            }
        } catch {
            completion(false)
        }
        
        completion(true)
    }
    
    
    //MARK: Helper Methods
    
    lazy var viewContext: NSManagedObjectContext = {
        return self.dataBase.viewContext
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        return self.dataBase.newBackgroundContext()
    }()
    
    func performForegroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.viewContext.perform {
            block(self.viewContext)
        }
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.dataBase.performBackgroundTask(block)
    }
}
