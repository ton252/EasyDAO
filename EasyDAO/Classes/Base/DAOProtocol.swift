//
//  DAOProtocol.swift
//  DAO
//
//  Created by Антон Поляков on 13/02/2017.
//  Copyright © 2017 Антон Поляков. All rights reserved.
//

import Foundation

public protocol DAOProtocol {
    
    associatedtype Entry // Сущность БД
    associatedtype Entity: EntityProtocol // Сущность
    associatedtype Translator: TranslatorProtocol // Сущность
    
    /**
    Транслятор, отвечающий за преобразования сущности БД (Entry)
    в простую сущность (Entity)
     */
    var translator: Translator { get }
    
    /**
    Инициализация DAO
    - parameter translator: Транслятор Entry в Entity
    - parameter DataBase: Объект для работы с БД, Realm или PersistentContainer(CoreData)
    - returns: Инициализированный объект или nil в случае ошибки
     */
    //init(translator: Translator)

    /**
     Сохранение сущности в БД
     - parameter entity: Сущность
     - returns: true - успех, false - неудача
     */
    func persist(_ entity: Entity) -> Bool
    
    /**
     Сохранение массива сущностей в БД
     - parameter entities: Сущность
     - returns: true - успех, false - неудача
     */
    func persist(_ entities: [Entity]) -> Bool
    
    /**
     Чтение сущности из БД
     - parameter id: Уникальный идентификатор сущности в БД
     - returns: сущность - успех, nil - сущность с заданным id отсутствует в БД
     */
    func read(id: String) -> Entity?

    /**
     Чтение всех сущностей из БД
     - returns: массив сущностей - успех, nil - сущности отсутствуют в БД
     */
    func read(predicate: NSPredicate?) -> [Entity]
    
    /**
     Удаление сущностей из БД
     - parameter id: Уникальный идентификатор сущности в БД
     - returns: true - успех, false - неудача
     */
    func erase(id: String) -> Bool
    
    /**
     Удаление всех сущностей из БД
     - returns: true - успех, false - неудача
     */
    func erase() -> Bool
    
}
