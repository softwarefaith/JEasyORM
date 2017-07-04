//
//  JEasyORMDBConnection.swift
//  JEasyORM
//
//  Created by 蔡杰 on 2017/7/3.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

import UIKit

public final class JEasyORMDBConnection {
    
//定义数据库存储方式(枚举、常量)
    enum StorageMode: CustomStringConvertible{
        
        case inMemory
        case temporary
        case uri(String)

        var description: String {
            
            switch self {
                case .inMemory:
                    return ":memory:"
                case .temporary:
                    return ""
                case .uri(let path):
                    return path;
            }
        }
    }
    
    enum Operation {
        
        case insert
        case update
        case delete
        case select
        
        //将数据库类型->转成枚举类型
        fileprivate init(value:Int32){
            switch value {
                case SQLITE_INSERT:
                    self = .insert
                case SQLITE_UPDATE:
                    self = .update
                case SQLITE_DELETE:
                    self = .delete
                case SQLITE_SELECT:
                    self = .select
                default:
                    fatalError("没有这个类型:\(value)")
            }
        }

        
    }

}
