//
//  MJRefresh+Rx.swift
//  ReactorKitApp
//
//  Created by Civel Xu on 2019/12/24.
//  Copyright © 2019 Civel Xu. All rights reserved.
//

import MJRefresh
import RxSwift
import RxCocoa

extension Reactive where Base: MJRefreshComponent {
    var refreshing: ControlEvent<Void> {
        let source = Observable<Void>.create { [weak control = self.base] observer in
            if let control = control {
                control.refreshingBlock = {
                    observer.onNext(())
                }
            }
            return Disposables.create()
        }
        return ControlEvent(events: source)
    }
}
