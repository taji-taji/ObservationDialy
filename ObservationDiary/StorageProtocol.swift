//
//  StorageProtocol.swift
//  ObservationDiary
//
//  Created by tajika on 2015/10/23.
//  Copyright © 2015年 Tajika. All rights reserved.
//

protocol StorageProtocol {
    func add<T: ModelBase>(d: T)
    func find<T: ModelBase>(type: T, id: Int) -> T?
    func findAll<T: ModelBase>(type: T, orderby: String?, ascending: Bool) -> [T]
    func delete<T: ModelBase>(d: T)
}