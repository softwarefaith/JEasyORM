//
//  JEasyType.swift
//  JEasyORM
//
//  Created by 蔡杰 on 2017/7/10.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

//所有类型的基础类(数字类型 以及 值类型)
public protocol Binding {
    
}

public protocol Number: Binding {
    
}
//保存数据库字段名称以及类型 -> 程序中的属性名称和值以及类型
public protocol Value: Binding {
    //程序当中的数据类型
    associatedtype DataType: Binding
    //程序返回值类型(可能需要转换)
    associatedtype ValueType = Self
    
    //数据库表字段名称
    static var decareDataType: String {get}
    //将程序中数据类型 ->  数据库类型
    static func fromDataTypeValue(_ dataTypeValue:DataType) ->ValueType
    
    //当前返回值类型
    var dataTypeValue: DataType {get}
    
}

//MARK: 数字类型
extension Int: Number {
    
}

extension Double: Number {
    
}

extension Float: Number {
    
}

//MARK: 值类型

