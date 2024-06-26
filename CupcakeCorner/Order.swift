//
//  Order.swift
//  CupcakeCorner
//
//  Created by Víctor Ávila on 08/05/24.
//

import Foundation

struct Address: Codable {
    var name: String
    var street: String
    var city: String
    var zip: String
}

@Observable
class Order: Codable {
    // Mapping all names created by @Observable to the real keys (avoiding the _$observationRegistrar extra key)
    // This way, the JSON returned by the server will have THE SAME KEYS as this class
    enum CodingKeys: String, CodingKey {
        case _type = "type"
        case _quantity = "quantity"
        case _specialRequestEnabled = "specialRequestEnabled"
        case _extraFrosting = "extraFrosting"
        case _addSprinkles = "addSprinkles"
        case _address = "address"
    }
    
    // Read from UserDefaults, if it already exists
    init() {
        if let savedAdress = UserDefaults.standard.data(forKey: "address") {
            if let decodedAddress = try? JSONDecoder().decode(Address.self, from: savedAdress) {
                address = decodedAddress
                return
            }
        }
        address = Address(name: "", street: "", city: "", zip: "")
    }
    
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
    var address = Address(name: "", street: "", city: "", zip: "") {
        didSet {
            if let encoded = try? JSONEncoder().encode(address) {
                UserDefaults.standard.set(encoded, forKey: "address")
            }
        }
    }
    
    // How to stop the user if they only filled in 3 out of the 4 fields?
    // Please, don't use length checks for the name, for example. They exclude people.
    // Let's just verify if name, street address, city and zip aren't empty. We'll combine this with SwiftUI .disabled() modifier to stop the user interaction if the condition is true.
    var hasValidAddress: Bool {
        if address.name.isEmpty || address.street.isEmpty || address.city.isEmpty || address.zip.isEmpty {
            return false
        } else if address.name.trimmingCharacters(in: .whitespaces).isEmpty || address.street.trimmingCharacters(in: .whitespaces).isEmpty || address.city.trimmingCharacters(in: .whitespaces).isEmpty || address.zip.trimmingCharacters(in: .whitespaces).isEmpty {
            return false
        }
        return true
    }
    
    // Ideally, deal with prices with Decimal instead of Double (it's much more accurate).
    // Behind the scenes, Decimal uses Integer mathematics for each number after the point (which won't cause rounding errors or Double weird behaviours).
    var cost: Decimal {
        // $2 per cake
        var cost = Decimal(quantity) * 2
        
        // Complicated cakes, like Rainbow, cost more
        cost += Decimal(type) / 2
        
        // $1/cake for extra frosting
        if extraFrosting {
            cost += Decimal(quantity)
        }
        
        // $0.50/cake for sprinkles
        if addSprinkles {
            cost += Decimal(quantity) / 2
        }
        
        return cost
    }
}
