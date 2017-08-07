//
//  Select.swift
//  JEasyORM
//
//  Created by 蔡杰 on 2017/7/31.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

import Foundation


extension DBConnection {
    
    public func prepare(_ query: QueryType) throws ->AnySequence<Row>  {
        //构建SQL语句->对象(expression)
        let expression = query.expression
        //expression->String类型
        //select * from t_user
        let statement = try prepare(expression.template, expression.bindings)
        
        //指定这个SQL语句查询字段
        let columnNames: [String:Int] = {
            var (columnNames, index) = ([String:Int](),0)
            //循环遍历查询字段
            for each in query.manager.select.columns {
                //查询字段名称:each.expression.template
                //查询字段下标:index
                columnNames[each.expression.template] = index
                index += 1
            }
            return columnNames
        }()
        
        
        //执行SQL语句，查询数据
//        try statement.step()
        //返回数据
        return AnySequence {
            //statement.next():执行SQL语句，获取的数据
            //Row(columnNames, $0):解析数据，获取的我们想要的类型
            AnyIterator {
                statement.next().map{ Row(columnNames, $0) }
            }
        }
    }
    
    //select * from t_user;
    //查询所有:不需要指定查询字段->为了和之前的根据字段查询方法分开实现
    public func prepareAll(_ query: QueryType) throws ->AnySequence<Row> {
        //构建SQL语句->对象(expression)
        let expression = query.expression
        //expression->String类型
        //select * from t_user
        let statement = try prepare(expression.template, expression.bindings)
        
        //指定这个SQL语句查询字段
        let columnNames: [String:Int] = try {
            var (columnNames, index) = ([String:Int](),0)
            //循环遍历查询字段
            for each in query.manager.select.columns {
                
                //获取所有字段名称
                //解析字段(db.id,db.name)
                //select db_test.t_user.* from t_user
                var names = each.expression.template.characters.split { $0 == "." }.map( String.init )
                let column = names.removeLast();
                
                //定义闭包代码块
                let expandGlob = { (query: QueryType) throws -> (Void) in
                    //创建一个查询语句
                    var q = type(of: query).init(query.manager.from.name, query.manager.from.database)
                    q.manager.select = query.manager.select
                    let e = q.expression
                    
                    //这两种是一样的(语法区别)
                    //写法一
                    //SQL语句结构：select "t_user_sex","t_user_name" from "t_user"
                    let names = try self.prepare(e.template, e.bindings).columnNames.map { $0.quote() }
                    //写法二
                    //SQL语句结构：select t_user_sex,t_user_name from t_user
                    //                    let names = try self.prepare(e.template, e.bindings).columnNames
                    
                    //根据表字段顺序，后去表字段对应下标
                    //获取下标目的：为了在查询数据库的时候，通过迭代器模式动态遍历字段
                    for name in names {
                        columnNames[name] = index
                        index += 1
                    }
                    
                }
                
                if column == "*" {
                    //查询所有数据
                    //将"*"->变成一个表达式
                    var select = query
                    select.manager.select = (false,[Expression<Void>(literal: "*") as Expressible])
                    //执行查询
                    try expandGlob(select)
                }
            }
            return columnNames
            }()
        
        return AnySequence {
            AnyIterator {
                statement.next().map{ Row(columnNames, $0) }
            }
        }
    }

    
}


extension QueryType {
    
    //方法重载
    //指定查询字段
    //例如：select * from t_user(表示查询所有的数据)
    //例如：select t_id,t_name from t_user(指定查询字段)
    public func select(_ column: Expressible, _ more: Expressible...) -> Self {
        return self.select(false, [column] + more)
    }
    
    //方法重载:去除重复数据
    public func select(distinct column: Expressible, _ more: Expressible...) -> Self {
        return self.select(true, [column] + more)
    }
    
    //方法重载：查询所有字段(字段数组)
    public func select(_ all: [Expressible]) -> Self {
        return self.select(false, all)
    }
    
    //方法重载：查询所有字段->去除重复
    public func select(distinct all: [Expressible]) -> Self {
        return self.select(true, all)
    }
    
    
    //处理公共功能
    //动态修改查询语句默认条件
     func select<Q : QueryType>(_ distinct: Bool, _ columns:[Expressible]) -> Q {
        //数据库中哪一个表
        //例如：db_test.t_user
        var query = Q.init(manager.from.name,manager.from.database)
        query.manager = manager
        query.manager.select = (distinct, columns)
        return query
    }
    
    //添加具体的查询语句
    fileprivate var selectStatement: Expressible {
        return " ".join([
            Expression<Void>(literal: manager.select.distinct ? "SELECT DISTINCT" : "SELECT"),
            ", ".join(manager.select.columns),
            Expression<Void>(literal: "FROM"),
            tableName()
            ])
    }
    
//    public var expression:Expression<Void> {
//        let manager: [Expressible?] = [
//            //添加查询语句
//            selectStatement,
//            //添加where语句
//            whereStatement,
//            orderStatement,
//            limitOffsetStatement
//        ]
//        //过滤器
//        //Expression : name   sex
//        //加入", "结果: name, sex
//        return " ".join(manager.flatMap{ $0 }).expression
//    }
    
}




//定义行数据:Row结构体
//解释下标语法
//struct TimesTable {
//    let multiplier: Int
//    subscript(index: Int) -> Int {
//        return multiplier * index
//    }
//}
//let threeTimesTable = TimesTable(multiplier: 3)
//print("six times three is \(threeTimesTable[6])")
public struct Row {
    
    //字段名称列表
    fileprivate let columnNames: [String:Int]
    //字段对应值
    fileprivate let values: [Binding?]
    
    fileprivate init(_ columnNames: [String:Int], _ values: [Binding?]){
        self.columnNames = columnNames
        self.values = values
    }
    
    //下标语法
    public func get<V : Value>(_ column: Expression<V>) -> V {
        return get(Expression<V?>(column))!
    }
    
    //重载一个方法:可选类型
    public func get<V : Value>(_ column: Expression<V?>) -> V? {
        //第一步：定义嵌套方法/函数->临时代码块
        //目的：判定当前值是否是我们规定的数据类型
        func valueAtIndex(_ index: Int) -> V? {
            //规定类型
            //判断当前Value是否是我们的规范的类型
            guard let value = values[index] as? V.DataType else {
                //否:执行else
                //不合法
                return nil
            }
            //是：继续执行->合法
            return (V.fromDatatypeValue(value) as? V)!
        }
        
        //第二步：验证下标
        guard let index = columnNames[column.template] else {
            //不存在字段，那么我就抛出异常，报错
            //在我们的字段存在的下标中去判断是非存在这个index
            //优化处理
            fatalError("没有这个字段，请确认是否传入正确参数")
        }
        //如果继续执行
        return valueAtIndex(index)
    }
    
    //知道具体的类型
    //下标语法
    public subscript(column: Expression<Bool>) -> Bool {
        return get(column)
    }
    
    public subscript(column: Expression<Bool?>) -> Bool? {
        return get(column)
    }
    
    public subscript(column: Expression<Double>) -> Double {
        return get(column)
    }
    
    public subscript(column: Expression<Double?>) -> Double? {
        return get(column)
    }
    
    public subscript(column: Expression<Int>) -> Int {
        return get(column)
    }
    
    public subscript(column: Expression<Int?>) -> Int? {
        return get(column)
    }
    
    public subscript(column: Expression<Int64>) -> Int64 {
        return get(column)
    }
    
    public subscript(column: Expression<Int64?>) -> Int64? {
        return get(column)
    }
    
    public subscript(column: Expression<String>) -> String {
        return get(column)
    }
    
    public subscript(column: Expression<String?>) -> String? {
        return get(column)
    }
    
    public subscript(column: Expression<Float>) -> Float {
        return get(column)
    }
    
    public subscript(column: Expression<Float?>) -> Float? {
        return get(column)
    }
    
}









