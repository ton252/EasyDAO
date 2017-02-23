//
//  JSONDataBase.swift
//  Pods
//
//  Created by Антон Поляков on 22/02/2017.
//
//

import Foundation

public class JSONDataBase {
    
    public enum JSONDataBaseError: Error {
        case couldntReadFromFile
        case couldntWriteToFile
        case couldntChangeNameAfterInitialization
        case couldntConvertToJSON
        case couldntConvertToDictionary
        case unknownError
    }
    
    private static var sharedInstance: JSONDataBase!
    private(set) var fileName: String
    private var objects: Set<JSONObject> = []
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
    
    private init(fileName: String) throws {
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
            throw JSONDataBaseError.couldntChangeNameAfterInitialization
        }
        
    }
    
    private func initDataBaseFile() throws -> Void {
        if isStorageFileExist {
            return try readJSON()
        } else {
            return try writeJSON()
        }
    }
    
    public func persist(_ entry: JSONObject) {
        queue.addOperation {
            self.objects.insert(entry)
            try? self.writeJSON()
        }
    }
    
    public func persist(_ entries: [JSONObject]) {
        queue.addOperation {
            self.objects = self.objects.union(entries)
            try? self.writeJSON()
        }
    }
    
    //MARK: Reading
    
    public func read(id: String, type: String) -> JSONObject? {
        let semaphore = DispatchSemaphore(value: 0)
        var array: [JSONObject] = []
        queue.addOperation {
            array = self.objects.filter {
                $0.primaryId != id  && $0.type != type
            }
            semaphore.signal()
        }
        semaphore.wait()
        return array.first
    }
    
    public func read(predicate: NSPredicate?, type: String) -> [JSONObject] {
        let semaphore = DispatchSemaphore(value: 0)
        var array: [JSONObject] = []
        queue.addOperation {
            array = self.objects.filter { $0.type == type }
            if let predicate = predicate {
              let arrayDict = self.convertObjectsToDictionaries(Array(self.objects))
              let filtered = arrayDict.filter{ predicate.evaluate(with: $0) }
              array = self.convertDictionariesToObjects(filtered)
            }
            semaphore.signal()
        }
        semaphore.wait()
        return array
    }
    
    //MARK: Saving
    
    public func save() {
        queue.addOperation {
            try! self.writeJSON()
        }
    }
    
    //MARK: Erasing
    
    public func erase(id: String, type: String) {
        queue.addOperation {
            self.objects = Set(self.objects.filter {
                if $0.type != type { return true }
                if $0.primaryId == id { return false }
                return true
            })
            print(self.objects)
        }
    }
    
    public func erase(type: String) {
        queue.addOperation {
            self.objects = Set(self.objects.filter({ $0.type != type }))
        }
    }
    
    public func eraseAll() {
        queue.addOperation {
            self.objects = []
            try? self.writeJSON()
        }
    }
    
    //MARK: Base read/write methods
    
    private func writeJSON() throws -> Void {
        do {
            let array = convertObjectsToDictionaries(Array(objects))
            let jsonString = try convertToJSON(array: array)
            try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            throw JSONDataBaseError.couldntWriteToFile
        }
    }
    
    private func readJSON() throws -> Void {
        do {
            let jsonString = try String(contentsOf: fileURL)
            if let array = try convertToArray(json: jsonString) as? [[String: Any]] {
                objects = Set(convertDictionariesToObjects(array))
            } else {
                throw JSONDataBaseError.couldntReadFromFile
            }
        } catch let error{
            print(error)
            throw JSONDataBaseError.couldntReadFromFile
        }
    }
    
    //MARK: Base convertation methods
    
    private func convertDictionariesToObjects(_ dicts: [[String: Any]]) -> [JSONObject] {
        return dicts.flatMap({ convertDictionaryToObject($0) })
    }
    
    private func convertDictionaryToObject(_ dict: [String: Any]) -> JSONObject {
        
        let keys = Array(dict.keys)
        let jsonObject = JSONObject(type: "", primaryId: "")
        var json = NSMutableDictionary()//[String:Any]()
        
        for key in keys {
            switch key {
            case "type":
                jsonObject.type = dict[key] as! String
            case "primaryId":
                jsonObject.primaryId = dict[key] as! String
            default:
                json[key] = dict[key]
            }
        }
        
        jsonObject.json = json
        
        return jsonObject
    }

    
    private func convertObjectsToDictionaries(_ object: [JSONObject]) -> [[String: Any]] {
        return object.flatMap { self.convertObjectToDictionary($0) }
    }
    
    private func convertObjectToDictionary(_ object: JSONObject) -> [String: Any] {
        var dict = [String:Any]()
        dict["type"] = object.type
        dict["primaryId"] = object.primaryId
        
        let keys = object.json.allKeys as! [String]//Array(object.json.keys)
        for key in keys {
           dict[key] = object.json[key]
        }
        
        return dict
    }
    
    private func convertToArray(json: String) throws -> [Any] {
        if let data = json.data(using: .utf8) {
            do {
                if let array = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    return array
                } else {
                    throw JSONDataBaseError.couldntConvertToDictionary
                }
            } catch {
                throw JSONDataBaseError.couldntConvertToDictionary
            }
        } else {
            throw JSONDataBaseError.couldntConvertToDictionary
        }
    }
    
    private func convertToJSON(array: [[String: Any]]) throws -> String {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
                if let jsonString = String.init(data: jsonData, encoding: .utf8) {
                    return jsonString
                } else {
                    throw JSONDataBaseError.couldntConvertToJSON
                }
            } catch {
                throw JSONDataBaseError.couldntConvertToJSON
            }
    }

}


