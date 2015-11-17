//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Yasuhiro on 11/15/2015.
//  Copyright © 2015 yasuhiroyoshida. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var artworkImageView: UIImageView!

    override func awakeFromNib() {
      super.awakeFromNib()
      let selectedView = UIView(frame: CGRect.zero)
      selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
      selectedBackgroundView = selectedView
    }

    override func setSelected(selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)
      // Configure the view for the selected state
  }

}
