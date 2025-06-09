import Foundation

protocol DateFormatterServiceProtocol: AnyObject {
    func formatDate(_ date: Date?) -> String
}

final class DateFormatterService: DateFormatterServiceProtocol {
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        return formatter.string(from: date)
    }
}
