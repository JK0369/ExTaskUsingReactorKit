//
//  TaskListService.swift
//  ExTodo
//
//  Created by 김종권 on 2021/12/02.
//

import RxSwift

enum TaskEvent {
    case checkMark(id: String)
    case checkUnMark(id: String)
    case create(task: Task)
}

protocol TaskService {
    var event: PublishSubject<TaskEvent> { get }
    
    func fetchTasks() -> Observable<[Task]>
    func create(title: String) -> Observable<Task>
    func setCheckMark(taskId: String, isCheckNow: Bool) -> Observable<Task>
}

final class TaskServiceImpl: TaskService {
    
    let event = PublishSubject<TaskEvent>()
    
    func fetchTasks() -> Observable<[Task]> {
        if let savedTasks = UserDefaultsManager.tasks {
            return .just(savedTasks)
        }
        let defaultTasks = [Task(title: "iOS 앱"),
                            Task(title: "iOS 앱 개발 알아가기"),
                            Task(title: "Jake의 iOS 앱 개발 알아가기")]
        UserDefaultsManager.tasks = defaultTasks
        return .just(defaultTasks)
    }
    
    func create(title: String) -> Observable<Task> {
        return fetchTasks()
            .flatMap { [weak self] tasks -> Observable<Task> in
                guard let `self` = self else { return .empty() }
                let newTask = Task(title: title)
                return self.saveTasks(tasks + [newTask]).map { newTask }
            }
            .do(onNext: { task in
                self.event.onNext(.create(task: task))
            })
    }
    
    func setCheckMark(taskId: String, isCheckNow: Bool) -> Observable<Task> {
        return fetchTasks()
            .flatMap { [weak self] tasks -> Observable<Task> in
                guard let `self` = self else { return .empty() }
                guard let index = tasks.firstIndex(where: { $0.id == taskId }) else { return .empty() }
                var tasks = tasks
                tasks[index].isSelected = !isCheckNow
                return self.saveTasks(tasks).map { tasks[index] }
            }.do(onNext: { [weak self] task in
                if isCheckNow {
                    self?.event.onNext(.checkMark(id: task.id))
                } else {
                    self?.event.onNext(.checkUnMark(id: task.id))
                }
            })
    }
    
    @discardableResult
    private func saveTasks(_ tasks: [Task]) -> Observable<Void> {
        UserDefaultsManager.tasks = tasks
        return .just(Void())
    }
}
