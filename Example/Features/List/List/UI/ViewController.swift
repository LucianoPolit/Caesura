//
//  ViewController.swift
//  List
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import Caesura

class ViewController: Caesura.ViewController, Connectable {
    
    lazy var connection = Connection.toModule(
        Module.self,
        mapStateToProps: Self.mapStateToProps,
        mapDispatchToEvents: Self.mapDispatchToEvents
    )
    private let tableView = UITableView()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewHierarchy()
        configureLeftBarButton()
        configureRightBarButton()
        configureTableView()
        bindLeftBarButton()
        bindRightBarButton()
        bindTableView()
        events.didLoad()
    }
    
    override func viewWillAppear(
        _ animated: Bool
    ) {
        super.viewWillAppear(animated)
        connection.connect()
    }
    
    override func viewWillDisappear(
        _ animated: Bool
    ) {
        super.viewWillDisappear(animated)
        connection.disconnect()
    }
    
}

private extension ViewController {
    
    func configureViewHierarchy() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.snp.edges)
        }
    }
    
    func configureLeftBarButton() {
        navigationItem.setLeftBarButton(
            UIBarButtonItem(
                title: "Sort",
                style: .plain,
                target: nil,
                action: nil
            ),
            animated: true
        )
    }
    
    func configureRightBarButton() {
        navigationItem.setRightBarButton(
            UIBarButtonItem(
                title: "Add",
                style: .plain,
                target: nil,
                action: nil
            ),
            animated: true
        )
    }
    
    func configureTableView() {
        tableView.register(
            cellType: TableViewCell.self
        )
    }
    
}

private extension ViewController {
    
    func bindLeftBarButton() {
        navigationItem.leftBarButtonItem?.rx.tap
            .subscribe(onNext: events.didTapLeftBarButton)
            .disposed(by: disposeBag)
    }
    
    func bindRightBarButton() {
        navigationItem.rightBarButtonItem?.rx.tap
            .subscribe(onNext: events.didTapRightBarButton)
            .disposed(by: disposeBag)
    }
    
    func bindTableView() {
        connection.bind(
            \.list,
            to: tableView.rx.items(of: TableViewCell.self) { cell, _, item in
                cell.titleLabel.text = item
            },
            mapToSingleSectionModel: ()
        )
        tableView.rx.modelSelected(String.self)
            .subscribe(onNext: events.didSelectOption)
            .disposed(by: disposeBag)
    }
    
}
