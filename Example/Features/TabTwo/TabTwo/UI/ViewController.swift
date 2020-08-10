//
//  ViewController.swift
//  TabTwo
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Caesura

class ViewController: Caesura.ViewController, Connectable {
    
    lazy var connection = Connection.toModule(
        Module.self,
        mapStateToProps: Self.mapStateToProps,
        mapDispatchToEvents: Self.mapDispatchToEvents
    )
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Two"
        view.backgroundColor = .red
        configureRightBarButton()
        bindRightBarButton()
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
    
    func configureRightBarButton() {
        navigationItem.setRightBarButton(
            UIBarButtonItem(
                title: "Next",
                style: .plain,
                target: nil,
                action: nil
            ),
            animated: true
        )
    }
    
}

private extension ViewController {
    
    func bindRightBarButton() {
        navigationItem.rightBarButtonItem?.rx.tap
            .subscribe(onNext: events.didTapRightBarButton)
            .disposed(by: disposeBag)
    }
    
}
