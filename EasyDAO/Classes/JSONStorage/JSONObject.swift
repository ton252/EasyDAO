//
//  JSONObject.swift
//  Pods
//
//  Created by Антон Поляков on 22/02/2017.
//
//

import Foundation

public class JSONObject: NSObject {
        
    var json: NSMutableDictionary
    var primaryId: String
    var type: String
    
    public init(type: String, primaryId: String, json: NSMutableDictionary = NSMutableDictionary()){
        self.json = json
        self.type = type
        self.json["type"] = type
        self.primaryId = primaryId
    }
    
    public func object(forKey key: String) -> Any? {
        return json[key]
    }
    
//    public var description: String {
//        return "Type: \(type)\nprimaryId: \(primaryId)\nJSON:\n\(json)\n"
//    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        if let object = object as? JSONObject {
            if object.primaryId == self.primaryId && object.type == self.type {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
}

//extension Int : AnyEquatable { }
//extension Float : AnyEquatable { }
//extension Double : AnyEquatable { }
//extension String : AnyEquatable { }
//
//public protocol AnyEquatable {
//    func equals(_ otherObject: AnyEquatable) -> Bool
//}
//
//extension AnyEquatable where Self : Equatable {
//    public func equals(_ otherObject: AnyEquatable) -> Bool {
//        if let otherAsSelf = otherObject as? Self {
//            return otherAsSelf == self
//        }
//        return false
//    }
//}
//
//extension Dictionary {
//    
//    public func toAnyEquatable() -> [String: AnyEquatable] {
//        var newDict = [String: AnyEquatable]()
//        for key in self.keys {
//            let type = type(of: self[key])
//            if type == String.self {
//                
//            }else if type == Int.self {
//                
//            }else if type == Array.self {
//                
//            }
////            if self[key].self! == String {
////                
////            }
//            //newDict[key as! String] = self[key]
//        }
//    }
//    
//}
