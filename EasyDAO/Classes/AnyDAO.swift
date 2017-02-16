//
//  AnyDAO.swift
//  DAO
//
//  Created by Антон Поляков on 13/02/2017.
//  Copyright © 2017 Антон Поляков. All rights reserved.
//

import Foundation

public class AnyDAO<Entity: EntityProtocol> {
    
    private let _persistEntity: ((Entity) -> Bool)
    private let _persistEntities: (([Entity]) -> Bool)
    
    private let _readID: ((String) -> Entity?)
    private let _read: ((NSPredicate?) -> [Entity])
    
    private let _eraseID: ((String) -> Bool)
    private let _erase: ((Void) -> Bool)
    
    
    public init<DAOType: DAOProtocol>(_ dao: DAOType) where DAOType.Entity == Entity {
        _persistEntity = dao.persist
        _persistEntities = dao.persist
        _readID = dao.read(id:)
        _read = dao.read(predicate:)
        _eraseID = dao.erase(id:)
        _erase = dao.erase
    }
    
    @discardableResult public func persist(entity: Entity) -> Bool {
        return _persistEntity(entity)
    }
    
    @discardableResult public func persist(entities: [Entity]) -> Bool {
        return _persistEntities(entities)
    }
    
    public func read(id: String) -> Entity? {
        return _readID(id)
    }
    
    public func read(predicate: NSPredicate?) -> [Entity] {
        return _read(predicate)
    }
    
    @discardableResult public func erase(id: String) -> Bool {
        return _eraseID(id)
    }
    
    @discardableResult public func erase() -> Bool {
        return _erase()
    }
}
