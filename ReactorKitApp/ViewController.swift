//
//  ViewController.swift
//  ReactorKitApp
//
//  Created by Civel Xu on 2019/12/24.
//  Copyright © 2019 Civel Xu. All rights reserved.
//

import UIKit
import RxSwift
import MJRefresh
import Kingfisher
import RxCocoa
import ReactorKit
import RxDataSources
import RxViewController

class ViewController: UIViewController, StoryboardView {

    var disposeBag = DisposeBag()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!

    private let refreshHeader = MJRefreshNormalHeader()
    private let refreshFooter = MJRefreshAutoNormalFooter()

    private let dataSource = RxTableViewSectionedAnimatedDataSource<Members>(configureCell: {
        (dataSource, tableView, indexPath, item) -> MemberCell in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as? MemberCell else {
            return MemberCell()
        }
        cell.configureData(member: item)
        return cell
    })

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        reactor = ViewControllerReactor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        tableView.mj_header = refreshHeader
        tableView.mj_footer = refreshFooter
        // dataSource.decideViewTransition = { (_, _, _)  in return .reload }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        indicatorView.center = view.center
    }
    
    func bind(reactor: ViewControllerReactor) {

        /// Action
        rx.viewDidAppear
            .map { _ in Reactor.Action.loading(true) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        rx.viewDidAppear
            .map { _ in Reactor.Action.fetchMembers(update: true) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        /// State
        reactor.state
            .map { $0.loading }
            .bind(to: indicatorView.rx.isAnimating)
            .disposed(by: disposeBag)

        reactor.state
            .map { [Members(header: "data", items: $0.members)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.error }
            .subscribe(onNext: { [weak self] error in
                guard let `self` = self else { return }
                guard let error = error else { return }
                self.alert(title: "网络连接出错", message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isHeaderRefresh }
            .bind(to: refreshHeader.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.footerRefreshState }
            .bind(to: refreshFooter.rx.refreshFooterState)
            .disposed(by: disposeBag)
        
        /// View
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let `self` = self else { return }
                self.tableView.deselectRow(at: indexPath, animated: true)
                let name = reactor.currentState.members[indexPath.row].name ?? ""
                self.alert(title: "点击了", message: name)
            })
            .disposed(by: disposeBag)

       
        tableView.rx.willDisplayCell
            .filter {
                reactor.currentState.footerRefreshState == .default
                    && $1.row == reactor.currentState.members.count - 5 }
            .map { _ in Reactor.Action.fetchMembers(update: false) }
            .bind(onNext: { _ in
                self.refreshFooter.beginRefreshing()
            })
            .disposed(by: disposeBag)

        refreshHeader.rx.refreshing
            .map { _ in Reactor.Action.fetchMembers(update: true) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        refreshFooter.rx.refreshing
            .map { _ in Reactor.Action.fetchMembers(update: false) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

    }
    
}

// MARK: - Help

extension ViewController {
    private func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
