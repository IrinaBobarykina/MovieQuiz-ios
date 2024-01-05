import Foundation

public struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    var completion: () -> Void
}