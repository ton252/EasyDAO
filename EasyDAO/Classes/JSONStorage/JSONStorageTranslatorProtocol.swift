//
//  JSONStorageTranslatorProtocol.swift
//  Pods
//
//  Created by Антон Поляков on 22/02/2017.
//
//

import Foundation

public protocol JSONStorageTranslatorProtocol: TranslatorProtocol {
    associatedtype Entry: JSONObject
}
