//
//  Update.swift
//  JEasyORM
//
//  Created by 蔡杰 on 2017/7/31.
//  Copyright © 2017年 蔡杰. All rights reserved.
//


extension QueryType {

    
    //更新数据
    //update table_name set column1 = value1, column2 = value2;
    @discardableResult public func update(_ values: Setter...) -> Update {
        return self.update(values)
    }
    
    fileprivate func update(_ values: [Setter]) -> Update {
        let expressionArray:[Expressible?] = [
            Expression<Void>(literal: "UPDATE"),
            tableName(),
            Expression<Void>(literal: "SET"),
            ", ".join( values.map{ " = ".join([$0.column,$0.value]) } ),
            whereStatement
        ]
        return Update(" ".join(expressionArray.flatMap{ $0 }).expression)
    }
    
}

extension DBConnection {
    
    @discardableResult public func run(_ update: Update) throws -> Int {
        let expression = update.expression
        return try dbSync{
            try self.run(expression.template,expression.bindings)
            return self.changes
        }
    }
    
}


public struct Update : ExpressionType {
    
    public var template: String
    public var bindings: [Binding?]
    
    public init(_ template: String, _ bindings: [Binding?]) {
        self.template = template
        self.bindings = bindings
    }
    
}
