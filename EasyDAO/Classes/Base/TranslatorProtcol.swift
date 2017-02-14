//
//  TranslatorProtcol.swift
//  DAO
//
//  Created by Антон Поляков on 13/02/2017.
//  Copyright © 2017 Антон Поляков. All rights reserved.
//

public protocol TranslatorProtocol: class {
    
    associatedtype Entity: EntityProtocol
    associatedtype Entry
    
    /**
     Трансляция сущности(Entry) в сущность БД(Entity)
     - parameter entity: Массив сущностей
     - returns: Сущность БД
     */
    func toEntry(_ entity: Entity) -> Entry
    
    /**
     Трансляция массива сущностей(Entry) в массив сущностей БД(Entity)
     - parameter entity: Массив сущностей
     - returns: Массив сущностей БД
     */
    func toEntries(_ entities: [Entity]) -> [Entry]
    
    /**
     Трансляция сущности БД(Entity) в сущность(Entry)
     - parameter entity: Сущность БД
     - returns: Сущность
     */
    func toEntity(_ entry: Entry) -> Entity
    
    /**
     Трансляция массива сущностей БД(Entity) в массив сущностей(Entry)
     - parameter entity: Массив сущностей БД
     - returns: Массив сущностей
     */
    func toEntities(_ entries: [Entry]) -> [Entity]
}
