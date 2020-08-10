//
//  ViewController.swift
//  Generics
//
//  Created by Luciano Polit on 8/18/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Caesura
import SnapKit

class ViewController: Caesura.ViewController, Connectable {
    
    lazy var connection = Connection.toModule(
        Module.self,
        mapStateToProps: Self.mapStateToProps,
        mapDispatchToEvents: Self.mapDispatchToEvents
    )
    private let label = UILabel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Generics"
        view.backgroundColor = .white
        configureRightBarButton()
        configureLabel()
        bindRightBarButton()
        bindLabel()
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
                title: "Change",
                style: .plain,
                target: nil,
                action: nil
            ),
            animated: true
        )
    }
    
    func configureLabel() {
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
}

private extension ViewController {
    
    func bindRightBarButton() {
        navigationItem.rightBarButtonItem?.rx.tap
            .subscribe(onNext: events.didTapRightBarButton)
            .disposed(by: disposeBag)
    }
    
    func bindLabel() {
        connection.bind(
            \.title,
            to: label.rx.text
        )
    }
    
}
