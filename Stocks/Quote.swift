struct Quote {
    let companySymbol: String
    let companyName: String
    let price: Double
    let priceChange: Double
    let direction: Direction

    public func toString() -> String {
        "Quote: {companySymbol: '\(companySymbol)', companyName: '\(companyName)', price: '\(price)', priceChange: '\(priceChange)', direction: '\(direction)'}"
    }
}

enum Direction {
    case up, down, flat
}
