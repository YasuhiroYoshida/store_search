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
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
