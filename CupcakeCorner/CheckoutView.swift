//
//  CheckoutView.swift
//  CupcakeCorner
//
//  Created by Víctor Ávila on 19/05/24.
//

import SwiftUI

// This View is composed of two halves:
// 1. The basic UI, which should provide little challenge (a ScrollView with an image inside plus the total price of their order and a Place Order Button that will kick off the whole networking)
// 2. We'll encode our order object to JSON and send it to the Internet somehow, which is harder

struct CheckoutView: View {
    var order: Order
    
    // The image will be downloaded from Paul website in order for us to be able to change it for seasonal marketing campaigns.
    // The price will be $2.00 for each cupcake and add a little more on cost for complicated cupcakes. Extra frosting will be $1/cake and extra sprinkles will be $0.50/cake
    
    @State private var confirmationMessage = ""
    @State private var showingConfirmation = false
    @State private var connectionFailed = false
    
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: "https://hws.dev/img/cupcakes@3x.jpg"), scale: 3) { image in
                    image
                    // We don't need to use image?.image here because of the placeholder: {}
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 233) // Chosen by try and error
                
                // It's important to define the order price format carefully below
                Text("Your total cost is \(order.cost, format: .currency(code: "USD"))") // This will take care of inserting the Dollar sign, the correct comma/point and the correct number of decimal places
                    .font(.title)
                
                // Regular Buttons don't support awaiting for data (even if we add an await closure inside)
                // The .onAppear() modifier also doesn't know how to sleep. Instead, we would use the .task() to sleep. Unfortunately, this isn't also an option, because we're executing an action rather than just attaching modifiers.
                // Nevertheless, we can create a new Task out of thin air, and just like the .task() modifier this will run any kind of asynchronous code that we want.
                Button("Place Order") {
                    Task {
                        await placeOrder()
                    }
                }
                    .padding()
            }
        }
        .navigationTitle("Check out")
        .navigationBarTitleDisplayMode(.inline)
        
        // This lets us disable the scroll bounce of ScrollViews when the content is being shown completely already
        // If you add more Text or if the user uses a very large font it will start scrolling automatically
        .scrollBounceBehavior(.basedOnSize)
        .alert("Thank you!", isPresented: $showingConfirmation) {
            // Just the regular OK Button
            Button("OK") { }
        } message: {
            Text(confirmationMessage)
        }
        .alert("Oops!", isPresented: $connectionFailed) {
            Button("OK") { }
        } message: {
            Text("The connection to the server failed. You may be having a poor internet connection.")
        }
    }
    
    // The URLSession class makes it easy to send and receive data
    // If we combine that with the Codable protocol to convert Swift objects to and from JSON, then wrap that in a URLSession struct to customize the exact way in which we send data, then we can accomplish great things in 20 lines of code.
    func placeOrder() async { // An asynchronous function that can go to sleep (uploading data is also asynchronous)
        // Convert our current order to JSON data
        guard let encoded = try? JSONEncoder().encode(order) else {
            print("Failed to encode order")
            return
        }
        
        // Tell Swift how to send that over a network call
        // URLRequest is quite like a regular URL object, but with extra options to add information like the type of the request, what user data should be sent and received and so forth
        // We'll add two extra pieces of information so the server knows how to process the request:
        // 1. The HTTP method (GET, POST, etc.)
        // 2. The Content Type, which determines what kind of data we're sending, which affects the way the server handles it (is it plain text? Is it an image? Is it JSON?). The MIME type, for example, was designed to handle attachments in e-mails and has thousands of very specific options.
        // We'll use reqres.in as our server, which can handle any data we send to it and will automatically send back to us
        let url = URL(string: "https://reqres.in/api/cupcakes")! // Forcing unwrapping because since it was handtyped there is no chance of errors ("please, make it unoptional"!)
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // There is some JSON data inside our request
        request.httpMethod = "POST" // We are writing data
        
        // Run the request with URLSession.shared.upload() and process the response
        do {
            // Uploading it, looking for errors and ready to go to sleep while it happens
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            
            connectionFailed = false
            
            // Handle the result
            // We'll show an alert with some details of the order we sent (by using the decoded version of the order, not the original order). Both should be the same, and if they aren't there was an error.
            let decodedOrder = try JSONDecoder().decode(Order.self, from: data)
            confirmationMessage = "Your order for \(decodedOrder.quantity)x \(Order.types[decodedOrder.type].lowercased()) cupcakes is on its way!"
            showingConfirmation = true
            
            // There is a small networking bug we will have to solve by debugging
            // lldb is the XCode debugger, in which we can run commands (we will run the command for iOS to decode what we received back as a String: p String(decoding: encoded, as: UTF8.self))
            // We saw that all keys have _ in the beginning, and there is also a key named _$observationRegistrar. These are produced by the @Observable macro. We should guarantee that every key is coded into the same name.
             
        } catch {
            // If there is no Internet connection, or reqres.in is down or whatever
            print("Check out failed: \(error.localizedDescription)")
            connectionFailed = true
        }
    }
    
}

#Preview {
    CheckoutView(order: Order())
}
