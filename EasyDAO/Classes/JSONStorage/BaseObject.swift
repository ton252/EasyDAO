//
//  BaseObject.swift
//  1
//
//  Created by Антон Поляков on 24/02/2017.
//  Copyright © 2017 Антон Поляков. All rights reserved.
//

import Foundation

@objc(BaseObject)
open class BaseObject: NSObject {
    
    dynamic var identifier: String?
    
    open class func primaryKey() -> String {
        fatalError("Override this method")
    }
    
    //MARK: Comparable
    
    override open func isEqual(_ object: Any?) -> Bool {
        
        if let object = object as? BaseObject {
            
            guard let selfClass = object_getClass(self) as? BaseObject.Type else {
                return false
            }
            
            guard let objectClass = object_getClass(object) as? BaseObject.Type else {
                return false
            }
            
            let primaryKey1 = selfClass.primaryKey()
            let primaryKey2 = objectClass.primaryKey()
            
            let value1 = self.value(forKey: primaryKey1)
            let value2 = object.value(forKey: primaryKey2)
            
            guard type(of:value1) == type(of: value2) else {
                return false
            }
            
            if let value1 = value1 as? String {
                return value1 == (value2 as! String)
            } else {
                fatalError("Primary key must be only String")
            }
            
        }

        return false
    }
    
    override open var hash: Int {
        let className = String(describing: self.getClass(type: self))
        let value = self.value(forKey: self.getPrimaryKey(type: self))
        return "\(className)\(value)".hash
    }
    
    //MARK: Helpers
    
    private func getPrimaryKey(type: Any!) -> String! {
        let selfClass = object_getClass(type) as? BaseObject.Type
        return selfClass?.primaryKey()
    }
    
    private func getClass(type: Any!) -> Any! {
        return object_getClass(type) as? BaseObject.Type
    }
    
}

//MARK: Convert to dictionary and back

extension NSObject {
    
    public static let kClassName = "ClassName"
    
    public class func fromClassName(_ className : String) -> NSObject {
        if let aClass = NSClassFromString(className) as? NSObject.Type {
            return aClass.init()
        }
        let className = Bundle.main.infoDictionary!["CFBundleName"] as! String + "." + className
        let aClass = NSClassFromString(className) as! NSObject.Type
        return aClass.init()
    }
    
    public func toDictionary() -> [String: Any] {
        
        var dictionary = [String: Any]()
        let className = String(describing: type(of: self))
        let keys = self.propertyKeys()
        
        for key in keys {
            dictionary[key] = self.value(forKey: key)
        }
        
        dictionary[NSObject.kClassName] = className
        
        return dictionary
    }
    
    public class func fromDictionary(_ dictionary: [String: Any]) -> NSObject {
        
        let className = dictionary[NSObject.kClassName] as! String
        let object = NSObject.fromClassName(className)
        let keys = dictionary.keys
        
        for key in keys {
            if key != NSObject.kClassName {
                object.setValue(dictionary[key], forKey: key)
            }
        }
        return object
    }
    
    public func propertyKeys() -> [String] {
        
        var results: Array<String> = [];
        
        // retrieve the properties via the class_copyPropertyList function
        var count: UInt32 = 0;
        let myClass: AnyClass = self.classForCoder;
        let properties = class_copyPropertyList(myClass, &count);
        
        // iterate each objc_property_t struct
        for i: UInt32 in 0 ..< count {
            let property = properties?[Int(i)];
            
            // retrieve the property name by calling property_getName function
            let cname = property_getName(property);
            
            // covert the c string into a Swift string
            let name = String(validatingUTF8:cname!)
            results.append(name!);
        }
        
        // release objc_property_t structs
        free(properties);
        
        return results;
    }
}


//MARK: Convert to JSON and back

extension BaseObject {
    
    public class func convertToJSON(_ objects: [NSObject]) -> String? {
        do {
            
            let array = objects.map{ $0.toDictionary() }
            let jsonData = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
            return nil
        } catch {
            return nil
        }
    }
    
    public class func convertfromJSON(_ json: String) -> [NSObject]? {
        if let data = json.data(using: .utf8) {
            do {
                if let array = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    let objects = array.map{ BaseObject.fromDictionary($0) }
                    return objects
                }
            } catch {
                return nil
            }
        }
        return nil
    }
    
}
