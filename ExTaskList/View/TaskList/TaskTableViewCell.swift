//
//  TaskTableViewCell.swift
//  ExTaskList
//
//  Created by 김종권 on 2021/12/02.
//

import UIKit
import ReactorKit
import RxSwift

final class TaskTableViewCell: UITableViewCell, StoryboardView {
    
    typealias Reactor = TaskCellReactor
    var disposeBag = DisposeBag()
    
    // MARK: Constants
    
    struct LabelConstant {
        static let maximumNumberOfLines = 5
        static let font = UIFont.systemFont(ofSize: 16)
    }
    
    struct Metric {
        static let cellPadding = 16.0
    }
    
    
    // MARK: UI
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    // MARK: Binding
    
    func bind(reactor: TaskCellReactor) {
        titleLabel.text = reactor.currentState.title
        accessoryType = reactor.currentState.isSelected ? .checkmark : .none
    }
    
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupDynamicLayout()
    }
    
    private func setupDynamicLayout() {
        titleLabel.numberOfLines = LabelConstant.maximumNumberOfLines
        titleLabel.font = LabelConstant.font
        titleLabel.layer.frame.origin.y = Metric.cellPadding
        titleLabel.layer.frame.origin.x = Metric.cellPadding
        titleLabel.layer.frame.size.width = contentView.layer.frame.size.width - Metric.cellPadding * 2
        titleLabel.sizeToFit()
    }
    
    
    // MARK: Cell Height
    
    class func height(width: CGFloat, reactor: Reactor) -> CGFloat {
        let titleState = reactor.currentState.title
        
        let contentWidth = width - Metric.cellPadding * 2
        let heightContents = titleState.getCalculatedHeight(contentWidth: contentWidth,
                                                            font: LabelConstant.font,
                                                            maximumNumberOfLines: LabelConstant.maximumNumberOfLines)
        let heightWithPadding = heightContents + Metric.cellPadding * 2
        return heightWithPadding
    }
    
}
