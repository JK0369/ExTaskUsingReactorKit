//
//  TaskCellReactor.swift
//  ExTaskList
//
//  Created by 김종권 on 2021/12/02.
//

import ReactorKit
import RxSwift
import RxCocoa

class TaskCellReactor: Reactor {
    typealias Action = NoAction
    
    let initialState: Task
    
    init(task: Task) {
        self.initialState = task
    }
}
