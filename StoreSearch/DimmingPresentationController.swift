//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Yasuhiro on 11/22/2015.
//  Copyright © 2015 yasuhiroyoshida. All rights reserved.
//

import UIKit

class DimmingPresentaionController: UIPresentationController {

  lazy var dimmingView = GradientView(frame: CGRect.zero)

  override func shouldRemovePresentersView() -> Bool {
    return false
  }

  override func presentationTransitionWillBegin() {
    dimmingView.frame = containerView!.bounds
    containerView!.insertSubview(dimmingView, atIndex: 0)

    dimmingView.alpha = 0
    if let transitionCoordinator = presentedViewController.transitionCoordinator() {
      transitionCoordinator.animateAlongsideTransition({ _ in
        self.dimmingView.alpha = 1
      }, completion: nil)
    }
  }

  override func dismissalTransitionWillBegin() {
    if let transitionCoordinator = presentedViewController.transitionCoordinator() {
      transitionCoordinator.animateAlongsideTransition({ _ in
        self.dimmingView.alpha = 0
      }, completion: nil)
    }
  }
}
