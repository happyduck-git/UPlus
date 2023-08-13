//
//  FirestoreActor.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/13.
//

import Foundation
import FirebaseFirestore

// TODO: Might need to move FirestoreManager logic to here!

actor FirestoreActor {
    
    static let shared = FirestoreActor()

    private init() {
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
    }
    
    //MARK: - Property

    // Decoder
    private let decoder = Firestore.Decoder()
    private let encoder = Firestore.Encoder()
    
    // Database
    private let db = Firestore.firestore()
    
    func getTodayPointHistory() async throws -> [PointHistory] {
        let documents = try await self.db.collectionGroup(FirestoreConstants.userPointHistory)
            .whereField(FirestoreConstants.userPointTime, isEqualTo: Date().yearMonthDateFormat)
            .order(by: FirestoreConstants.userPointCount, descending: true)
            .getDocuments()
            .documents
        
        var points: [PointHistory] = []
        
        for doc in documents {
            var point = try doc.data(as: PointHistory.self, decoder: self.decoder)
            point.userIndex = doc.reference.parent.parent?.documentID
            points.append(point)
        }
        
        return points
        
    }
}
