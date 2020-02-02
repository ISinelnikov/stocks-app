import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    
    @IBOutlet weak var companyPickerView: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private lazy var companies = [
        "Apple": "AAPL",
        "Microsoft": "MSFT",
        "Google": "GOOG",
        "Amazon": "AMZN",
        "Facebook": "FB",
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        companyNameLabel.text = "Tinkoff"
        companyPickerView.dataSource = self
        companyPickerView.delegate = self

        activityIndicator.hidesWhenStopped = true
        
        requestQuoteUpdate()
    }

    private func requestQuote(for symbol: String) {
        print("Request quote for: \(symbol).")
        
        let token = "pk_4335b7641e304f6e8ef89cfe43a99cb4"
        guard let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?token=\(token)") else {
            return
        }

        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, responce, error in
            if let data = data,
                (responce as? HTTPURLResponse)?.statusCode == 200,
                error == nil {
                self?.parseQuote(from: data)
            } else {
                print("Network error!")
            }
        }

        dataTask.resume()
    }

    private func parseQuote(from data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)

            guard
                let json = jsonObject as? [String: Any],
                let companyName = json["companyName"] as? String else { return print("Json is invalid!") }

            print(jsonObject)
            
            DispatchQueue.main.async { [weak self] in
                self?.displayStockInfo(companyName: companyName)
            }
        } catch {
            print("Can't parse quote with error: " + error.localizedDescription)
        }
    }
    
    private func displayStockInfo(companyName: String) {
        activityIndicator.stopAnimating()
        companyNameLabel.text = companyName
    }
    
    private func requestQuoteUpdate() {
        activityIndicator.startAnimating()
        
        companyNameLabel.text = "-"
        
        let selectedRow = companyPickerView.selectedRow(inComponent: 0)
        
        let selectedSymbol = Array(companies.values)[selectedRow]
        requestQuote(for: selectedSymbol)
    }
}

extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        companies.keys.count
    }
}

extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        Array(companies.keys)[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        requestQuoteUpdate()
    }
}
