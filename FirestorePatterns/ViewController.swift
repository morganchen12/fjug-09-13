//
//  ViewController.swift
//  FirestorePatterns
//
//  Created by Morgan Chen on 8/20/19.
//  Copyright © 2019 Firebase. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

  private var viewModels: [PostViewModel] = []
  private var postAutoLiker: FirestorePostAutoLiker?

  @IBOutlet weak var tableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    tableView.delegate = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    PostViewModel.getPosts { (postList, error) in
      if let error = error {
        fatalError("Error fetching posts \(error)")
      }
      let posts = postList!
      self.viewModels = posts
      self.tableView.reloadData()
    }

    postAutoLiker = FirestorePostAutoLiker()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    postAutoLiker = nil
    viewModels.forEach { $0.removeListener() }
  }

}

extension ViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModels.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell",
                                             for: indexPath) as! PostTableViewCell
    let viewModel = viewModels[indexPath.row]
    viewModel.populate(cell: cell)
    return cell
  }

}

extension ViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView,
                 willDisplay cell: UITableViewCell,
                 forRowAt indexPath: IndexPath) {
    guard let postCell = cell as? PostTableViewCell else { return }
    let viewModel = viewModels[indexPath.row]
    viewModel.startUpdating(cell: postCell)
  }

  func tableView(_ tableView: UITableView,
                 didEndDisplaying cell: UITableViewCell,
                 forRowAt indexPath: IndexPath) {
    let viewModel = viewModels[indexPath.row]
    viewModel.removeListener()
  }

}
