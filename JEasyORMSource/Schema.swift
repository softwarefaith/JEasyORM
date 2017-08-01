//
//  Schema.swift
//  JEasyORM
//
//  Created by 蔡杰 on 2017/7/31.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

import Foundation

extension QueryType {
    
    //创建表->处理
    //参数一：创建表关键字: TABLE
    //参数二：表名
    //返回值：抽象产品
    public func create(_ identifer: String, _ name: Expressible) -> Expressible {
        let expressionArray:[Expressible?] = [
            Expression<Void>(literal: "CREATE" ),//创建表关键字:create
            Expression<Void>(literal: identifer ),
            name
        ]
        return " ".join(expressionArray.flatMap{$0})
    }
    
}


//统一组装类
extension Table {
    
    //构建表->方法重载
    //参数一：构建者
    public func create(_ build: (TableBuilder) -> Void) -> String {
        let tableBuild = TableBuilder()
        build(tableBuild)
        
        //分为两个部分
        //一个部分create(Table.identifier,tableName())表示：create table t_user
        //一个部分"".wrap(tableBuild.expressions)表示：(t_user_sex text, t_user_name text)
        let expression:[Expressible?] = [
            create(Table.identifier,tableName()),
            "".wrap(tableBuild.expressions) as Expression<Void>
        ]
        
        return " ".join(expression.flatMap{ $0 }).asSQL()
    }
    
}


//构建者模式：具体的构建者
public final class TableBuilder {
    
    //字段列表(表达式数组)
    fileprivate var expressions = [Expressible]()
    
    //方法重载一（默认值）
    //参数一：字段名称
    //参数二：表示字段是否唯一
    //参数三：字段默认值->表达式类型->Expression<V>? = nil
    @discardableResult public func column<V : Value>(_ name: Expression<V>, unique: Bool = false, defaultValue: Expression<V>? = nil) -> TableBuilder {
        return self.column(name, V.declareDatatype, unique: unique, defaultValue: defaultValue)
    }
    
    //方法重载二（默认值）
    //参数一：字段名称
    //参数二：表示字段是否唯一
    //参数三：字段默认值->表达式类型->V类型->Int、Double、Float、String等...
    @discardableResult public func column<V : Value>(_ name: Expression<V>, unique: Bool = false, defaultValue: V) -> TableBuilder {
        return self.column(name, V.declareDatatype, unique: unique, defaultValue: defaultValue as? Expressible)
    }
    
    //方法重载三:实现
    @discardableResult public func column(_ name: Expressible,_ datatype: String, unique: Bool = false, defaultValue: Expressible?) -> TableBuilder {
        //保存字段，为了后面构建使用
        self.expressions.append(expressionFunc(name,datatype,false,unique: unique, defaultValue: defaultValue))
        return self
    }
    
    //童鞋们课后可以重载更多的方法
    
    
    private func expressionFunc(_ column: Expressible,_ datatype: String,_ null:Bool, unique: Bool = false, defaultValue: Expressible?) -> Expressible {
        //数据库字段唯一
        //例如
        //第一条数据：name = "Dream"
        //第二条数据：name = "Dream"
        //唯一：不能够有重复值(主键唯一)
        //分析默认值关键字
        //数据顺序：default [值]
        //错误写法：defaultValue default
        let expressionArray:[Expressible?] = [
            column,//字段名称
            Expression<Void>(literal: datatype),//字段类型
            null ? nil : Expression<Void>(literal: "NOT NULL" ),//是否为空
            unique ? Expression<Void>(literal: "UNIQUE" ) : nil,//字段唯一
            //在默认值的前面拼接SQL默认关键字:DEFAULT
            defaultValue.map{"DEFAULT".prefix($0)},//默认值
            
        ]
        return " ".join(expressionArray.flatMap{ $0 })
    }


    
}







