//
//  TaskListReactor.swift
//  ExTaskList
//
//  Created by 김종권 on 2021/12/02.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class TaskListReactor: Reactor {
    
    
    // MARK: Model
    
    enum Action {
        case didInitBinding
        case didSelect(IndexPath)
        case didTapAddButton
    }
    
    enum Mutation {
        case setSections([TaskListSection])
        case updateSectionItem(IndexPath, TaskListSection.Item)
        case insertSectionItem(IndexPath, TaskListSection.Item)
        case presentEditTask
    }
    
    struct State {
        var sections: [TaskListSection]
        var isPresentEditTask: Bool = false
    }
    
    
    // MARK: Properties
    
    let initialState: State
    let taskService: TaskService
    
    
    // MARK: Initializing
    
    init(initialState: State, taskService: TaskService) {
        self.initialState = initialState
        self.taskService = taskService
    }
    
    
    // MARK: Mutate

    func mutate(action: Action) -> Observable<Mutation> {
        var newMutation: Observable<Mutation>
        
        switch action {
        case .didInitBinding:
            newMutation = getRefreshMutation()
        case .didSelect(let indexPath):
            newMutation = setCheckMarkMutation(indexPath)
        case .didTapAddButton:
            newMutation = .just(.presentEditTask)
        }
        
        return newMutation
    }
    
    private func getRefreshMutation() -> Observable<Mutation> {
        let tasks = taskService.fetchTasks()
        return tasks.map { tasks in
            let sectionItems = tasks.map(TaskCellReactor.init)
            let section = TaskListSection(model: Void(), items: sectionItems)
            return .setSections([section])
        }
    }
    
    private func setCheckMarkMutation(_ indexPath: IndexPath) -> Observable<Mutation> {
        let taskCellReactor = currentState.sections[indexPath.section].items[indexPath.item]
        let taskState = taskCellReactor.currentState
        return taskService
            .setCheckMark(taskId: taskState.id, isCheckNow: taskState.isSelected)
            .flatMap { _ in Observable.empty() }
    }
    
    
    // MARK: Transform
    
    /// 원래 있던 mutate()에서 발생한 이벤트와 TaskService().event에 있는 것을 같이 방출하는 메소드
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let taskEventMutation = taskService.event
            .flatMap { [weak self] taskEvent -> Observable<Mutation> in
                self?.mutate(taskEvent: taskEvent) ?? .empty()
            }
        return Observable.of(mutation, taskEventMutation).merge()
    }
    
    private func mutate(taskEvent: TaskEvent) -> Observable<Mutation> {
        var newMutation: Observable<Mutation>
        let state = currentState
        
        switch taskEvent {
        case .checkMark(let taskId):
            newMutation = getUpdateSectionItemMutation(taskId: taskId, state: state, isSelectedNow: true)
        case .checkUnMark(let taskId):
            newMutation = getUpdateSectionItemMutation(taskId: taskId, state: state, isSelectedNow: false)
        case .create(let task):
            newMutation = getCreateSectionMutation(task: task)
        }
        
        return newMutation
    }
    
    private func getUpdateSectionItemMutation(taskId: String, state: State, isSelectedNow: Bool) -> Observable<Mutation> {
        guard let indexPath = getIndexPath(taskId: taskId, state: state) else { return .empty() }
        var taskState = getState(indexPath: indexPath)
        taskState.isSelected = !isSelectedNow
        let reactor = TaskCellReactor(task: taskState)
        return .just(.updateSectionItem(indexPath, reactor))
    }
    
    private func getState(indexPath: IndexPath) -> TaskCellReactor.State {
        let taskState = currentState.sections[indexPath.section].items[indexPath.item].currentState
        return taskState
    }
    
    private func getIndexPath(taskId: String, state: State) -> IndexPath? {
        let item = state.sections[0].items.firstIndex(where: { reactor in reactor.currentState.id == taskId })
        guard let item = item else { return nil }
        return IndexPath(item: item, section: 0)
    }
    
    private func getCreateSectionMutation(task: Task) -> Observable<Mutation> {
        let newIndexPath = IndexPath(item: 0, section: 0)
        let reactor = TaskCellReactor(task: task)
        return .just(.insertSectionItem(newIndexPath, reactor))
    }
    
    
    // MARK: Reduce
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setSections(let sections):
            newState.sections = sections
            
        case .updateSectionItem(let indexPath, let item):
            newState.sections[indexPath.section].items[indexPath.item] = item
            
        case .insertSectionItem(let indexPath, let item):
            newState.sections.insert(getTaskListSection(indexPath: indexPath, item: item), at: 0)
            
        case .presentEditTask:
            newState.isPresentEditTask = true
        }
        
        return newState
    }
    
    private func getTaskListSection(indexPath: IndexPath, item: TaskListSection.Item) -> TaskListSection {
        return TaskListSection(model: Void(), items: [item])
    }
    
    // MARK: Builder
    
    func getTaskEditReactorForCreatingTask() -> TaskEditReactor {
        
        return TaskEditReactor(initialState: TaskEditReactor.State(title: ""), taskService: taskService)
    }
}
