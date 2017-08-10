//
//  ViewController.swift
//  JEasyORM
//
//  Created by 蔡杰 on 2017/7/3.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //打印这个对象的详情(每一个地方都需要一个个输出)
        //从写OC中的discription方法
        //        let user = User(name: "Dream", sex: "男", age: 100)
        //        print(user.description)
        
        //处理异常
        do {
            //执行SQL语句
            let path = Bundle.main.path(forResource: "test", ofType: ".db")
            print(path!)
            //数据库连接:DBConnection
            let connection = try DBConnection(path!)
            print(connection.readonly)
            //
            //            //直接执行SQL
            //            try connection.execute("create table t_user(t_user_sex text, t_user_name text)")
            //但是有一个严重问题?
            //参数绑定？
            //以下SQL如何处理？
            //如果采用该方式：需要每一次手动的绑定参数(例如：10张表，100个操作，手动绑定要写100次)
            //参数类型不一样
            //            try connection.execute("insert into t_user(t_user_sex,t_user_name) values(?,?)")
            
            
            //解决这个问题？
            //动态绑定?
            //不管用户怎么传递参数，顺序及时乱的，也没有关系，我也可以做到一一对应
            //            let statement = try connection.run("insert into t_user(t_user_sex, t_user_name, t_user_age) values(?,?)", "男","Dream")
            //            print(statement.description)
            
            //下一节课：创建表(面向对象方式创建表)
            //Table结构体(设计到：Builder设计模式)
            
            //可以使用
            //            let expression = Expression<Int>("id",[])
            //            print("表字段：\(expression.template)")
            
            
            let table = Table("t_user")
            print("表名：\(table.manager.from)")
            let id  = Expression<Int>("t_user_id")
            let name  = Expression<String>("t_user_name")
            let sql = table.create({ (build) in
                build.column(id).column(name)
            })
            try connection.run(sql)
            
            //非常麻烦
            //实现一个非常牛逼操作(动态插入，只需要传递参数即可)->面向对象方式进行设计
            //insert into t_user(id,name) values("1","肥牛哥");
            
            
            //            try connection.run(table.drop())
            
            
            //测试：插入语句
            //直接插入对象
            let insert = table.insert(id --> 10, name --> "Dream")
            let rowid = try connection.run(insert)
            print(rowid)
            
            let insert_1 = table.insert(id --> 20, name --> "Andy同学")
            try connection.run(insert_1)
            
            let insert_2 = table.insert(id --> 1, name --> "肥牛哥同学")
            try connection.run(insert_2)
            
            let insert_4 = table.insert(id --> 2, name --> "Nick同学")
            try connection.run(insert_4)
            
            let insert_3 = table.insert(id --> 2, name --> "Flonger同学")
            try connection.run(insert_3)
            
            
            
            
            //            try connection.run(table.delete())
            
            //测试：更新
            //修改所有
            //            let update = table.update(id --> 10,name --> "流浪人")
            //            try connection.run(update)
            
            //添加条件删除
            //            let filter = table.filter(id == 10)
            //采用带条件的filter执行删除
            //            let delete = filter.delete()
            //            try connection.run(delete)
            
            //            let update = filter.update(name --> "Somebody同学")
            //            try connection.run(update)
            
            
            //根据字段进行查询
            //指定查询字段
            //            for t in try connection.prepare(table.select(id,name)) {
            ////                print("姓名：\(t[name])")
            //                print("id:\(t[id])    姓名：\(t[name])")
            //            }
            
            //查询所有数据
            //            for t in try connection.prepareAll(table) {
            //                print("id:\(t[id])  姓名：\(t[name])")
            //            }
            
            //查询ID = 10 对应的->name
                        let tableFilter = table.filter(id == 20)
                        for t in try connection.prepare(tableFilter.select(name)) {
                            print("--------姓名：\(t[name])")
                        }
            
                        for t in try connection.prepareAll(table.order(id.asc,name.asc)) {
                            print("---------id:\(t[id])  姓名：\(t[name])")
                        }
            
            //查询多少条数据
//            for t in try connection.prepareAll(table.limit(2, offset: 2)) {
//                print("id:\(t[id])  姓名：\(t[name])")
//            }
//            //学习一个国外大牛->写的框架
//            
//            //第一步：数据库调用（初始化）
//            //第二步：Statement->执行SQL
//            let value = try connection.scalar(table.count)
//            print("行数：\(value)")
            
                   } catch {
            print("出现了异常\(error)")
        }
        
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

