//
//  Delete.swift
//  Dream_20170626_Architect_DatabaseFramework
//
//  Created by Dream on 2017/7/3.
//  Copyright © 2017年 Tz. All rights reserved.
//

extension QueryType {
    
    
    //第一种：写法
//    @discardableResult public func delete<V : Value>(id: Expression<V>){
//        let expressionArray:[Expressible?] = [
//            Expression<Void>(literal: "DELETE FROM"),
//            tableName(),
//            Expression<Void>(literal: "WHERE"),
//            id
//        ]
//    }
    
    
    //第二种写法:删除数据库表的所有的数据
    //delete all
    @discardableResult public func delete() -> Delete {
        let expressionArray:[Expressible?] = [
            Expression<Void>(literal: "DELETE FROM"),
            tableName(),
            whereStatement
        ]
        return Delete(" ".join(expressionArray.flatMap{ $0 }).expression)
    }
    
}

extension DBConnection {
    
    @discardableResult public func run(_ delete: Delete) throws -> Int {
        let expression = delete.expression
        return try dbSync{
            try self.run(expression.template,expression.bindings)
            return self.changes
        }
    }
    
}


public struct Delete : ExpressionType {
    
    public var template: String
    public var bindings: [Binding?]
    
    public init(_ template: String, _ bindings: [Binding?]) {
        self.template = template
        self.bindings = bindings
    }
    
}


