//
//  TaskListViewController.swift
//  ExTaskList
//
//  Created by 김종권 on 2021/12/02.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import RxDataSources

final class TaskListViewController: UIViewController, StoryboardView {
    
    // MARK: IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!
    
    // MARK: Properties
    
    var disposeBag = DisposeBag()
    
    let dataSource = RxTableViewSectionedReloadDataSource<TaskListSection> { _, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.className, for: indexPath) as! TaskTableViewCell
        cell.bind(reactor: item)
        return cell
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerTableViewCell()
        setupTableViewDelegate()
    }
    
    private func registerTableViewCell() {
        let nib = UINib(nibName: TaskTableViewCell.className, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: TaskTableViewCell.className)
    }
    
    private func setupTableViewDelegate() {
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    
    // MARK: Binding
    
    func bind(reactor: TaskListReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    private func bindAction(_ reactor: TaskListReactor) {
        Observable.just(Void())
            .map { Reactor.Action.didInitBinding }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        addBarButtonItem.rx.tap
            .map { Reactor.Action.didTapAddButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map(Reactor.Action.didSelect)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: TaskListReactor) {
        reactor.state
            .map { $0.sections }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
}

extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = dataSource[indexPath]
        let calculatedHeight = TaskTableViewCell.height(width: tableView.layer.frame.width,
                                                        reactor: item)
        return calculatedHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
