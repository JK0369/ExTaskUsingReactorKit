//
//  TaskEditViewController.swift
//  ExTaskList
//
//  Created by 김종권 on 2021/12/02.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

final class TaskEditViewController: UIViewController, StoryboardView {
    
    
    // MARK: IBOutlet
    
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var memoTextField: UITextField!
    
    
    // MARK: Properties
    
    var disposeBag = DisposeBag()
    
    
    // MARK: View Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirrstResponderToMemoTextField()
    }
    
    private func becomeFirrstResponderToMemoTextField() {
        memoTextField.becomeFirstResponder()
    }
    
    
    // MARK: Binding
    
    func bind(reactor: TaskEditReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    private func bindAction(_ reactor: TaskEditReactor) {
        cancelBarButtonItem.rx.tap
            .map { Reactor.Action.didTapCancelButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        doneBarButtonItem.rx.tap
            .map { Reactor.Action.didTapDoneButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        memoTextField.rx.text
            .map { Reactor.Action.didInputTaskTitle($0 ?? "") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: TaskEditReactor) {
        reactor.state
            .map { $0.isDismissed }
            .filter { $0 }
            .map { _ in }
            .bind(onNext: dismiss)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.canSubmit }
            .bind(onNext: updateEnabledButton)
            .disposed(by: disposeBag)
    }
    
    private func dismiss() {
        dismiss(animated: true)
    }
    
    private func updateEnabledButton(isEnable: Bool) {
        doneBarButtonItem.isEnabled = isEnable
    }
    
}
