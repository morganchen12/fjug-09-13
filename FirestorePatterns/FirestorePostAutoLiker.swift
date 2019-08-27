//
//  FirestorePostAutoLiker.swift
//  FirestorePatterns
//
//  Created by Morgan Chen on 8/20/19.
//  Copyright © 2019 Firebase. All rights reserved.
//

import UIKit
import Firebase

class FirestorePostAutoLiker {

  private let firestore: Firestore
  private var timer: Timer

  var rootCollection: CollectionReference {
    return firestore.collection("posts")
  }

  init(firestore: Firestore = Firestore.firestore()) {
    self.firestore = firestore
    timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
      Firestore.firestore().collection("posts").getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else { return }
        let writeBatch = Firestore.firestore().batch()
        for document in snapshot.documents {
          let randomIncrement = Int(arc4random_uniform(3) + 1)
          let likeCount = ((document.data()["likes"] as? Int ?? 0) + randomIncrement) % 1000
          writeBatch.updateData(["likes": likeCount], forDocument: document.reference)
        }
        writeBatch.commit()
      }
    }
    timer.tolerance = 0.2
  }

  deinit {
    timer.invalidate()
  }

}
