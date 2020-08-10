//
//  ViewController.swift
//  TabOne
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Caesura
import TabTwo

class ViewController: Caesura.ViewController, Connectable {
    
    lazy var connection = Connection.toModules(
        Module.self,
        Module.TabTwo.self,
        mapStateToProps: Self.mapStateToProps,
        mapDispatchToEvents: Self.mapDispatchToEvents
    )
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "One"
        view.backgroundColor = .green
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
        navigationItem.rightBarButtonItem = UIBarButtonItem()
    }
    
}

private extension ViewController {
    
    func bindRightBarButton() {
        navigationItem.rightBarButtonItem?.do {
            connection.bind(
                \.rightBarButtonTitle,
                to: $0.rx.title
            )
            $0.rx.tap
                .subscribe(onNext: events.didTapRightBarButton)
                .disposed(by: disposeBag)
        }
    }
    
}
