//
//  Order.swift
//  CupcakeCorner
//
//  Created by Víctor Ávila on 08/05/24.
//

import Foundation

@Observable
class Order {
    // We will use the .indices property of this Array as an arrayIndex. This is a bad idea with mutable Arrays, because the order of the Array can change at any type.
    static let types = ["Vanilla", "Strawberry", "Chocolate", "Rainbow"]
    
    // Storage for the current order
    var type = 0
    var quantity = 3
    
    var specialRequestEnabled = false {
        didSet {
            // When we disable it and then enable again, forget what was chosen before
            if specialRequestEnabled == false {
                extraFrosting = false
                addSprinkles = false
            }
        }
    }
    var extraFrosting = false
    var addSprinkles = false
    
    // Fields that will be filled in by AddressView
    var name = ""
    var streetAddress = ""
    var city = ""
    var zip = ""
    
    // How to stop the user if they only filled in 3 out of the 4 fields?
    // Please, don't use length checks for the name, for example. They exclude people.
    // Let's just verify if name, street address, city and zip aren't empty. We'll combine this with SwiftUI .disabled() modifier to stop the user interaction if the condition is true.
    var hasValidAddress: Bool {
        if name.isEmpty || streetAddress.isEmpty || city.isEmpty || zip.isEmpty {
            return false
        }
        return true
    }
}
