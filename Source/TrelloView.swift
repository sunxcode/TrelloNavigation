//
//  TrelloView.swift
//  TrelloNavigation
//
//  Created by DianQK on 15/11/8.
//  Copyright © 2015年 Qing. All rights reserved.
//

import UIKit

public typealias TrelloCells = () -> [UIView]

public class TrelloView: UIView, UIScrollViewDelegate {
    
    public var tabView: TrelloListTabView
    public var listView: TrelloListView
    
    public var isFoldedMode : Bool = true
    public var tabCount: Int
    
    public var tabs: [String] {
        get {
            return tabView.tabs
        }
    }
    
    weak public var delegate: UITableViewDelegate? {
        didSet {
            _ = tableViews.map { tableView in
                tableView.delegate = delegate
            }
        }
    }
    weak public var dataSource: UITableViewDataSource? {
        didSet {
            _ = tableViews.map { tableView in
                tableView.dataSource = dataSource
            }
        }
    }
    
    public var tableViews: [UITableView] = []
    
    public init(frame: CGRect, tabCount: Int,trelloTabCells: TrelloTabCells) {
        self.tabCount = tabCount
        tabView = TrelloListTabView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 100), trelloTabCells: trelloTabCells)
        tabView.backgroundColor = TrelloBlue
        tabView.selectedIndex = 0
        listView = TrelloListView(frame: CGRect(x: 30.0, y: tabView.bottom - 30.0, width: ScreenWidth - 45.0, height: frame.height - tabView.bottom + 30.0), listCount: tabCount)
        
        super.init(frame: frame)
        listView.delegate = self
        self.addSubviews(tabView, listView)
        
        for i in 0..<tabCount {
            let x: CGFloat = CGFloat(i) * (ScreenWidth - 60.0 + 15.0)
            let tableView = TrelloListTableView<TrelloListCellItem>(frame: CGRect(x: x, y: 0, width: ScreenWidth - 60.0, height: listView.height - 80.0))
//            在这里设置 delegate 和 dataSource 是没有卵用的
//            tableView.delegate = delegate
//            tableView.dataSource = dataSource
            tableView.backgroundColor = UIColor.clear
            tableView.layer.cornerRadius = 5.0
            tableView.layer.masksToBounds = true
            tableView.separatorStyle = .none
            tableView.showsHorizontalScrollIndicator = false
            tableView.showsVerticalScrollIndicator = false
            tableView.headerDidFolded = { folded in
                if self.isFoldedMode != folded {
                    self.isFoldedMode = folded
                    TrelloAnimate.tabUnfold(trelloView: self, unfold: !folded) { unfolded in
                        self.isFoldedMode = unfolded
                    }
                }
            }
            listView.addSubview(tableView)
            tableViews.append(tableView)
        }
        
        listView.layer.masksToBounds = false
        listView.clipsToBounds = false
        
        prepareAnimate()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Delegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == listView {
            let x = scrollView.contentOffset.x
            let width = ScreenWidth - 45.0
            if (Int(x) % Int(width)) == 0 {
                tabView.selectedIndex = Int(x / width)
            }
        }
    }

    func prepareAnimate() {
        tabView.didClickIndex = { index in
            if !self.isFoldedMode {
                self.tabView.selectedIndex = index
            }
            TrelloAnimate.tabUnfold(trelloView: self, unfold: self.isFoldedMode) { unfolded in
                self.isFoldedMode = unfolded
            }
            
            let offsetX = (ScreenWidth - 45.0) * CGFloat(self.tabView.selectedIndex)
            self.listView.setContentOffset(CGPoint(x: offsetX, y: self.listView.contentOffset.y), animated: true)
        }
    }

}
