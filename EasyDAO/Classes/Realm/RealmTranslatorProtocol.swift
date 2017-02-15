//
//  RealmTranslator.swift
//  DAO
//
//  Created by Антон Поляков on 13/02/2017.
//  Copyright © 2017 Антон Поляков. All rights reserved.
//

import RealmSwift

public protocol RealmTranslatorProtocol: TranslatorProtocol {
    associatedtype Entry: Object
}
