import UIKit

class ViewController: UIViewController {
    @IBOutlet var companyNameLabel: UILabel!
    @IBOutlet var companySymbolLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var priceChangeLabel: UILabel!

    @IBOutlet var companyPickerView: UIPickerView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    private var quoteService: QuoteService = QuoteService()

    private lazy var companies: [String: String] = [String: String]()

    private lazy var directionToColor = [
        Direction.up: #colorLiteral(red: 0.4410318643, green: 1, blue: 0.5127332155, alpha: 1),
        Direction.down: #colorLiteral(red: 1, green: 0.2428795703, blue: 0.1901274799, alpha: 1),
        Direction.flat: #colorLiteral(red: 0.01622682996, green: 0.06301424652, blue: 0.08238171786, alpha: 1),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        companyPickerView.dataSource = self
        companyPickerView.delegate = self
        activityIndicator.hidesWhenStopped = true

        requestSymbols()
    }
    
    private func requestSymbols() {
        quoteService.requestSymbols(success: { nameToSymbol in
            self.activityIndicator.startAnimating()
            self.companies = nameToSymbol
            // Refresh picker view after load companies
            self.companyPickerView.reloadAllComponents()
            self.requestQuoteUpdate()
        }) { error in
            self.showNotification(error)
            self.activityIndicator.stopAnimating()
        }
    }

    private func requestQuoteUpdate() {
        let selectedRow = companyPickerView.selectedRow(inComponent: 0)
        
        if (selectedRow == -1) {
            self.showNotification("Internal error. Selected empty company.")
            activityIndicator.stopAnimating()
            return
        }
        
        let selectedSymbol = Array(companies.values)[selectedRow]

        activityIndicator.startAnimating()

        companyNameLabel.text = "-"
        companySymbolLabel.text = "-"
        priceLabel.text = "-"
        priceChangeLabel.text = "-"
        priceChangeLabel.textColor = directionToColor[Direction.flat]

        quoteService.requestQuote(for: selectedSymbol, success: { currentQuote in
            print("Current quote: \(currentQuote.toString()).")
            self.displayStockInfo(companySymbol: currentQuote.companySymbol,
                                  companyName: currentQuote.companyName,
                                  price: currentQuote.price,
                                  priceChange: currentQuote.priceChange,
                                  direction: currentQuote.direction)
        }) { error in
            self.showNotification(error)
        }
    }

    private func displayStockInfo(companySymbol: String,
                                  companyName: String,
                                  price: Double,
                                  priceChange: Double,
                                  direction: Direction) {
        activityIndicator.stopAnimating()

        companyNameLabel.text = self.prepareCompanyName(companyName)
        companySymbolLabel.text = companySymbol
        priceLabel.text = "\(price)"
        priceChangeLabel.text = "\(priceChange)"
        priceChangeLabel.textColor = directionToColor[direction]
    }
    
    private func prepareCompanyName(_ companyName: String) -> String {
        if (companyName.count > 22) {
            let firstIndex = companyName.startIndex
            let lastIndex = companyName.index(firstIndex, offsetBy:21)
            return "\(companyName[firstIndex...lastIndex])..."
        }
        return companyName
    }

    private func showNotification(_ errorMessage: String) {
        let alert = UIAlertController(title: "Internal Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

        present(alert, animated: true)
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
