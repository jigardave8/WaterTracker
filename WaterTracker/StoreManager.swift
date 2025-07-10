//
//  StoreManager.swift
//  WaterTracker
//
//  Created by BitDegree on 10/07/25.
//

//
//  StoreManager.swift
//  WaterTracker
//
//  This manager handles all StoreKit 2 interactions for in-app purchases.
//

import Foundation
import StoreKit

// --- THIS IS THE FIX ---
// Define a custom error type for our StoreKit interactions.
enum StoreError: Error {
    case failedVerification
}

// Define our product identifiers.
enum ProductID {
    static let proUnlock = "com.bitdegree.watertracker.pro"
}

@MainActor
class StoreManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    
    // A simple boolean to check if the user is a pro user.
    var isProUser: Bool {
        return !purchasedProductIDs.isEmpty
    }
    
    private var updates: Task<Void, Never>? = nil
    
    init() {
        updates = observeTransactionUpdates()
    }
    
    deinit {
        updates?.cancel()
    }
    
    // Fetch the product definition from the App Store.
    func loadProducts() async {
        do {
            self.products = try await Product.products(for: [ProductID.proUnlock])
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    // Initiate a purchase.
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            // Check the transaction and update the user's status.
            let transaction = try checkVerified(verification)
            await updatePurchasedStatus()
            await transaction.finish()
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }
    
    // Observe transaction updates (e.g., purchases made on other devices).
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verification in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(verification)
                    await self.updatePurchasedStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction update failed verification")
                }
            }
        }
    }
    
    // Update the local set of purchased product IDs.
    func updatePurchasedStatus() async {
        var newPurchasedIDs = Set<String>()
        for await verification in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(verification)
                newPurchasedIDs.insert(transaction.productID)
            } catch {
                print("Entitlement failed verification")
            }
        }
        self.purchasedProductIDs = newPurchasedIDs
    }
    
   
    // Helper to decode the JWS verification.
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            // --- MODIFIED: Throw our custom error ---
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}
