//
//  Filter.swift
//  JEasyORM
//
//  Created by 蔡杰 on 2017/7/31.
//  Copyright © 2017年 蔡杰. All rights reserved.
//


import Foundation

//过滤器：where条件
extension QueryType {
    
    //编写条件语句:是否有条件
    var whereStatement: Expressible? {
        guard let filters = manager.filters else {
            return nil
        }
        return " ".join([
                Expression<Void>(literal: "WHERE"),
                filters
            ])
    }
    
    public func filter(_ isWhere: Expression<Bool>) -> Self {
        return self.filter(Expression<Bool?>(isWhere))
    }
    
    //where id = 1 and name = "Dream"
    public func filter(_ isWhere: Expression<Bool?>) -> Self {
        //拼接条件
        var query = self
        query.manager.filters = self.manager.filters.map{ $0 && isWhere} ?? isWhere
        return query
    }
    
}
