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
    fileprivate func select<Q : QueryType>(_ distinct: Bool, _ columns:[Expressible]) -> Q {
        //数据库中哪一个表
        //例如：db_test.t_user
        var query = Q.init(manager.from.name,manager.from.database)
        query.manager = manager
        query.manager.select = (distinct, columns)
        return query
    }
    
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









