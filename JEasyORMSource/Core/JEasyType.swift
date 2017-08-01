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
public protocol Value: Binding,Expressible{
    //程序当中的数据类型
    associatedtype DataType: Binding
    //程序返回值类型(可能需要转换)
    associatedtype ValueType = Self
    
    //数据库表字段名称
    static var declareDatatype: String {get}
    //将程序中数据类型 ->  数据库类型
    static func fromDatatypeValue(_ datatypeValue:DataType) ->ValueType
    
    //当前返回值类型
    var datatypeValue: DataType {get}
    
}

///Double类型
//数据库里面：程序中Double类型->REAL类型
extension Double : Number, Value {
    
    //程序中Double类型->REAL类型
    public static var declareDatatype: String {
        return "REAL"
    }
    
    public static func fromDatatypeValue(_ datatypeValue: Double) -> Double {
        return datatypeValue
    }
    
    public var datatypeValue: Double {
        //返回值
        return self
    }
    
}

extension Float : Number, Value {
    //程序中Float类型->REAL类型
    public static var declareDatatype = "REAL"
    
    public static func fromDatatypeValue(_ datatypeValue: Float) -> Float {
        return datatypeValue
    }
    
    public var datatypeValue: Float {
        //返回值
        return self
    }
    
}

//Int类型
//数据库里面：程序中整形类型->integer类型
extension Int : Number , Value {
    //程序中Int类型->INTEGER类型
    public static var declareDatatype = "INTEGER"
    
    public static func fromDatatypeValue(_ datatypeValue: Int) -> Int {
        return datatypeValue
    }
    
    public var datatypeValue: Int {
        //返回值
        return self
    }
}

//Int32位类型
extension Int32 : Number , Value {
    //程序中Int32类型->INTEGER类型
    public static var declareDatatype = "INTEGER"
    
    public static func fromDatatypeValue(_ datatypeValue: Int32) -> Int32 {
        return datatypeValue
    }
    
    public var datatypeValue: Int32 {
        //返回值
        return self
    }
}

//Int64位类型
extension Int64 : Number , Value {
    //程序中Int64类型->INTEGER类型
    public static var declareDatatype = "INTEGER"
    
    public static func fromDatatypeValue(_ datatypeValue: Int64) -> Int64 {
        return datatypeValue
    }
    
    public var datatypeValue: Int64 {
        //返回值
        return self
    }
}

//以此类推...


//例如：String(字符串、Bool类型等等...)，自己扩展

extension String : Binding , Value {
    //程序中Int64类型->TEXT类型
    public static var declareDatatype = "TEXT"
    
    public static func fromDatatypeValue(_ datatypeValue: String) -> String {
        return datatypeValue
    }
    
    public var datatypeValue: String {
        //返回值
        return self
    }
}


extension Bool : Binding , Value {
    //程序中Int64类型->TEXT类型(0和1)
    public static var declareDatatype = Int.declareDatatype
    
    public static func fromDatatypeValue(_ datatypeValue: Int) -> Bool {
        return datatypeValue != 0
    }
    
    public var datatypeValue: Int {
        //返回值
        return self ? 1 : 0
    }
}


