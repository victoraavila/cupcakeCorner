//
//  Order.swift
//  CupcakeCorner
//
//  Created by Víctor Ávila on 08/05/24.
//

import Foundation

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
        case _name = "name"
        case _city = "city"
        case _streetAddress = "streetAddress"
        case _zip = "zip"
    }
    
    init() {
        if let savedName = UserDefaults.standard.data(forKey: "name") {
            if let decodedName = try? JSONDecoder().decode(String.self, from: savedName) {
                name = decodedName
            } else {
                name = ""
            }
        } else {
            name = ""
        }
        
        if let savedStreetAddress = UserDefaults.standard.data(forKey: "streetAddress") {
            if let decodedStreetAddress = try? JSONDecoder().decode(String.self, from: savedStreetAddress) {
                streetAddress = decodedStreetAddress
            } else {
                streetAddress = ""
            }
        } else {
            streetAddress = ""
        }
        
        if let savedCity = UserDefaults.standard.data(forKey: "city") {
            if let decodedCity = try? JSONDecoder().decode(String.self, from: savedCity) {
                city = decodedCity
            } else {
                city = ""
            }
        } else {
            city = ""
        }
        
        if let savedZip = UserDefaults.standard.data(forKey: "zip") {
            if let decodedZip = try? JSONDecoder().decode(String.self, from: savedZip) {
                zip = decodedZip
            } else {
                zip = ""
            }
        } else {
            zip = ""
        }
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
    var name = "" {
        didSet {
            if let encoded = try? JSONEncoder().encode(name) {
                UserDefaults.standard.set(encoded, forKey: "name")
            }
        }
    }
    var streetAddress = "" {
        didSet {
            if let encoded = try? JSONEncoder().encode(streetAddress) {
                UserDefaults.standard.set(encoded, forKey: "streetAddress")
            }
        }
    }
    var city = "" {
        didSet {
            if let encoded = try? JSONEncoder().encode(city) {
                UserDefaults.standard.set(encoded, forKey: "city")
            }
        }
    }
    var zip = "" {
        didSet {
            if let encoded = try? JSONEncoder().encode(zip) {
                UserDefaults.standard.set(encoded, forKey: "zip")
            }
        }
    }
    
    // How to stop the user if they only filled in 3 out of the 4 fields?
    // Please, don't use length checks for the name, for example. They exclude people.
    // Let's just verify if name, street address, city and zip aren't empty. We'll combine this with SwiftUI .disabled() modifier to stop the user interaction if the condition is true.
    var hasValidAddress: Bool {
        if name.isEmpty || streetAddress.isEmpty || city.isEmpty || zip.isEmpty {
            return false
        } else if name.trimmingCharacters(in: .whitespaces).isEmpty || streetAddress.trimmingCharacters(in: .whitespaces).isEmpty || city.trimmingCharacters(in: .whitespaces).isEmpty || zip.trimmingCharacters(in: .whitespaces).isEmpty {
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
