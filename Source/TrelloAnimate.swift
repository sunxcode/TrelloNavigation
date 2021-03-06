//
//  TrelloAnimate.swift
//  TrelloNavigation
//
//  Created by DianQK on 15/11/10.
//  Copyright © 2015年 Qing. All rights reserved.
//

import UIKit

typealias Unfolded = (Bool) -> Void

struct TrelloAnimate {
    static func tabUnfold(trelloView: TrelloView, unfold: Bool, finish: @escaping Unfolded) {
        UIView.animate(withDuration: 0.3, animations: {
            let scale: CGFloat = unfold ? ScreenWidth / 4.5 / 30.0 : 1.0
            var nextX: CGFloat = unfold ? 30.0 : 70.0
            trelloView.tabView.frame = CGRect(x: 0, y: trelloView.tabView.top, width: ScreenWidth, height: 100.0 * scale)
            _ = trelloView.tabView.subviews.map { view in
                let view = view as! TrelloListTabItemView
                view.frame = CGRect(x: nextX, y: 0, width: ScreenWidth / 4.5, height: CGFloat(view.heightLevel) * 20.0)
                view.titleLabel.frame = CGRect(x: ScreenWidth / 27.0, y: 10.0, width: ScreenWidth / (4.5 * 1.5), height: 25.0)
                view.boardView.frame = CGRect(x: ScreenWidth / 18.0, y: view.titleLabel.bottom + 10.0, width: ScreenWidth / 9.0, height: CGFloat(view.heightLevel) * 20.0)
                
                view.titleLabel.alpha = unfold ? 1 : 0
                
                (view.frame, view.titleLabel.frame, view.boardView.frame) = unfold ?
                    (
                        CGRect(x: nextX, y: 0, width: ScreenWidth / 4.5, height: CGFloat(view.heightLevel) * 20.0 + 50.0),
                        CGRect(x: ScreenWidth / 27.0, y: 10.0, width: ScreenWidth / (4.5 * 1.5), height: 25.0),
                        CGRect(x: ScreenWidth / 18.0, y: view.titleLabel.bottom + 10.0, width: ScreenWidth / 9.0, height: CGFloat(view.heightLevel) * 20.0)
                    ) : (
                        CGRect(x: nextX, y: 0, width: 30.0, height: 30.0 + CGFloat(view.heightLevel) * 10.0 + 20.0 ),
                        CGRect(x: 5.0, y: 0, width: 20.0, height: 10.0),
                        CGRect(x: 5.0, y: 5.0, width: 20.0, height: CGFloat(view.heightLevel) * 10.0)
                )
                
                nextX += view.width
                
                trelloView.listView.top = unfold ? trelloView.tabView.bottom - 90.0 : trelloView.tabView.bottom - 30.0
                if unfold {
                    tabSelectedAnimate(tabView: trelloView.tabView)
                }
            }
            
            }, completion: { finished in
                if !unfold {
                    tabSelectedAnimate(tabView: trelloView.tabView)
                }
                trelloView.isFoldedMode = unfold
                finish(!unfold)
        })
    }
    
    static func tabSelectedAnimate(tabView: TrelloListTabView) {
        UIView.animate(withDuration: 0.2, animations: {
            for (index, view) in tabView.subviews.enumerated() {
                guard let view = view as? TrelloListTabItemView else { return }
                if tabView.selectedIndex == index {
                    let visibleRect = CGRect(origin: tabView.contentOffset, size: CGSize(width: tabView.width, height: view.height))
                    if !visibleRect.contains(view.frame) {
                        if visibleRect.origin.x + tabView.width <= view.right {
                            tabView.setContentOffset(CGPoint(x: view.right - tabView.width + view.width / 2.0, y: tabView.contentOffset.y), animated: false)
                        } else if visibleRect.origin.x >= view.left {
                            tabView.setContentOffset(CGPoint(x: view.left - view.width / 2.0, y: tabView.contentOffset.y), animated: false)
                        }
                    }
                    view.boardView.alpha = 1.0
                } else {
                    view.boardView.alpha = 0.5
                }
            }
            }, completion: { finish in
                
        })
    }
}
