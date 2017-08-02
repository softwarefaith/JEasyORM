
//
//  Statement.swift
//  Dream_20170626_Architect_DatabaseFramework
//
//  Created by Dream on 2017/6/28.
//  Copyright © 2017年 Tz. All rights reserved.
//

import UIKit


//扩展知识?
//sqlite3_destructor_type解释
//SQLITE_STATIC(0):表指针对应的内容恒定不变的(表数据不可修改->可以这理解)
let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
//SQLITE_TRANSIENT(1):表示数据库可以读写，随时随刻石可以改变的
let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)


//SQL语句：参数绑定(太监类)
public final class Statement {
    
    fileprivate let connection : DBConnection
    //数据库表指针
    fileprivate var handle : OpaquePointer? = nil

    //第一步：实现构造方法
    init(_ connection: DBConnection,_ SQL: String) throws {
        self.connection = connection
        //执行准备表(验证)
        //预处理语句(没有执行，只是准备，因为你还需赋值)
        //参数一：数据库指针
        //参数二：SQL语句
        //参数三：SQL语句长度（自动检测长度，读取第一个结束符执行SQL）
        //自己研究
        //例如：sql = "insert into t_user(t_user_sex,t_user_name) values(?,?); insert into t_teacher(t_teacher_sex,t_teacher_name) values(?,?);"
        //参数四：数据库表指针
        //参数五：SQL语句可能存在多个结束符，指定剩下的没有执行编译SQL
        //设置：nil->表示我只执行一个，如果你有多个与我无关
        try connection.check(sqlite3_prepare_v2(connection.handle,
                                                SQL,
                                                -1,
                                                &handle,
                                                nil))
        
    }
    
    //析构函数->是否内存
    deinit {
        //是否表指针
        sqlite3_finalize(handle)
    }
    
    
    /********************绑定参数--start************************/
    //第二步：绑定参数
    //一种是可变参数
    public func bind(_ values:Binding?...) -> Statement {
        return self.bind(values)
    }
    
    //一种是数组参数
    public func bind(_ values:[Binding?]) -> Statement {
        if values.isEmpty {
            return self
        }
        //重置缓存
        reset()
        
        //判定参数的数量是否合数据库的表字段数量一致
        guard values.count == Int(sqlite3_bind_parameter_count(handle)) else {
            fatalError("参数列表和数据库表字段数量不匹配")
        }
        
        //将数据绑定到SQL
        for index in 1...values.count {
            bind(values[index - 1], index: index)
        }
        return self
    }
    
    //一种是字典参数
    public func bind(_ values:[String:Binding?]) -> Statement {
        reset()
        for (name, value) in values {
            //判定这个属性是否存在
            let index = sqlite3_bind_parameter_index(handle, name)
            guard index > 0 else {
                fatalError("没有这个字段")
            }
            bind(value, index: Int(index))
        }
        return self
    }
    
    /**********************end************************/
    
    
    /********************执行SQL语句--start************************/
    //执行SQL语句
    //一种是可变参数
    public func run(_ bindings:Binding?...) throws -> Statement{
        guard bindings.isEmpty else {
            //不为空，绑定
            return try self.run(bindings)
        }
        //重置SQL语句，但是不清空数据
        reset(clearBinding: false)
        //执行SQL语句
        try step()
        return self
    }
    
    //一种是数组参数
    public func run(_ bindings:[Binding?]) throws -> Statement{
        return try self.bind(bindings).run()
    }
    
    //一种是字典参数
    public func run(_ bindings:[String:Binding?]) throws -> Statement{
        return try self.bind(bindings).run()
    }
    
    /**********************end************************/
    
    
    fileprivate func bind(_ value:Binding?,index:Int){
        if value == nil {
            sqlite3_bind_null(handle, Int32(index))
        } else if let v = value as? Double {
            sqlite3_bind_double(handle, Int32(index), v)
        } else if let v = value as? Float {
            sqlite3_bind_double(handle, Int32(index), Double(v))
        } else if let v = value as? Int {
            sqlite3_bind_int(handle, Int32(index), Int32(v))
        } else if let v = value as? Int32 {
            sqlite3_bind_int(handle, Int32(index), Int32(v))
        } else if let v = value as? Int64 {
            sqlite3_bind_int64(handle, Int32(index), Int64(v))
        } else if let v = value as? Bool {
            self.bind(v.datatypeValue, index: index)
        } else if let v = value as? String {
            //参数一：表指针
            //参数二：字段下标
            //参数三：字段对应的值
            //参数四：表示第三个参数长度(-1:表示系统自动检测长度)
            //参数五：是否缓存数据
            sqlite3_bind_text(handle,
                              Int32(index),
                              v,
                              -1, SQLITE_TRANSIENT)
        } else if let v = value {
            fatalError("没有指定类型\(v)")
        }
    }
    
    //执行SQL
    @discardableResult public func step() throws -> Bool {
        return try connection.dbSync {
            try self.connection.check(sqlite3_step(self.handle)) == SQLITE_ROW
        }
    }
    
    //情况缓存
    public func reset(clearBinding shouldClear: Bool = true){
        //sqlite3_reset作用：将一个SQL语句声明状态进行重置，是的可以反复的使用这个SQL操作
        //例如：执行第一次表，是不是有缓存
        //原始状态："insert into t_user(name) values(?);"
        //插入数据: name = "Dream"
        //执行状态: "insert into t_user(name) values("Dream");"
        //还原状态
        sqlite3_reset(handle)
        if shouldClear {
            //清空数据
            sqlite3_clear_bindings(handle)
        }
    }
    
    
}


extension Statement : CustomStringConvertible {
    
    public var description: String {
        return String(cString: sqlite3_sql(handle))
    }
    
}





