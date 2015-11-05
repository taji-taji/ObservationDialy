//
//  StorageProtocol.swift
//  PhotoLogger
//
//  Created by tajika on 2015/10/23.
//  Copyright © 2015年 Tajika. All rights reserved.
//

protocol StorageProtocol {
    func add<T: Data>(d: T)
    func find<T: Data>(type: T, id: Int) -> T?
    func findAll<T: Data>(type: T, orderby: String?, ascending: Bool) -> [T]
    func delete<T: Data>(d: T)
}