//
//  Expression.swift
//  JEasyORM
//
//  Created by 蔡杰 on 2017/7/31.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

import Foundation
import Foundation

//高度抽象表达式(可表示)
//操作类型（创建表、查询表、删除表等等...）
//字段类型（表字段）
//数据类型（字段类型：Int类型、可选类型、Double类型等...）
public protocol Expressible {
    
    //以下expression:就是一个SQL语句
    //合并表达式用的
    //(高度抽象为一个表达式)->SQL语句->将对象expression进行遍历，然后构建SQL语句
    var expression:Expression<Void> { get }
    
}

extension Expressible {
    
    //将expression->转成SQL语句
    //create table t_user(name text);
    //insert into t_user(name) values(?)
    //遇到了"?" = "Dream"
    func asSQL() -> String {
        let sql = expression
        var index = 0
        return sql.template.characters.reduce(""){template, character in
            let append: String
            
            if character == "?" {
                //拼接参数->"?"
                append = transcode(sql.bindings[index])
                index += 1
            } else {
                //拼接关键字
                append = String(character)
            }
            return template + append
        }
    }
    
}

//具体抽象字段表达式
//这个协议：定义了字段表达式抽象
public protocol ExpressionType : Expressible{
    //具体字段
    //抽象一：数据类型->(Int、Int32、Double等...)
    //具体类型？->泛型设计->默认是Void类型
    associatedtype UnderlyingType = Void
    
    //抽象二：模版(例如：表名称、字段名称等等...)
    var template: String { get }
    
    //抽象三：绑定参数(表字段->参数列表、约束条件)
    //保存：表字段描述信息("类型"、"NOT NULL")
    var bindings: [Binding?]{ get }
    
    //抽象四：构造方法
    //初始化这些参数:template、bindings
    init(_ template: String, _ bindings: [Binding?])
}


//处理特殊字段：给我们字段加入特殊字符
//支持这两种写法
//写法一：字段不加""号
//create table t_user (t_user_sex text, t_user_name text);
//写法二：字段加""号
//create table "t_user_1" ("t_user_sex" text, "t_user_name" text);
extension ExpressionType {
    
    //写法一：字段加""号
    //例如：create table t_user (t_user_sex text, t_user_name text);
    public init(literal: String) {
        self.init(literal, [])
    }
    
    //写法二：字段加""号
    //create table "t_user_1" ("t_user_sex" text, "t_user_name" text);
    public init(_ indentifer: String){
        self.init(literal: indentifer.quote())
    }
    
}

//扩展：字段类型
extension ExpressionType {
    public var expression: Expression<Void> {
        return Expression(template, bindings)
    }
}


//结构体->字段表达式类型实现类
public struct Expression<Datatype> : ExpressionType {
    //指定具体的数据类型
    public typealias UnderlyingType = Datatype
    //继承模版
    public var template: String
    //继承字段
    public var bindings: [Binding?]
    //构造方法
    public init(_ template: String, _ bindings: [Binding?]) {
        self.template = template
        self.bindings = bindings
    }
}





//Expressible可以是一种可选类型，也就是说 = nil
//扩展功能:表字段允许为空
//处理字段类型->表达式
//可选类型协议(自定类型)
public protocol OptionalType{
    //泛型
    associatedtype WrappedType
}
//Optional系统提供
extension Optional : OptionalType {
    //给WrappedType取一个别名: Wrapped
    public typealias WrappedType = Wrapped
}

//扩展抽象表字段->表达式->ExpressionType
//约束一:数据类型约束
//规定泛型类型必需是：Value子类(泛型约束条件)
extension ExpressionType where UnderlyingType : Value {
    //表字段值
    public init(value: UnderlyingType){
        //占位符
        //insert into t_user(name,sex) values(?,?)
        self.init("?", [value.datatypeValue])
    }
}

//约束二:可选类型
//约束框架锁能够支持类型(其他不支持类型，不允许传递)
extension ExpressionType where UnderlyingType : OptionalType, UnderlyingType.WrappedType : Value {
    
    //插入数据用到
    //为空(传递空值)
    //插入数据：插入null
    public static var null: Self {
        return self.init(value: nil)
    }
    
    public init(value: UnderlyingType.WrappedType?){
        self.init("?", [value?.datatypeValue])
    }
    
}


extension Value {
    
    public var expression: Expression<Void> {
        //最终表达式(将多个合并为一个)
        return Expression(value: self).expression
    }
    
}

