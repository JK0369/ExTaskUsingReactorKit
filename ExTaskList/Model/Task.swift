//
//  Task.swift
//  ExTaskList
//
//  Created by 김종권 on 2021/12/02.
//

import ReactorKit
import Differentiator

typealias TaskListSection = SectionModel<Void, TaskCellReactor>

struct Task: Codable, Identifiable, Equatable {
    var id = UUID().uuidString
    var title: String
    var isSelected: Bool = false
    
    init(title: String) {
        self.title = title
    }
}
