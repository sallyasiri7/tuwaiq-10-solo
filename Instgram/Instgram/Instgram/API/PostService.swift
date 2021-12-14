//
//  PostService.swift
//  Instgram
//
//  Created by sally asiri on 08/05/1443 AH.
//

import UIKit
import Firebase
import simd

struct PostService {
    
    static func uploadPost(caption: String, image: UIImage, user: User,
                           completion: @escaping(FirestoreCompletion)) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        ImageUploader.uploadImage(image: image) { imageUrl in
            
            let data = ["caption": caption,
                        "timestamp": Timestamp(date: Date()),
                        "likes": 0,
                        "imageUrl": imageUrl,
                        "ownerUid": uid,
                        "ownerImageUrl": user.profileImageUrl,
                        "ownerUsername": user.username] as [String : Any]
            
            COLLECTION_POSTS.addDocument(data: data, completion: completion)
        }
        
    }
    
    //تحديث الصور
    
    static func fetchPosts(completion: @escaping([Post]) -> Void) {
        COLLECTION_POSTS.order(by: "timestamp", descending: true).getDocuments { ( snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            
            let posts = documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
            completion(posts)
        }
    }
    
    //هذا الي يطلع الصور بالصفحه حقتي
    
    static func fetchPosts(forUser uid: String, completion: @escaping([Post]) -> Void) {
        
        let query = Firestore.firestore().collection("posts").whereField("ownerUid", isEqualTo: uid)
        
        
        query.getDocuments { (snapshot, error) in
            if error != nil {
             //   print(error?.localizedDescription)
                return
            }
            
            guard let documents = snapshot?.documents else { return }
           //  print("documents \(documents.count)")
            
            var posts = documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
            
           //  print("posts \(posts.count)")

            posts.sort { (post1, post2) -> Bool in
                return post1.timestamp.seconds > post2.timestamp.seconds
            }
            
            completion(posts)
            
            
        }
    }
}
