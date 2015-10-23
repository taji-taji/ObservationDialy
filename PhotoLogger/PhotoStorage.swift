
//
//  PhotoStorage.swift
//  PhotoLogger
//
//  Created by tajika on 2015/10/23.
//  Copyright © 2015年 Tajika. All rights reserved.
//

import UIKit
import RealmSwift

class PhotoStorage {
    
    private let realm: Realm
    
    init() {
        realm = try! Realm()
    }
    
    func add(d: PhotoData) {
        if let last = realm.objects(PhotoData).sorted("id").last {
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
    
    func find(id: Int) -> PhotoData? {
        return realm.objects(PhotoData).filter("id = \(id)").first
    }
    
    func findWhere(filter: String) -> PhotoData? {
        return realm.objects(PhotoData).filter(filter).first
    }
    
    func findAll() -> [PhotoData] {
        return realm.objects(PhotoData).map { $0 }
    }
    
    func delete(d: PhotoData) {
        do {
            try realm.write {
                self.realm.delete(d)
            }
        } catch {
            print("error")
        }
    }
    
}