import Foundation

protocol AlertPresenterDelegate: AnyObject {
    func showResultAlert (alertModel: AlertModel)
}
