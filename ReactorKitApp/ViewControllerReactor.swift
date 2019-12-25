//
//  ViewControllerReactor.swift
//  ReactorKitApp
//
//  Created by Civel Xu on 2019/12/24.
//  Copyright © 2019 Civel Xu. All rights reserved.
//

import ReactorKit
import RxSwift

class ViewControllerReactor: Reactor {

    enum Action {
        case loading(Bool)
        case fetchMembers(update: Bool)
    }

    enum Mutation {
        case loading(Bool)
        case setMembers([Member], update: Bool, page: Int)
        case setError(Error)
    }

    struct State {
        var loading = false
        var members: [Member] = []
        var page = 0
        var error: Error?
        var isHeaderRefresh = false
        var footerRefreshState = RxMJRefreshFooterState.hidden
    }

    let initialState = State()

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .loading(loading):
            return Observable.just(Mutation.loading(loading))
        case .fetchMembers(let update):
            let requestPage = update ? 0 : currentState.page
            return API.getMembers(page: requestPage)
                .requestArray(model: Member.self)
                .map { Mutation.setMembers($0, update: update, page: requestPage + 1) }
                .catchError { Observable.just( Mutation.setError($0)) }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case let .loading(loading):
            var newState = state
            newState.error = nil
            newState.loading = loading
            return newState
        case .setMembers(let members, let update, let page):
            var newState = state
            newState.error = nil
            if update {
                newState.members = members
                newState.isHeaderRefresh = false
            } else {
                newState.members.append(contentsOf: members)
            }
            if members.isEmpty {
                newState.footerRefreshState = .hidden
            } else if members.count < 20 {
                newState.footerRefreshState = .noMoreData
            } else {
                newState.footerRefreshState = .default
            }
            newState.loading = false
            newState.page = page
            return newState
        case let .setError(error):
            var newState = state
            newState.loading = false
            newState.error = error
            return newState
        }
    }

}
