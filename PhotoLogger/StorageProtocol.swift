//
//  StorageProtocol.swift
//  PhotoLogger
//
//  Created by tajika on 2015/10/23.
//  Copyright © 2015年 Tajika. All rights reserved.
//

protocol StorageProtocol {
    func add<T: Data>(d: T)
    func find<T: Data>(id: Int) -> T?
    func findAll<T: Data>(type: T) -> [T]
    func delete<T: Data>(d: T)
}