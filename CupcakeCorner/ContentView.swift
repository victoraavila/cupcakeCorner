//
//  ContentView.swift
//  CupcakeCorner
//
//  Created by Víctor Ávila on 08/05/24.
//

import SwiftUI

// All the screens in our app share the same data: a single class that stores all of it
// It will have the type of cake, a static array of all possible options, how many cakes the user wants, whether the user wants to make special requests, whether the user wants extra frosting on the cake and whether the user wants extra sprinkles on the cake.

struct ContentView: View {
    // This is the only place where the order will be created
    @State private var order = Order()
    
    var body: some View {
        // 3 sections:
        // 1. Cupcake type and quantity (with a Picker to choose the type and a Stepper to choose the quantity)
        NavigationStack {
            Form {
                Section {
                    Picker("Select your cake type", selection: $order.type) {
                        ForEach(Order.types.indices, id: \.self) { // Use id: here to tell SwiftUI that the indices won't change over time (we know that they won't, but SwiftUi doesn't)
                            Text(Order.types[$0]) // Plot a Text with the type at that index
                        }
                    }
                    
                    Stepper("Number of cakes: \(order.quantity)", value: $order.quantity, in: 3...20)
                }
                
                // 2. Three toggle switches bound to specialRequestEnabled, extraFrosting and addSprinkles.
                // The 2nd and 3rd toggle should be visible only when the 1st toggle is enabled.
                
                Section {
                    Toggle("Any special requests?", isOn: $order.specialRequestEnabled.animation()) // .animation() to animate the change smoothly if possible
                    
                    if order.specialRequestEnabled {
                        Toggle("Add extra frosting", isOn: $order.extraFrosting)
                        Toggle("Add extra sprinkles", isOn: $order.addSprinkles)
                    }
                }
                
                // 3. A navigationLink pointing to the next screen in our flow and passing our order through
                Section {
                    NavigationLink("Delivery details") {
                        AddressView(order: order)
                    }
                }
            }
            .navigationTitle("Cupcake Corner")
        }
    }
}

#Preview {
    ContentView()
}
