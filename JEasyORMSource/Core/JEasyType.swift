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
//值类型 : Value类型
//特点一：保存了数据库表字段名称和类型->对应->程序当中属性名称和值以及类型
//特点二：并不知道具体是什么类型，然后它又要规定类型->泛型
public protocol Value: Binding,Expressible{
    //泛型一：数据类型：程序当中数据类型(Int、Double、Float、String)
    associatedtype DataType: Binding
    //泛型二：返回值类型：程序当中返回值类型(有可能要进行类型转换)
    associatedtype ValueType = Self
    
    //作用：数据库表字段名称和表字段类型
    
    //属性：数据库表字段名称
    static var declareDatatype: String {get}
     //方法：将程序中数据类型->转成->数据库类型
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


