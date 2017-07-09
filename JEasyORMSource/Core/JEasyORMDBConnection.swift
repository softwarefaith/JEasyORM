//
//  JEasyORMDBConnection.swift
//  JEasyORM
//
//  Created by 蔡杰 on 2017/7/3.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

import UIKit

let kQueueLabel = "com.JEasy.ORMDBConnection"

public final class JEasyORMDBConnection {
    

    /// 数据库存储方式
    ///
    /// - inMemory: 内存存储
    /// - temporary: 临时存储
    /// - uri: 路径创建数据库
    enum StorageMode: CustomStringConvertible{
        
        case inMemory
        case temporary
        case uri(String)

        var description: String {
            
            switch self {
                case .inMemory:
                    return ":memory:"
                case .temporary:
                    return ""
                case .uri(let path):
                    return path;
            }
        }
    }
    
    /// 数据库操作
    ///
    /// - insert: 插入
    /// - update: 更新
    /// - delete: 删除
    /// - select: 查询
        enum Operation {
        
        case insert
        case update
        case delete
        case select
        
        //将数据库类型->转成枚举类型
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
    //MARK:构建数据库链接
    fileprivate var handler: OpaquePointer? = nil
    //队列标记
    fileprivate var queue = DispatchQueue(label: kQueueLabel)
    fileprivate static var queueKey = DispatchSpecificKey<Int>()
    fileprivate lazy var queueContext: Int = unsafeBitCast(self, to: Int.self)
    
    init(_ location:StorageMode = .inMemory,readly:Bool = false) throws {
        
        let flags = readly ? SQLITE_OPEN_READONLY : SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE
        
        
        try check(sqlite3_open_v2(location.description, &handler, flags | SQLITE_OPEN_FULLMUTEX, nil))
        //操作数据库时避免并发
        queue.setSpecific(key: JEasyORMDBConnection.queueKey, value: queueContext)
        
    }
    
   convenience init(_ fileName: String, readly:Bool = false) throws {
       try self.init(.uri(fileName), readly: readly)
    }
    //MARK:数据库异常处理
   @discardableResult
    func check(_ resultCode: Int32) throws -> Int32 {
        guard let error = DBResult(code:resultCode,connection:self) else {
            return resultCode;
        }
        throw error;
    }
    
    //MARK:检测数据库操作
    //-- 数据库权限 
    /*returns 1 if the database N
    ** of connection D is read-only, 0 if it is read/write, or -1 if N is not
    ** the name of a database on connection D
    */
    public var readonly: Bool {
        return sqlite3_db_readonly(handler, nil) == 1
    }
    //--当前数据库插入最近一条数据的ID
    public var changes: Int {
        return Int(sqlite3_changes(handler))
    }
    
    //--数据库打开到目前为止所受影响的行数
    public var totalChanges: Int {
        return Int(sqlite3_total_changes(handler))
    }
    

}

public enum DBResult: Error {
    
    private static let successCode = [SQLITE_OK,SQLITE_ROW,SQLITE_DONE];
    
    case error(message:String, code: Int32)
    
    init?(code: Int32, connection: JEasyORMDBConnection) {
        guard !DBResult.successCode.contains(code) else {
            return nil
        }
        
        let  message = String(cString: sqlite3_errmsg(connection.handler))
        self = .error(message: message, code: code)
    }
}
