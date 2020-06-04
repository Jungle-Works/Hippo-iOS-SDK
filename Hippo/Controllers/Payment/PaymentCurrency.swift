//
//  PaymentCurrency.swift
//  Hippo
//
//  Created by Vishal on 22/02/19.
//

import Foundation


class PaymentCurrency: NSObject {
    private static var currencies: [PaymentCurrency] = []
    
    var id: Int = -1
    var symbol: String = ""
    var code: String = ""
    var name: String = ""
    var displayName: String = ""
    
    init(json: [String: Any]) {
        id = Int.parse(values: json, key: "currency_id") ?? -1
        symbol = json["symbol"] as? String ?? ""
        code = json["code"] as? String ?? ""
        name = json["name"] as? String ?? ""
        
        displayName = name + " (\(symbol))"
    }
    
    init(_ symbol : String, _ name : String){
        self.symbol = symbol
        self.code = name
    }
    
    class func getAllCurrency() -> [PaymentCurrency] {
        guard currencies.isEmpty else {
            return currencies
        }
        var list: [PaymentCurrency] = []
        
        for each in currencyJson {
            let currency = PaymentCurrency(json: each)
            list.append(currency)
        }
        
        currencies = list
        return currencies
    }
    
    static func findCurrency(code: String?, symbol: String?) -> PaymentCurrency? {
        let currencies = getAllCurrency()
        var objForCode: PaymentCurrency?
        var objForSymbol: PaymentCurrency?
        
        for each in currencies {
            guard objForCode == nil && objForSymbol == nil else {
                break
            }
            if each.code == code, objForCode == nil {
                objForCode = each
            }
            if each.symbol == symbol, objForSymbol == nil {
                objForSymbol = each
            }
        }
        return objForCode ?? objForSymbol
    }
}

let currencyJson: [[String: Any]] = [
    [
        "currency_id": 1,
        "symbol": "$",
        "code": "USD",
        "name": "United States dollar"
    ],
    [
        "currency_id": 2,
        "symbol": "€",
        "code": "EUR",
        "name": "Euro"
    ],
    [
        "currency_id": 3,
        "symbol": "¥",
        "code": "JPY",
        "name": "Japanese yen"
    ],
    [
        "currency_id": 4,
        "symbol": "£",
        "code": "GBP",
        "name": "Pound sterling"
    ],
    [
        "currency_id": 5,
        "symbol": "$",
        "code": "AUD",
        "name": "Australian dollar"
    ],
    [
        "currency_id": 6,
        "symbol": "C$",
        "code": "CAD",
        "name": "Canadian dollar"
    ],
    [
        "currency_id": 7,
        "symbol": "Fr.",
        "code": "CHF",
        "name": "Swiss franc"
    ],
    [
        "currency_id": 8,
        "symbol": "¥",
        "code": "CNY",
        "name": "Chinese yuan"
    ],
    [
        "currency_id": 9,
        "symbol": "kr",
        "code": "SEK",
        "name": "Swedish krona"
    ],
    [
        "currency_id": 10,
        "symbol": "Mex$",
        "code": "MXN",
        "name": "Mexican peso"
    ],
    [
        "currency_id": 11,
        "symbol": "NZ$",
        "code": "NZD",
        "name": "New Zealand dollar"
    ],
    [
        "currency_id": 12,
        "symbol": "S$",
        "code": "SGD",
        "name": "Singapore dollar"
    ],
    [
        "currency_id": 13,
        "symbol": "HK$",
        "code": "HKD",
        "name": "Hong Kong dollar"
    ],
    [
        "currency_id": 14,
        "symbol": "kr",
        "code": "NOK",
        "name": "Norwegian krone"
    ],
    [
        "currency_id": 15,
        "symbol": "₩",
        "code": "KRW",
        "name": "South Korean won"
    ],
    [
        "currency_id": 16,
        "symbol": "₹",
        "code": "INR",
        "name": "Indian rupee"
    ],
    [
        "currency_id": 17,
        "symbol": "₽",
        "code": "RUB",
        "name": "Russian ruble"
    ],
    [
        "currency_id": 18,
        "symbol": "R",
        "code": "ZAR",
        "name": "South African rand"
    ],
    [
        "currency_id": 19,
        "symbol": "KSh",
        "code": "KES",
        "name": "Kenyan Shilling"
    ],
    [
        "currency_id": 20,
        "symbol": "ZK",
        "code": "ZMW",
        "name": "Zambian Kwacha"
    ],
    [
        "currency_id": 21,
        "symbol": "AED",
        "code": "AED",
        "name": "Arab Emirates Dirham"
    ],
    [
        "currency_id": 22,
        "symbol": "E£",
        "code": "EGP",
        "name": "Egyptian Pound"
    ],
    [
        "currency_id": 23,
        "symbol": "S",
        "code": "PEN",
        "name": "Peruvian Sol"
    ],
    [
        "currency_id": 24,
        "symbol": "UGX",
        "code": "UGX",
        "name": "Ugandan Shilling"
    ],
    [
        "currency_id": 25,
        "symbol": "ع.د",
        "code": "IQD",
        "name": "Iraqi Dinar"
    ],
    [
        "currency_id": 26,
        "symbol": "﷼",
        "code": "QAR",
        "name": "Qatari Riyal"
    ],
    [
        "currency_id": 27,
        "symbol": "$",
        "code": "COP",
        "name": "Colombian Peso"
    ],
    [
        "currency_id": 28,
        "symbol": "kr",
        "code": "SEK",
        "name": "Swedish Krona"
    ],
    [
        "currency_id": 29,
        "symbol": "₦",
        "code": "NGN",
        "name": "Nigerian Naira"
    ],
    [
        "currency_id": 30,
        "symbol": "RM",
        "code": "MYR",
        "name": "Malaysian Ringgit"
    ],
    [
        "currency_id": 31,
        "symbol": "re",
        "code": "RES",
        "name": "res"
    ]
]
