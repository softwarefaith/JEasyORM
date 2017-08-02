



//
//  DBConnection.swift
//  JEasyORM
//
//  Created by 蔡杰 on 2017/7/31.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

import UIKit


//class User : CustomStringConvertible{
//    
//    var name:String
//    var sex:String
//    var age:Int
//    
//    init(name:String,sex:String,age:Int) {
//        self.name = name
//        self.sex = sex
//        self.age = age
//    }
//    
//    public var description: String {
//        return "name = \(name), sex = \(sex), age = \(age)"
//    }
//    
//}


//数据库连接(不允许继承：太监类)
public final class DBConnection {

    //第一步：定义数据库存储方式(枚举、常量)
    public enum Location : CustomStringConvertible{
        //第一种：内存数据库(":memory:")
        case inMemory
        //第二种：临时数据库("")
        case temporary
        //第三种：指定地址("路径")
        case uri(String)
        
        //处理文件名称(具体内容)
        public var description: String {
            switch self {
            case .inMemory:
                return ":memory:"
            case .temporary:
                return ""
            case .uri(let path):
                return path
            }
        }
        
    }
    
    
    //第二步：定义数据库操作类型
    //我为啥设计这个枚举?
    //原因因为：数据库操作类型(常量)
    //为了更加方便扩展识别数据库操作(更加直观)->增强可读性
    //定义枚举：让用户直观去选择数据库操作(四个类型)
    public enum Operation {
        //    第一个操作：添加数据->insert
        case insert
        //    第二个操作：更新数据->update
        case update
        //    第三个操作：删除数据->delete
        case delete
        //    第四个操作：查询数据->select
        case select
        
        //这个构造方法目的：将数据库类型->转成枚举类型
        fileprivate init(value:Int32){
            switch value {
            case SQLITE_INSERT:
                self = .insert
            case SQLITE_UPDATE:
                self = .update
            case SQLITE_DELETE:
                self = .delete
            case SQLITE_SELECT:
                self = .select
            default:
                fatalError("没有这个类型:\(value)")
            }
        }
        
    }
    
    
    //第三步：构建数据库连接（构造方法）
    
    var handle : OpaquePointer? = nil
    fileprivate var queue = DispatchQueue(label: "sqlite")
    //队列标记
    fileprivate static let queueKey = DispatchSpecificKey<Int>()
    
    //细节(语法：差点忘记)
    //没有初始化(直接初始化)
    //继承了NSObject直接使用成员变量
    //如果你没有继承NSObject那么需要使用懒加载(因为对象没有创建)
    fileprivate lazy var queueContext : Int = unsafeBitCast(self, to: Int.self)
    
    //参数默认值
    //_ location:Location = .inMemory
    init(_ location:Location = .inMemory, readonly:Bool = false) throws {
        //打开数据库
        //参数一：数据库类型
        //参数二：数据库指针
        //参数三：标记(权限)
        //参数四：传递nil
        //SQLITE_OPEN_FULLMUTEX:什么意思？串行结构模式->排队->队列
        //一个个执行
        let flags = readonly ? SQLITE_OPEN_READONLY : SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE
        try check(sqlite3_open_v2(location.description, &handle, flags | SQLITE_OPEN_FULLMUTEX, nil))
        
        //给我们数据库设置标记(队列)
        //目的：操作数据库的时候避免并发
        //子线程->同时操作数据库->保证安全
        //一个个任务执行->按照顺序执行
        queue.setSpecific(key: DBConnection.queueKey, value: queueContext)
    }
    
    //当前对象构造方法调用当前对象构造方法(当前)->需要加入convenience
    //遍历构造器
    convenience init(_ fileName: String, readonly:Bool = false) throws {
        //语法规定(处理异常)
        try self.init(.uri(fileName), readonly: readonly)
    }
    
    
    //第四步：处理数据库异常信息
    //将数据库错误信息->转成可读性强异常类
    //原始数据库->宏定义->转成了面向对象形式表示
    @discardableResult func check(_ reusltCode: Int32) throws -> Int32 {
        guard let error = DBResult(errorCode: reusltCode, connection: self) else {
            //没有异常，直接返回
            return reusltCode
        }
        //有异常抛出异常
        throw error
    }
    
    
    //第五步：检测数据库操作？
    //作用：后面会用到、扩展知识(普及)
//    获取数据库权限
    public var readonly : Bool {
        return sqlite3_db_readonly(handle, nil) == 1
    }
    
    
//    当前数据库插入最近一条数据ID
    public var changes: Int {
        return Int(sqlite3_changes(handle))
    }
    
    //获得插入数据受影响的行的id
    public var lastInsertRowid: Int64 {
        return sqlite3_last_insert_rowid(handle)
    }
    
//    获取数据库打开连接到目前为止操作表数据受影响行数
    public var totalChnages : Int {
        return Int(sqlite3_total_changes(handle))
    }
//    等等...
    
    //第六步：执行SQL语句
    public func execute(_ sql: String) throws {
        //派上用场->保证数据库操作按照执行顺序一个个执行
        _ = try dbSync {
            try self.check(sqlite3_exec(self.handle, sql, nil, nil, nil))
        }
    }
    
    
    
    /****************执行SQL语句****start************/
    
    //绑定参数类型：一种是可变参数、一种是数组参数、一种是字典参数
    //分析：如果你的参数类型是Any类型，
    //存在问题：那么不好扩展(例如：数据库表字段名称、数据库表字段类型、数据库表字段对应的Swift语言中属性名称、属性类型)
    
    //面向协议编程
    //以下的三个方法：方法重载
    //解决方案:扩展协议(例如：给Int扩展、给Double扩展等等...)
    //可变参数
    @discardableResult public func run(_ statement:String,_ bindings:Binding...) throws -> Statement {
        return try self.run(statement, bindings)
    }
    
    //数组参数
    @discardableResult public func run(_ statement:String,_ bindings:[Binding?]) throws -> Statement {
        //构建SQL
        return try self.prepare(statement).run(bindings)
    }
    
    //字典参数
    @discardableResult public func run(_ statement:String,_ bindings:[String:Binding?]) throws -> Statement {
        //先去->构建SQL(绑定值)->执行SQL
        return try self.prepare(statement).run(bindings)
    }
    
    
    /***********************end*********************/
    
    
    /****************SQL绑定参数****start************/
    
    //以下的三个方法：方法重载
    //绑定参数
    //一种是可变参数
    public func prepare(_ statement:String,_ bindings:Binding?...) throws -> Statement {
        if !bindings.isEmpty {
            return try self.prepare(statement, bindings)
        }
        return try Statement(self, statement)
    }
    
    //一种是数组参数
    public func prepare(_ statement:String,_ bindings:[Binding?]) throws -> Statement {
        return try self.prepare(statement).bind(bindings)
    }
    
    //一种是字典参数
    public func prepare(_ statement:String,_ bindings:[String:Binding?]) throws -> Statement {
        return try self.prepare(statement).bind(bindings)
    }
    
    /****************end************/
    
    
    //保证同步->传递闭包
    //方法泛型
    //rethrows继续抛出异常
    //编译器自动识别当前类型
    public func dbSync<T>(_ callback:@escaping () throws -> T) rethrows -> T {
        //返回任何类型
        var success:T?
        //任何类型(DBResult等等...)
        var failure:Error?
        
        //定义临时代码块
        //用于处理异常结果
        //定义了自动闭包
        let box : () -> Void = {
            //逻辑代码块
            do {
                success = try callback()
            } catch {
                //catch忽略参数(编译器会自动识别)
                failure = error
            }
        }
        
        //当前队列
        if DispatchQueue.getSpecific(key: DBConnection.queueKey) == queueContext {
            //当前线程，当前队列
            box()
        } else {
            //其他子队列
            queue.sync(execute: box)
        }
        
        //处理异常
        //异常抛出给客户端处理
        if let fail = failure {
            //存在异常(报错)
            //这个问题?
            //语法错误
//            throw fail
            //正确写法
            try { () -> Void in
                throw fail
            }()
        }
        
        return success!
    }
    
}




//枚举定义异常信息(数据库返回结果)
//构造方法前面加"?"号表示当前枚举是可选类型
public enum DBResult : Error {
    
    //如何表示数据库成功?
    //SQLITE_OK:表示当前操作执行成功
    //SQLITE_ROW:执行sqlite3_step()受影响行数(删除、插入、更新等等...)
    //SQLITE_DONE:执行sqlite3_step()函数完成
    fileprivate static let successCodes = [SQLITE_OK,SQLITE_ROW,SQLITE_DONE]
    
    case error(message:String,code:Int32)
    
    init?(errorCode: Int32, connection:DBConnection) {
        guard !DBResult.successCodes.contains(errorCode) else {
            //成功了嘛
            return nil
        }
        //捕获异常
        let message = String(cString: sqlite3_errmsg(connection.handle))
        self = .error(message: message, code: errorCode)
    }
    
}






