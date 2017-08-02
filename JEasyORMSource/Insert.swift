//
//  Insert.swift
//  Dream_20170626_Architect_DatabaseFramework
//
//  Created by Dream on 2017/7/3.
//  Copyright © 2017年 Tz. All rights reserved.
//

//扩展插入操作
extension QueryType {
    
    //插入的是一个对象(而不是直接的值)
    //key、value都是一个表达式
    //定义一个Setter结构体
    //可变参数(至少有一个值)
    public func insert(_ value: Setter, _ more: Setter...) -> Insert {
        return self.insert([value] + more)
    }
    
    //拼接多个插入参数
    //例如：insert into t_user(id,name) values(10,"Dream");
    //两个字段: id = 10    name = "Dream"
    //进行拼接表达式数组
    //拼接结果：(id,name)    (10,"Dream")
    //原始状态：key - value形式存在
    //reduce作用
    //(key1,key2)  (value1,value2)
    //将key放在一起，将value放在一起
    fileprivate func insert(_ values: [Setter]) -> Insert {
        //insert是一个元组
        //结果：(column:[id,name],values[10,"Dream"])
        let insert = values.reduce((column: [Expressible](), values: [Expressible]())) { insert, setter in
            (insert.column + [setter.column], insert.values + [setter.value])
        }
        
        //拼接SQL语句->面向对象形式存在
        let expressionArray:[Expressible?] = [
            Expression<Void>(literal: "INSERT"),
            Expression<Void>(literal: "INTO"),
            tableName(),
            //wrap方法给我们的字段名称之间加入","进行分割
            //例如：原来是(id name)->(id,name)
            "".wrap(insert.column) as Expression<Void>,
            Expression<Void>(literal: "VALUES"),
            "".wrap(insert.values) as Expression<Void>
        ]
        
        return Insert(" ".join(expressionArray.flatMap{ $0 }).expression)
    }
    
}

//数据库执行Insert
extension DBConnection {
    
    @discardableResult public func run(_ insert: Insert) throws -> Int64 {
        let expression = insert.expression
        return try dbSync{
            try self.run(expression.template,expression.bindings)
            return self.lastInsertRowid
        }
    }
    
}


//插入语句(封装->面向对象形式进行展示)
public struct Insert : ExpressionType {
    
    public var template: String
    public var bindings: [Binding?]
    
    public init(_ template: String, _ bindings: [Binding?]) {
        self.template = template
        self.bindings = bindings
    }
    
}
