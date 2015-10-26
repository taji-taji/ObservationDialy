//
//  Storage.swift
//  PhotoLogger
//
//  Created by tajika on 2015/10/24.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import RealmSwift

class Storage: StorageProtocol {
    
    private let realm: Realm
    
    init() {
        realm = try! Realm()
    }
    
    func add<T: Data>(d: T) {
        if let last = realm.objects(T).sorted("id").last {
            d.id = last.id + 1
        } else {
            d.id = 1
        }
        do {
            try realm.write({ () -> Void in
                self.realm.add(d)
            })
        } catch {
            realm.cancelWrite()
            print("error")
        }
    }
    
    func find<T: Data>(type: T, id: Int) -> T? {
        return realm.objects(T).filter("id = \(id)").first
    }
    
    func findWhere<T: Data>(type: T, filter: String) -> [T]? {
        return realm.objects(T).filter(filter).map { $0 }
    }
    
    func findAll<T: Data>(type: T) -> [T] {
        return realm.objects(T).map { $0 }
    }
    
    func delete<T: Data>(d: T) {
        do {
            try realm.write {
                self.realm.delete(d)
            }
        } catch {
            print("error")
        }
    }
    
}