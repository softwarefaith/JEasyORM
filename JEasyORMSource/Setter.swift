
//
//  Setter.swift
//  JEasyORM
//
//  Created by 蔡杰 on 2017/7/31.
//  Copyright © 2017年 蔡杰. All rights reserved.
//


//对象形式保存参数值和表字段
public struct Setter {
    
    //表达式(字段名称)
    let column: Expressible
    //表达式(字段值)
    let value: Expressible
    
    //构造方法重载
    init<V : Value>(column: Expression<V>,value: Expression<V>){
        self.column = column
        self.value = value
    }
    
    init<V : Value>(column: Expression<V>,value: V){
        self.column = column
        self.value = value
    }
    
    init<V : Value>(column: Expression<V?>,value: Expression<V>){
        self.column = column
        self.value = value
    }
    
    init<V : Value>(column: Expression<V?>,value: Expression<V?>){
        self.column = column
        self.value = value
    }
    
    init<V : Value>(column: Expression<V?>,value: V?){
        self.column = column
        self.value = Expression<V?>(value: value)
    }
    
}

//Setter也是一个表达式类型
extension Setter : Expressible {
    
    //结构: "id = 10"
    public var expression: Expression<Void>{
        return "=".infixs(column, value,wrap: false)
    }
    
}

//重载运算符
//ColumnAssignment权限
//infix operator || : LogicalDisjunctionPrecedence
//infix operator && : LogicalConjunctionPrecedence
//infix operator < : ComparisonPrecedence
//infix operator <= : ComparisonPrecedence
//infix operator > : ComparisonPrecedence
//infix operator >= : ComparisonPrecedence
//infix operator == : ComparisonPrecedence
//infix operator != : ComparisonPrecedence
//infix operator === : ComparisonPrecedence
//infix operator !== : ComparisonPrecedence
//infix operator ~= : ComparisonPrecedence
//infix operator ?? : NilCoalescingPrecedence
//infix operator + : AdditionPrecedence
//infix operator - : AdditionPrecedence
//infix operator &+ : AdditionPrecedence
//infix operator &- : AdditionPrecedence
//infix operator | : AdditionPrecedence
//infix operator ^ : AdditionPrecedence
//infix operator * : MultiplicationPrecedence
//infix operator / : MultiplicationPrecedence
//infix operator % : MultiplicationPrecedence
//infix operator &* : MultiplicationPrecedence
//infix operator & : MultiplicationPrecedence
//infix operator << : BitwiseShiftPrecedence
//infix operator >> : BitwiseShiftPrecedence
//infix operator ..< : RangeFormationPrecedence
//infix operator ... : RangeFormationPrecedence
//infix operator *= : AssignmentPrecedence
//infix operator /= : AssignmentPrecedence
//infix operator %= : AssignmentPrecedence
//infix operator += : AssignmentPrecedence
//infix operator -= : AssignmentPrecedence
//infix operator <<= : AssignmentPrecedence
//infix operator >>= : AssignmentPrecedence
//infix operator &= : AssignmentPrecedence
//infix operator ^= : AssignmentPrecedence
//infix operator |= : AssignmentPrecedence

//运算符计算顺序
//结合类型：left(左结合)、right(右结合)、none(无)
//left：从左到右进行计算
//例如：a + b - c - d
//"+"->"-"->"-"
//right: 从右到左
//例如：a + b - c - d
//"-" "-" "+"
//left、right关键字(固定写法)

precedencegroup ColumnAssignment {
    associativity: left
    //是否是赋值运算符
    assignment: true
    //指定运算符优先级
    //优先级要低于AssignmentPrecedence类型操作符
    lowerThan: AssignmentPrecedence
}

//prefix:前缀
//例如：++a
//postfix:后缀
//例如：a++
//infix:中缀
//例如：a + b
infix operator --> : ColumnAssignment

//"-->"方法重载
public func --><V : Value>(column: Expression<V>, value: Expression<V>) -> Setter {
    return Setter(column: column, value: value)
}
public func --><V : Value>(column: Expression<V>, value: V) -> Setter {
    return Setter(column: column, value: value)
}
public func --><V : Value>(column: Expression<V?>, value: Expression<V>) -> Setter {
    return Setter(column: column, value: value)
}
public func --><V : Value>(column: Expression<V?>, value: Expression<V?>) -> Setter {
    return Setter(column: column, value: value)
}
public func --><V : Value>(column: Expression<V?>, value: V?) -> Setter {
    return Setter(column: column, value: value)
}



