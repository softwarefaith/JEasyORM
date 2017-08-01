

//
//  Query.swift
//  JEasyORM
//
//  Created by 蔡杰 on 2017/7/31.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

import Foundation

//结构体->类型
//有很多操作:查询、删除、插入、更新、排序、创建等等...
//没有继承关系
public struct QueryManager {
    //创建表操作(元组)
    var from: (name:String, database: String?)
    //TODO:查询、删除、插入....
    fileprivate init(_ name:String, _ database: String?) {
        self.from = (name,database)
    }
}

//操作类型
//第三步：定义抽象->操作类型接口（表操作：创建表、删除表等等...）
public protocol QueryType : Expressible {
    
    //查询类型
    //操作:查询、删除、插入、更新、排序、创建等等...
    //封装为一个管理器
    var manager: QueryManager { get set}
    
    init(_ name:String, _ database: String?)
    
}

//提供默认实现
extension QueryType {
    
    public var expression: Expression<Void> {
        let manager = [Expressible?]()
        //过滤器
        //Expression : name   sex
        //加入", "结果: name, sex
        return ", ".join(manager.flatMap{ $0 }).expression
    }
    
    //包装数据库表名
    func tableName() -> Expressible {
        //加入空格
        return " ".join([database(namespace: manager.from.name)])
    }
    
    func database(namespace name: String) -> Expressible {
        let name = Expression<Void>(name)
        
        guard let database = manager.from.database else {
            return name
        }
        
        //目的：database.name
        //目的：[数据库名称].[表名]
        return ".".join([Expression<Void>(database),name])
    }
    
}


//第四步：实现操作类型->定义表->Table类
//表操作类型
public protocol SchemaType : QueryType {
    
    //定义一个属性：数据库关键字(表关键字)
    static var identifier: String { get }
    
}

//定义表
public struct Table : SchemaType {
    
    public static var identifier: String = "TABLE"
    
    public var manager: QueryManager
    
    //数据库语法
    //创建、查询表：create table test.t_user
    //结构：[数据库名称].[表名]
    public init(_ name: String, _ database: String? = nil) {
        manager = QueryManager(name, database)
    }
    
}






