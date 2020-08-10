//
//  RxDataSources+Common.swift
//  Common
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift
import ReRxSwift
import AwesomeUtilities

public struct SectionModel<T: Equatable>: SectionModelType, Equatable {
    
    public var items: [T]
    
    public init(
        items: [T]
    ) {
        self.items = items
    }
    
    public init(
        original: SectionModel<T>,
        items: [T]
    ) {
        self = original
        self.items = items
    }
    
}

extension Connection {
    
    public func bind<S: Equatable>(
        _ keyPath: KeyPath<Props, [S]>,
        to binder: (Observable<[SectionModel<S>]>) -> Disposable,
        mapToSingleSectionModel: Void
    ) {
        bind(
            keyPath,
            to: binder,
            mapping: { [SectionModel(items: $0)] }
        )
    }
    
}

extension Reactive where Base: UITableView {
    
    public func items<Cell: UITableViewCell & NibLoadable, T: Equatable, O: ObservableType>(
        of cellType: Cell.Type = Cell.self,
        configureCell: @escaping (Cell, IndexPath, T) -> Void
    ) -> (O) -> Disposable where O.Element == [SectionModel<T>] {
        return items(
            dataSource: RxTableViewSectionedReloadDataSource<SectionModel<T>>(
                configureCell: { _, tableView, indexPath, item in
                    let cell = tableView.dequeueReusableCell(
                        of: Cell.self,
                        for: indexPath
                    )
                    configureCell(
                        cell,
                        indexPath,
                        item
                    )
                    return cell
                }
            )
        )
    }
    
}
