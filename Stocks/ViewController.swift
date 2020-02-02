import UIKit

class ViewController: UIViewController {
    @IBOutlet var companyNameLabel: UILabel!
    @IBOutlet var companyPickerView: UIPickerView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    private lazy var companies = [
        "Apple": "AAPL",
        "Microsoft": "MSFT",
        "Google": "GOOG",
        "Amazon": "AMZN",
        "Facebook": "FB",
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        companyNameLabel.text = "Tinkoff"
        companyPickerView.dataSource = self
        companyPickerView.delegate = self
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
}
