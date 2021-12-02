//
//  NSObject+ClassName.swift
//  ExTodo
//
//  Created by 김종권 on 2021/12/01.
//

import Foundation

extension NSObject {
    class var className: String {
        return String(describing: self)
    }
}
