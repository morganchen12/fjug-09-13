//
//  Post.swift
//  FirestorePatterns
//
//  Created by Morgan Chen on 8/20/19.
//  Copyright © 2019 Firebase. All rights reserved.
//

import Firebase

struct Post {

  var author: String
  var body: String
  var likes: Int

  init(author: String, body: String, likes: Int) {
    self.author = author; self.body = body; self.likes = likes
  }

  init?(dictionary: [String: Any]) {
    guard let author = dictionary["author"] as? String,
        let body = dictionary["body"] as? String,
        let likes = dictionary["likes"] as? Int else {
      return nil
    }

    self.init(author: author, body: body, likes: likes)
  }

}

class PostViewModel {

  private var listener: ListenerRegistration?
  private let reference: DocumentReference
  private(set) var post: Post

  init(reference: DocumentReference, post: Post) {
    self.reference = reference
    self.post = post
  }

  func listen(_ handler: @escaping (Post?, Error?) -> ()) {
    listener = reference.addSnapshotListener { (snapshot, error) in
      if let error = error {
        handler(nil, error)
        return
      }

      guard let data = snapshot?.data() else {
        let error = NSError(domain: "PostDecoderErrorDomain",
                            code: 0,
                            userInfo: [NSLocalizedFailureErrorKey: "Snapshot was unexpectedly nil"])
        handler(nil, error)
        return
      }

      guard let post = Post(dictionary: data) else {
        let error = NSError(domain: "PostDecoderErrorDomain",
                            code: 1,
                            userInfo: [NSLocalizedFailureErrorKey: "Could not create Post from snapshot"])
        handler(nil, error)
        return
      }

      handler(post, nil)
    }
  }

  func removeListener() {
    listener?.remove()
  }

  func populate(cell: PostTableViewCell) {
    cell.authorLabel.text = post.author
    cell.bodyLabel.text = post.body
    cell.likesLabel.text = String(post.likes)
  }

  func startUpdating(cell: PostTableViewCell) {
    listen { [unowned self] (post, error) in
      guard let post = post else { return }
      self.post = post
      self.populate(cell: cell)
    }
  }

}

extension PostViewModel {

  static func getPosts(_ completion: @escaping ([PostViewModel]?, Error?) -> ()) {
    Firestore.firestore().collection("posts").getDocuments { (snapshot, error) in
      if let error = error {
        completion(nil, error)
        return
      }

      guard let documents = snapshot?.documents else {
        let error = NSError(domain: "PostDecoderErrorDomain",
                            code: 0,
                            userInfo: [NSLocalizedFailureErrorKey: "Snapshot was unexpectedly nil"])
        completion(nil, error)
        return
      }

      var postViewModels: [PostViewModel] = []
      for document in documents {
        guard let post = Post(dictionary: document.data()) else {
          let error = NSError(domain: "PostDecoderErrorDomain",
                              code: 1,
                              userInfo: [NSLocalizedFailureErrorKey: "Could not create Post from snapshot"])
          completion(nil, error)
          return
        }
        let viewModel = PostViewModel(reference: document.reference, post: post)
        postViewModels.append(viewModel)
      }

      completion(postViewModels, nil)
    }
  }

}
