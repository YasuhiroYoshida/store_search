//
//  GradientView.swift
//  StoreSearch
//
//  Created by Yasuhiro on 11/23/2015.
//  Copyright © 2015 yasuhiroyoshida. All rights reserved.
//

import UIKit

class GradientView: UIView {

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = UIColor.clearColor()
    autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    backgroundColor = UIColor.clearColor()
    autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
  }

  override func drawRect(rect: CGRect) {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let components : [CGFloat] = [ 0, 0, 0, 0.3, 0, 0, 0, 0.7 ]
    let locations : [CGFloat] = [ 0, 1 ]
    let gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2)

    let x = CGRectGetMidX(bounds)
    let y = CGRectGetMidY(bounds)

    let point = CGPoint(x: x, y: y)
    let radius = max(x, y)

    let context = UIGraphicsGetCurrentContext()
    CGContextDrawRadialGradient(context, gradient, point, 0, point, radius, .DrawsAfterEndLocation)
  }
}
