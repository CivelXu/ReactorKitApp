//
//  MJRefreshHeader+Rx.swift
//  ReactorKitApp
//
//  Created by Civel Xu on 2019/12/24.
//  Copyright © 2019 Civel Xu. All rights reserved.
//

import Foundation
import class MJRefresh.MJRefreshHeader
import RxSwift
import RxCocoa

public extension Reactive where Base: MJRefreshHeader {
    
    var beginRefreshing: Binder<Void> {
        return Binder(base) { (header, _) in
            header.beginRefreshing()
        }
    }
    
    var isRefreshing: Binder<Bool> {
        return Binder(base) { header, refresh in
            if refresh && header.isRefreshing {
                return
            } else {
                refresh ? header.beginRefreshing() : header.endRefreshing()
            }
        }
    }
}
