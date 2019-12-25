//
//  NetworkRequest+Rx.swift
//  ReactorKitApp
//
//  Created by Civel Xu on 2019/12/24.
//  Copyright © 2019 Civel Xu. All rights reserved.
//

import Moya
import RxSwift
import ObjectMapper

public extension TargetType {

    func requestObject<T: Mappable>(
        nestedKeyPath: String = "",
        model: T.Type,
        callbackQueue: DispatchQueue? = .none,
        progressCallback: Moya.ProgressBlock? = nil) -> Observable<(T)> {

        return Observable.create { observer in
            let task = Network.default.provider.request(
                .target(self),
                callbackQueue: callbackQueue,
                progress: progressCallback) { result in
                switch result {
                case let .success(response):
                    DispatchQueue.global().async {
                        let contenxt = NestedMapContext(key: nestedKeyPath, mapArray: false)
                        guard let model = Mapper<NetworkResponse<T>>(context: contenxt).map(JSONObject: try? response.mapJSON()) else {
                            DispatchQueue.main.async {
                                observer.onError(MoyaError.jsonMapping(response))
                            }
                              return
                        }
                        guard model.isSuccess else {
                            let err = NSError(domain: model.errorMsg, code: model.resultCode, userInfo: nil)
                            DispatchQueue.main.async {
                                observer.onError(err)
                            }
                            return
                        }
                        guard let data = model.data else {
                            DispatchQueue.main.async {
                                observer.onError(MoyaError.jsonMapping(response))
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            observer.onNext(data)
                            observer.onCompleted()
                        }
                    }
                case let .failure(err):
                    observer.onError(err)
                }
            }
            return Disposables.create(with: task.cancel)
        }

    }

    func requestArray<T: Mappable>(
        nestedKeyPath: String = "",
        model: T.Type,
        callbackQueue: DispatchQueue? = .none,
        progressCallback: Moya.ProgressBlock? = nil) -> Observable<([T])> {

        return Observable.create { observer in
            let task = Network.default.provider.request(
                .target(self),
                callbackQueue: callbackQueue,
                progress: progressCallback) { result in
                    switch result {
                    case let .success(response):
                        DispatchQueue.global().async {
                            let contenxt = NestedMapContext(key: nestedKeyPath, mapArray: true)
                            guard let model = Mapper<NetworkResponse<T>>(context: contenxt).map(JSONObject: try? response.mapJSON()) else {
                                DispatchQueue.main.async {
                                    observer.onError(MoyaError.jsonMapping(response))
                                }
                                return
                            }
                            guard model.isSuccess else {
                                let err = NSError(domain: model.errorMsg, code: model.resultCode, userInfo: nil)
                                DispatchQueue.main.async {
                                    observer.onError(err)
                                }
                                return
                            }
                            guard let datas = model.datas else {
                                DispatchQueue.main.async {
                                    observer.onError(MoyaError.jsonMapping(response))
                                }
                                return
                            }
                            DispatchQueue.main.async {
                                observer.onNext(datas)
                                observer.onCompleted()
                            }
                        }
                    case let .failure(err):
                        observer.onError(err)
                    }
            }
            return Disposables.create(with: task.cancel)
        }
    }
}

