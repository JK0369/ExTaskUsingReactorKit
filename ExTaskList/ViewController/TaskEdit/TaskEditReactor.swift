//
//  TaskEditReactor.swift
//  ExTaskList
//
//  Created by 김종권 on 2021/12/02.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class TaskEditReactor: Reactor {
    
    
    // MARK: Model
    
    enum Action {
        case didInputTaskTitle(String)
        case didTapCancelButton
        case didTapDoneButton
    }
    
    enum Mutation {
        case updateTaskTitle(String)
        case dismiss
    }
    
    struct State {
        var title: String
        var isDismissed: Bool = false
        var canSubmit: Bool = false
    }
    
    
    // MARK: Properties
    
    let initialState: State
    let taskService: TaskService
    
    
    // MARK: Initializing
    
    init(initialState: State, taskService: TaskService) {
        self.initialState = initialState
        self.taskService = taskService
    }
    
    
    // MARK: Transform
    
    func mutate(action: Action) -> Observable<Mutation> {
        let newMutation: Observable<Mutation>
        
        switch action {
        case .didInputTaskTitle(let title):
            newMutation = .just(.updateTaskTitle(title))
        case .didTapCancelButton:
            newMutation = .just(.dismiss)
        case .didTapDoneButton:
            newMutation = taskService.create(title: currentState.title).map { _ in .dismiss }
        }
        
        return newMutation
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .updateTaskTitle(let title):
            newState = getUpdatedTitleState(state: state, title: title)
        case .dismiss:
            newState.isDismissed = true
        }
        
        return newState
    }
    
    private func getUpdatedTitleState(state: State, title: String) -> State {
        var state = state
        state.canSubmit = !title.isEmpty
        state.title = title
        return state
    }
    
}
