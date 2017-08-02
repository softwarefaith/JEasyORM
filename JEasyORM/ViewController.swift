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
        // Do any additional setup after loading the view, typically from a nib.
        //处理异常
        do {
            //执行SQL语句
            let path = Bundle.main.path(forResource: "test", ofType: ".db")
            print(path!)
            //数据库连接:DBConnection
            let connection = try DBConnection(path!)
            print(connection.readonly)
            
            //直接执行SQL
            try connection.execute("create table t_user(t_user_sex text,t_user_name text)")
            
            let statement = try connection.run("insert into t_user(t_user_sex,t_user_name) values(?,?)", "男","Dream")
            print(statement.description)
            
          
        } catch {
            print("出现了异常\(error)")
        }
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

