//
//  StoreManager.swift
//  WaterTracker
//
//  Created by BitDegree on 10/07/25.
//

import Foundation
import StoreKit

enum StoreError: Error { case failedVerification }
enum ProductID { static let proUnlock = "com.bitdegree.watertracker.pro" }

@MainActor
class StoreManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    
    var isProUser: Bool { !purchasedProductIDs.isEmpty }
    private var updates: Task<Void, Never>? = nil
    
    init() {
        updates = observeTransactionUpdates()
    }
    
    deinit { updates?.cancel() }
    
    func loadProducts() async {
        do {
            self.products = try await Product.products(for: [ProductID.proUnlock])
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedStatus()
            await transaction.finish()
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verification in Transaction.updates {
                do {
                    // Correctly unwrap the verified transaction first
                    let transaction = try self.checkVerified(verification)
                    await self.updatePurchasedStatus()
                    // Finish the transaction after processing
                    await transaction.finish()
                } catch {
                    print("Transaction update failed verification")
                }
            }
        }
    }
    
    func updatePurchasedStatus() async {
        var newPurchasedIDs = Set<String>()
        for await verification in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(verification)
                if transaction.productID == ProductID.proUnlock {
                    AwardsManager().grant(id: .appPro)
                }
                newPurchasedIDs.insert(transaction.productID)
            } catch {
                print("Entitlement failed verification")
            }
        }
        self.purchasedProductIDs = newPurchasedIDs
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw StoreError.failedVerification
        case .verified(let safe): return safe
        }
    }
}
