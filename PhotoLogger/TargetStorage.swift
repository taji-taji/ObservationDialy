//
//  TargetStorage.swift
//  PhotoLogger
//
//  Created by tajika on 2015/10/20.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import RealmSwift

class TargetStorage {

    private let realm: Realm
    
    init() {
        realm = try! Realm()
    }

    func add(d :TargetData) {
        if let last = realm.objects(TargetData).sorted("id").last {
            d.id = last.id + 1
        } else {
            d.id = 1
        }
        do {
            try realm.write {
                self.realm.add(d)
            }
        } catch {
            print("error")
        }
        
    }

    func find(id: Int) -> TargetData? {
        return realm.objects(TargetData).filter("id = \(id)").first
    }

    func findAll() -> [TargetData] {
        return realm.objects(TargetData).map { $0 }
    }

    func delete() {
        let objs = self.realm.objects(TargetData)
        do {
            try realm.write {
                self.realm.delete(objs)
            }
        } catch {
            print("error")
        }
    }

}