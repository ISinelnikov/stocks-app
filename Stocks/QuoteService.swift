import UIKit

class QuoteService {
    private let API_TOKEN = "pk_33807dd047364026b2755952731a7a44"

    private var sumbolToLastPrice = [String: Double]()

    public func requestQuote(for symbol: String,
                             successCallback: @escaping (_ currentQuote: Quote) -> Void,
                             errorCallback: @escaping (_ errorMessage: String) -> Void) {
        print("Request actual quote for: \(symbol).")

        guard
            let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?token=\(API_TOKEN)")
        else {
            return
        }

        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, responce, error in
            if let data = data,
                (responce as? HTTPURLResponse)?.statusCode == 200,
                error == nil {
                self?.parseQuote(from: data, successCallback: successCallback, errorCallback: errorCallback)
            } else {
                errorCallback("Can't get actual quote from server!")
            }
        }

        dataTask.resume()
    }

    private func parseQuote(from data: Data,
                            successCallback: @escaping (_ currentQuote: Quote) -> Void,
                            errorCallback: @escaping (_ errorMessage: String) -> Void) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)

            guard
                let json = jsonObject as? [String: Any],
                let companySymbol = json["symbol"] as? String,
                let companyName = json["companyName"] as? String,
                let price = json["latestPrice"] as? Double,
                let priceChange = json["change"] as? Double
            else { return errorCallback("Quote data is invalid!") }

            DispatchQueue.main.async { [weak self] in
                guard
                    let strongSelf = self
                else {
                    errorCallback("Can't get actual quote with internal error!")
                    return
                }

                var direction: Direction = Direction.flat

                // Get and refresh last quote price value
                if let lastPrice = strongSelf.sumbolToLastPrice[companySymbol] {
                    if price == lastPrice {
                        direction = Direction.flat
                    } else if lastPrice < price {
                        direction = Direction.up
                    } else {
                        direction = Direction.down
                    }
                } else {
                    print("Can't get last price by symbol: \(companySymbol).")
                }
                strongSelf.sumbolToLastPrice[companySymbol] = price

                successCallback(Quote(companySymbol: companySymbol,
                                      companyName: companyName,
                                      price: price,
                                      priceChange: priceChange,
                                      direction: direction))
            }
        } catch {
            errorCallback("Can't parse quote with error: \(error.localizedDescription)")
        }
    }
}
