//
//  AddressView.swift
//  CupcakeCorner
//
//  Created by Víctor Ávila on 09/05/24.
//

import SwiftUI

// The next step will be to let the user enter the address data into a form.
// We'll add some validation: the user will be able to proceed to the next step only if their address looks good.
// It will have name, street address, city and zip/postal code. Also, it will have a NavigationLink to the next screen.

struct AddressView: View {
    // All three Views point to the same object of data
    // The @State automatically creates 2-way bindings for us (exposed with $). We don't use @State here because we aren't making the order instance here.
    // Internally, we know that Order uses the @Observable macro (so SwiftUI in theory watches it for changes)
    // @Bindable is necessary in order to create the 2-way bindings to its mutable properties that couldn't be created because we couldn't use @State here. These bindings are able to work with @Observable objects.
    @Bindable var order: Order
    
    var body: some View {
        Form {
            Section {
                // This data will persist even if we leave this View and come back, because we are passing around the same class instance (if we had used structs or local data with @State we would lost it if we did that)
                TextField("Name", text: $order.name)
                TextField("Street Address", text: $order.streetAddress)
                TextField("City", text: $order.city)
                TextField("Zip", text: $order.zip)
            }
            
            Section {
                NavigationLink("Check out") {
                    CheckoutView(order: order)
                }
            }
            // Stop user from progressing to Check Out if all fields aren't filled.
            .disabled(order.hasValidAddress == false)
        }
        .navigationTitle("Delivery details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AddressView(order: Order())
}
