//
//  Storage.swift
//  1
//
//  Created by Антон Поляков on 23/02/2017.
//  Copyright © 2017 Антон Поляков. All rights reserved.
//

import Foundation

public class JSONDataBase {
    
    public enum JSONDataBaseError: Error {
        case initializationFailed(String)
        case readingFailed(String)
        case writingFailed(String)
        case unknownError
    }
    
    private static var sharedInstance: JSONDataBase!
    private(set) var fileName: String
    private var objects: Set<BaseObject> = []
    private let fileManager = FileManager.default
    private let queue = OperationQueue()
    
    private var fileURL: URL {
        get {
            let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            return url.appendingPathComponent("\(fileName).json")
        }
    }
    
    private var isStorageFileExist: Bool {
        get {
            return fileManager.fileExists(atPath: fileURL.path)
        }
    }
    
    //MARK: Initialization
    
    public init(fileName: String) throws {
        self.fileName = fileName
        queue.maxConcurrentOperationCount = 1
        try initDataBaseFile()
    }
    
    public static func shared(name: String) throws -> JSONDataBase {
        switch (sharedInstance, name) {
        case let (nil, name):
            do {
                sharedInstance = try JSONDataBase(fileName: name)
                return sharedInstance
            } catch let error {
                throw error
            }
        default:
            throw JSONDataBaseError.initializationFailed("Coulnd't change name after initialization")
        }
        
    }
    
    private func initDataBaseFile() throws -> Void {
        if isStorageFileExist {
            return try readJSON()
        } else {
            return try writeJSON()
        }
    }
    
    //MARK: Read/write JSON
    
    private func readJSON() throws {
        do {
            let jsonString = try String(contentsOf: fileURL)
            
            if let objectsArray = BaseObject.convertfromJSON(jsonString) as? [BaseObject] {
                objects = Set(objectsArray)
                
            } else {
                throw JSONDataBaseError.readingFailed("Wrong data format in \(fileName).json")
            }
        } catch {
            throw JSONDataBaseError.readingFailed("Coundn't read from \(fileName).json")
        }
    }
    
    private func writeJSON() throws {
        if let jsonString = BaseObject.convertToJSON(Array(objects)) {
            do {
                try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch  {
                throw JSONDataBaseError.writingFailed("Coundn't write to \(fileName).json")
            }
        } else {
            throw JSONDataBaseError.writingFailed("Wrong data format in memory database")
        }
    }
    
    //MARK: Reading
    
    public func object<T: BaseObject, K>(ofType type: T.Type, forPrimaryKey key: K) -> T? {
        var object: T? = nil
        let semaphore = DispatchSemaphore(value: 0)
        queue.addOperation {
            object = self.filter(type, forPrimaryKey: key)
            semaphore.signal()
        }
        semaphore.wait()
        return object
    }
    
    public func objects<T: BaseObject>(_ type: T.Type, predicate: NSPredicate?) -> [T] {
        var objectsArray = [T]()
        let semaphore = DispatchSemaphore(value: 0)
        queue.addOperation {
            objectsArray = self.filter(type)
            if let predicate = predicate {
                objectsArray = objectsArray.filter { predicate.evaluate(with: $0) }
            }
            semaphore.signal()
        }
        semaphore.wait()
        return objectsArray
    }
    
    //MARK: Persist
    
    public func persist<T: BaseObject>(_ entry: T) {
        queue.addOperation {
            self.objects.insert(entry)
            try? self.writeJSON()
        }
    }
    
    public func persist<T: BaseObject>(_ entries: [T]) {
        queue.addOperation {
            entries.forEach { self.objects.insert($0) }
            try? self.writeJSON()
        }
    }
    
    public func save() {
        queue.addOperation {
            try? self.writeJSON()
        }
    }
    
    //MARK: Erase
    
    public func erase<T: BaseObject, K>(ofType type: T.Type, forPrimaryKey key: K) {
        queue.addOperation {
            if let object = self.filter(type, forPrimaryKey: key) {
                self.objects.remove(object)
            }
        }
    }

    public func erase<T: BaseObject>(_ type: T.Type) {
        queue.addOperation {
           let objects = self.filter(type)
            objects.forEach { self.objects.remove($0) }
        }
    }
        
    public func eraseAll() {
        queue.addOperation {
            self.objects = []
            try? self.writeJSON()
        }
    }
    
    //MARK: Filter
    
    private func filter<T: BaseObject, K>(_ type: T.Type, forPrimaryKey key: K) -> T? {
        let primaryKey = T.primaryKey()
        let objectsArray = filter(type)
        if key is String {
            let key = key as! String
            let predicate = NSPredicate(format: "%K = %@", primaryKey,key)
            return objectsArray.filter( { predicate.evaluate(with: $0) } ).first
        }
        return nil
    }
    
    private func filter<T: BaseObject>(_ type: T.Type) -> [T] {
        if let objectsArray = objects.filter({ $0 is T }) as? [T] {
            return objectsArray
        }
        return []
    }
    
}


