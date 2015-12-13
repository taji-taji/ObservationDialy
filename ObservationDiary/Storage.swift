//
//  Storage.swift
//  ObservationDiary
//
//  Created by tajika on 2015/10/24.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import RealmSwift

class Storage: StorageProtocol {
    
    private let realm: Realm
    
    init() {
        // Realm マイグレーション
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
//                migration.enumerate(Photo.className()) { oldObject, newObject in
//                    if (oldSchemaVersion < 1) {
//                    }
//                    if (oldSchemaVersion < 2) {
//                        newObject!["elapsedTime"] = 0
//                    }
//                }
        })
        Realm.Configuration.defaultConfiguration = config
        realm = try! Realm()
    }
    
    init(defaultConfiguration identifier: String) {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = identifier
        realm = try! Realm()
    }
    
    func add<T: ModelBase>(d: T) -> Bool {
        if let last = realm.objects(T).sorted("id").last {
            d.id = last.id + 1
        } else {
            d.id = 1
        }
        do {
            try realm.write({ () -> Void in
                self.realm.add(d)
            })
            return true
        } catch {
            realm.cancelWrite()
            print("error")
            return false
        }
    }
    
    func update<T: ModelBase>(type: T, updateValues: NSDictionary) {
        do {
            try realm.write {
                self.realm.create(T.self, value: updateValues, update: true)
            }
        } catch {
            print("error")
        }
    }
    
    func find<T: ModelBase>(type: T, id: Int) -> T? {
        return realm.objects(T).filter("id = \(id)").first
    }
    
    func findWhere<T: ModelBase>(type: T, filter: String) -> [T]? {
        return realm.objects(T).filter(filter).map { $0 }
    }
    
    func findAll<T: ModelBase>(type: T, orderby: String?, ascending: Bool = true) -> [T] {
        var results = realm.objects(T)
        if orderby != nil {
            results = results.sorted(orderby!, ascending: ascending)
        }
        return results.map { $0 }
    }
    
    func delete<T: ModelBase>(d: T) -> Bool {
        do {
            try realm.write {
                self.realm.delete(d)
            }
            return true
        } catch {
            print("error")
            return false
        }
    }
    
}