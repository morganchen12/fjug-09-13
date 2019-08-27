//
//  PostCollectionViewCell.swift
//  FirestorePatterns
//
//  Created by Morgan Chen on 8/20/19.
//  Copyright © 2019 Firebase. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

  @IBOutlet weak var authorLabel: UILabel!
  @IBOutlet weak var bodyLabel: UILabel!
  @IBOutlet weak var likesLabel: UILabel!
  @IBOutlet weak var likeButton: UIButton!

  static let reuseIdentifier = "PostTableViewCell"

}
