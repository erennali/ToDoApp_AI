import StoreKit
import FirebaseFirestore
import FirebaseAuth

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedCredits: Int = 0
    @Published var errorMessage: String?
    
    private let productIdentifiers = [
        "com.erenalikoca.todoapp.credits.10",
        "com.erenalikoca.todoapp.credits.50",
        "com.erenalikoca.todoapp.credits.100"
    ]
    
    private init() {
        Task {
            await loadProducts()
        }
    }
    
    func loadProducts() async {
        do {
            print("Loading products...")
            let products = try await Product.products(for: productIdentifiers)
            print("Found \(products.count) products")
            
            for product in products {
                print("Product: \(product.id), \(product.displayName), \(product.displayPrice)")
            }
            
            await MainActor.run {
                self.products = products
            }
        } catch {
            print("Error loading products: \(error)")
            errorMessage = "Ürünler yüklenirken hata oluştu: \(error.localizedDescription)"
        }
    }
    
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    // Başarılı satın alma
                    await transaction.finish()
                    await addCreditsToUser(for: product)
                case .unverified(_, let error):
                    errorMessage = "Satın alma doğrulanamadı: \(error.localizedDescription)"
                }
            case .userCancelled:
                break
            case .pending:
                errorMessage = "Satın alma işlemi beklemede"
            @unknown default:
                errorMessage = "Bilinmeyen bir hata oluştu"
            }
        } catch {
            errorMessage = "Satın alma işlemi başarısız: \(error.localizedDescription)"
        }
    }
    
    private func addCreditsToUser(for product: Product) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        var creditsToAdd: Int
        switch product.id {
        case "com.erenalikoca.todoapp.credits.10":
            creditsToAdd = 10
        case "com.erenalikoca.todoapp.credits.50":
            creditsToAdd = 50
        case "com.erenalikoca.todoapp.credits.100":
            creditsToAdd = 100
        default:
            creditsToAdd = 0
        }
        
        do {
            try await db.collection("users")
                .document(userId)
                .updateData([
                    "aiMessageQuota": FieldValue.increment(Int64(creditsToAdd))
                ])
            purchasedCredits += creditsToAdd
        } catch {
            errorMessage = "Krediler eklenirken hata oluştu: \(error.localizedDescription)"
        }
    }
} 