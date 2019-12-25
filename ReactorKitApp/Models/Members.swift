//
//  SectionMembers.swift
//  ReactorKitApp
//
//  Created by Civel Xu on 2019/12/24.
//  Copyright © 2019 Civel Xu. All rights reserved.
//

import RxDataSources

struct Members {
    var header: String
    var items: [Member]
}

extension Member: IdentifiableType {
    
    var identity: String {
        return outUid ?? ""
    }
    
    typealias Identity = String

}

extension Members: AnimatableSectionModelType {

    var identity: String {
        return header
    }
    
    typealias Identity = String
    typealias Item = Member
    init(original: Members, items: [Item]) {
        self = original
        self.items = items
    }
}
