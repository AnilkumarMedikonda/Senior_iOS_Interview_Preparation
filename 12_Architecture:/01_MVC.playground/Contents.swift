import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

/*
 ============================================================
                    MVC ARCHITECTURE
 ============================================================

 MVC = Model + View + Controller

 Model      → Represents application data
 View       → Displays UI
 Controller → Coordinates View and Model

 Basic Flow:

 User
   ↓
 View
   ↓
 ViewController
   ↓
 API Client
   ↓
 URLSession
   ↓
 Server
   ↓
 API Client
   ↓
 Model
   ↓
 ViewController
   ↓
 View


 ------------------------------------------------------------
 WHEN TO USE MVC
 ------------------------------------------------------------

 Use MVC when:

 • Screen/feature is small or simple
 • Business logic is limited
 • Quick development is important
 • Prototype / POC
 • Simple CRUD screens
 • You don't need complex state management


 Examples:

 • Login screen
 • Settings screen
 • About screen
 • Simple Profile screen


 ------------------------------------------------------------
 MVC PROS
 ------------------------------------------------------------

 ✓ Simple
 ✓ Easy to understand
 ✓ Quick to develop
 ✓ Natural fit for UIKit
 ✓ Less boilerplate
 ✓ Good for small features


 ------------------------------------------------------------
 MVC CONS
 ------------------------------------------------------------

 ✗ ViewController can become very large
 ✗ Can create "Massive ViewController"
 ✗ Business logic can get mixed with UI
 ✗ Harder to unit test
 ✗ Navigation often stays inside ViewController
 ✗ Less separation for complex features


 ------------------------------------------------------------
 SENIOR INTERVIEW POINT
 ------------------------------------------------------------

 MVC is not bad.

 The problem occurs when too many responsibilities
 are placed inside UIViewController.

 For larger features, responsibilities can be separated
 using MVVM, Coordinator, VIPER or Clean Architecture.
*/


// MARK: - MVC Architecture Diagram

/*
 
                 ┌──────────────┐
                 │     VIEW     │
                 │    UIKit     │
                 └──────┬───────┘
                        │
                   User Action
                        ↓
              ┌──────────────────┐
              │  VIEW CONTROLLER │
              │   Controller     │
              └───────┬──────────┘
                      │
             ┌────────┴────────┐
             ↓                 ↓
        API Client           Model
             │                 │
          URLSession           │
             │                 │
          Server               │
             │                 │
             └──────→ Model ←──┘
                         │
                         ↓
                  Update the View

*/


// MARK: - 1. MODEL

/*
 Model represents application data.

 Important:

 Model should not know about UIKit.

 Example:
 Product received from an API.
*/

struct Product: Codable {

    let id: Int
    let name: String
    let price: Double

    // API sends "title" → map it to our "name"
    enum CodingKeys: String, CodingKey {
        case id
        case name = "title"
        case price
    }
}


// MARK: - 2. ENDPOINT

/*
 Endpoint describes the API we want to call.

 Keeping endpoint information separate makes
 networking reusable.

 Instead of writing URL strings everywhere:

    "/products"
    "/products/10"

 we centralize them here.
*/

enum ProductEndpoint {

    case products
    case product(id: Int)

    var path: String {

        switch self {
        case .products:
            return "/products"

        case .product(let id):
            return "/products/\(id)"
        }
    }
}


// MARK: - 3. API CLIENT

/*
 APIClient is reusable networking infrastructure.

 Responsibilities:

 • Build request
 • Add HTTP method
 • Add headers
 • Execute URLSession request
 • Validate response
 • Decode response

 The ViewController should not contain all networking code.
*/

final class APIClient {

    private let baseURL = "https://fakestoreapi.com"          // free test API

    func request<T: Decodable>(
        endpoint: ProductEndpoint,
        completion: @escaping (Result<T, Error>) -> Void
    ) {

        guard let url = URL(string: baseURL + endpoint.path) else {
            completion(.failure(URLError(.badURL)))           // always call completion
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error {
                completion(.failure(error))
                return
            }

            if let http = response as? HTTPURLResponse,
               !(200...299).contains(http.statusCode) {      // 404 / 500 don't throw
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            guard let data else {
                completion(.failure(URLError(.zeroByteResource)))
                return
            }

            do {
                let model = try JSONDecoder().decode(T.self, from: data)
                completion(.success(model))
            } catch {
                completion(.failure(error))
            }

        }.resume()
    }
}


// MARK: - 4. VIEW

/*
 In UIKit MVC, View is responsible for UI.

 Examples:

 • UILabel
 • UIButton
 • UIImageView
 • UITableView
 • UICollectionView

 The View displays information.

 For this Playground, we use simple properties
 to represent the UI.
*/

final class ProductView {

    var nameText: String = ""
    var priceText: String = ""

    func display(product: Product) {

        nameText = product.name
        priceText = "$\(product.price)"

        print("Product: \(nameText)")
        print("Price: \(priceText)")
    }
}


// MARK: - 5. CONTROLLER

/*
 UIViewController acts as the Controller in UIKit MVC.

 Controller responsibilities:

 • Handle user actions
 • Request data
 • Coordinate Model and View
 • Update UI
*/

final class ProductViewController {

    private let view = ProductView()
    private let apiClient = APIClient()

    func loadProduct() {

        apiClient.request(endpoint: .products) {
            [weak self] (result: Result<[Product], Error>) in

            // URLSession calls back on a background thread → UI on main
            DispatchQueue.main.async {

                guard let self else {
                    return
                }

                switch result {

                case .success(let products):

                    guard let firstProduct = products.first else {
                        print("No products found")
                        return
                    }

                    self.view.display(product: firstProduct)

                case .failure(let error):

                    print("API Error: \(error)")
                }
            }
        }
    }
}


// MARK: - 6. MVC FLOW

/*
 
 User
   │
   ↓
 View
   │
   │ User Action
   ↓
 ViewController
   │
   ↓
 APIClient
   │
   ↓
 URLSession
   │
   ↓
 Server
   │
   ↓
 JSON
   │
   ↓
 APIClient
   │
   ↓
 Product Model
   │
   ↓
 ViewController
   │
   ↓
 View


*/


// MARK: - 7. Example Usage

/*
 In a real UIKit application:

 let viewController = ProductViewController()
 viewController.loadProduct()

 For Playground demonstration:
*/

let viewController = ProductViewController()

print("MVC Example Started")

viewController.loadProduct()                                  // ← actually run it


// MARK: - 8. Massive ViewController

/*
 A common MVC problem:

 ProductViewController
 ├── UI setup
 ├── API calls
 ├── JSON decoding
 ├── Business logic
 ├── Validation
 ├── Database operations
 ├── Navigation
 ├── Analytics
 └── Error handling

 This becomes a:

        MASSIVE VIEW CONTROLLER

 The solution is not automatically to abandon MVC.

 Instead, move responsibilities into appropriate components.
*/


// MARK: - 9. MVC Responsibility Map

/*
 ┌─────────────────────────────────────────┐
 │                MODEL                    │
 │                                         │
 │ Product                                 │
 │ User                                    │
 │ Order                                   │
 │ Data                                    │
 └─────────────────────────────────────────┘


 ┌─────────────────────────────────────────┐
 │                 VIEW                    │
 │                                         │
 │ UILabel                                 │
 │ UIButton                                │
 │ UITableView                             │
 │ UI rendering                            │
 └─────────────────────────────────────────┘


 ┌─────────────────────────────────────────┐
 │              CONTROLLER                 │
 │                                         │
 │ User actions                            │
 │ Coordinates View + Model                │
 │ Calls services                          │
 │ Updates View                            │
 └─────────────────────────────────────────┘


 ┌─────────────────────────────────────────┐
 │              API CLIENT                 │
 │                                         │
 │ Request building                        │
 │ URLSession                              │
 │ HTTP handling                           │
 │ JSON decoding                           │
 └─────────────────────────────────────────┘
*/


// MARK: - 10. MVC vs MVVM

/*
 MVC:

 View
   ↓
 ViewController
   ↓
 Model


 MVVM:

 View
   ↓
 ViewModel
   ↓
 Repository / Model


 Main difference:

 MVC  → Controller handles presentation coordination.

 MVVM → ViewModel handles presentation logic.


 Example:

 MVC:

 ViewController
 ├── loading state
 ├── empty state
 ├── error state
 └── UI transformation


 MVVM:

 ViewModel
 ├── loading state
 ├── empty state
 ├── error state
 └── UI transformation

 ViewController mainly displays the state.
*/


// MARK: - 11. When NOT to Use MVC

/*
 Avoid plain MVC when:

 • Screen has complex business rules
 • Many UI states exist
 • Complex navigation exists
 • Multiple data sources exist
 • Heavy testing is required
 • Feature has large presentation logic

 In those situations consider:

 MVC
   ↓
 MVVM

 Complex navigation
   ↓
 Coordinator

 Highly modular feature
   ↓
 VIPER

 Large application
   ↓
 Clean Architecture
*/


// MARK: - 12. Senior Interview Questions

/*
 Q1. What is MVC?
     → A pattern splitting a screen into Model (data), View (UI), Controller (coordination).

 Q2. What are the responsibilities of Model, View
     and Controller?
     → Model holds data, View displays it, Controller handles actions and connects them.

 Q3. Why does Massive ViewController happen?
     → Networking, logic, navigation and state all get added to the one controller.

 Q4. How would you reduce a Massive ViewController?
     → Move networking to services, logic to ViewModels, navigation to Coordinators.

 Q5. Is MVC bad?
     → No — it's fine for simple screens; the problem is overloading the controller.

 Q6. Where should networking code live?
     → In a reusable API Client / service, not in the ViewController.

 Q7. Where should business logic live?
     → In the Model, a service, or a use case — not in the view layer.

 Q8. How would you make MVC testable?
     → Inject dependencies (API client) through protocols and mock them.

 Q9. MVC vs MVVM?
     → MVVM moves presentation logic and state from the controller into a ViewModel.

 Q10. When would you choose MVC?
     → Small screens with little logic, prototypes, quick features.

 Q11. Can MVC use a reusable API Client?
     → Yes — like the APIClient above.

 Q12. Can MVC use Repository?
     → Yes — the controller can call a repository instead of the API directly.

 Q13. Can MVC use Dependency Injection?
     → Yes — pass the API client / repository into the controller's init.

 Q14. What are the disadvantages of MVC?
     → Massive controllers, logic mixed with UI, hard testing, navigation in the VC.
*/


// MARK: - 13. Senior Interview Answer

/*
 Question:

 "When would you use MVC?"

 Answer:

 "I would use MVC for relatively simple features where
 presentation and business logic are limited.

 It is simple and fits naturally with UIKit.

 However, if the ViewController starts accumulating
 networking, business logic, navigation and state
 management, it can become a Massive ViewController.

 In that case I would introduce additional separation,
 such as MVVM for presentation logic, Coordinator for
 navigation, or Clean Architecture for larger features."
*/


// MARK: - FINAL MVC MAP

/*
 
              ┌─────────────┐
              │    VIEW     │
              │    UIKit    │
              └──────┬──────┘
                     │
                     ↓
          ┌────────────────────┐
          │  VIEW CONTROLLER   │
          │    Controller      │
          └───────┬────────────┘
                  │
          ┌───────┴────────┐
          ↓                ↓
    ┌──────────┐      ┌───────────┐
    │ APIClient│      │   Model   │
    └────┬─────┘      └───────────┘
         ↓
    ┌──────────┐
    │URLSession│
    └────┬─────┘
         ↓
      Server


 MVC = Simple UI architecture
 APIClient = Reusable networking
 Model = Data
 View = UI
 Controller = Coordination


 BEST FIT:

 Simple
    ↓
 Small/medium feature
    ↓
 Limited business logic
    ↓
 MVC


 COMPLEX:

 Complex presentation
    ↓
 MVVM

 Complex navigation
    ↓
 Coordinator

 Highly modular
    ↓
 VIPER

 Large business/data system
    ↓
 Clean Architecture
*/
