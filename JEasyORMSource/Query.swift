

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
     init(_ name:String, _ database: String?) {
        self.from = (name,database)
    }
    
    //过滤器(where条件)->统一调用->是否需要条件
    var filters:Expression<Bool?>?
    
    //添加查询操作
    //默认约束条件
    //元素一：查询数据去重复
    //例如
    //数据一：id = 1   name = "Dream"
    //数据二：id = 2   name = "Dream"
    //去除重复(关键字：distinct)->根据字段进行去除重复
    //结果
    //数据一：id = 1   name = "Dream"
    //元素二：需要查询的字段(默认查询所有的字段)
    //select * from t_user
    var select = (distinct: false,columns: [Expression<Void>(literal: "*") as Expressible])
    
    //添加排序
    var order = [Expressible]()
    
    //添加分组
    //by:表示字段列表(可以根据多个字段进行分组)
    //having:分组基础之上的条件
    var group:(by: [Expressible], having: Expression<Bool?>?)?

    //获取数量(元组)
    var limit:(length: Int, offset: Int?)?
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
    
//    //添加具体的查询语句
//    fileprivate var selectStatement: Expressible {
//        return " ".join([
//            Expression<Void>(literal: manager.select.distinct ? "SELECT DISTINCT" : "SELECT"),
//            ", ".join(manager.select.columns),
//            Expression<Void>(literal: "FROM"),
//            tableName()
//            ])
//    }
//    public var expression: Expression<Void> {
//        let manager: [Expressible?] = [
//            //添加查询语句
//            selectStatement
//        ]
//        //过滤器
//        //Expression : name   sex
//        //加入", "结果: name, sex
//        return ", ".join(manager.flatMap{ $0 }).expression
//    }

    
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






