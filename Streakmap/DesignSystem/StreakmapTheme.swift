import SwiftUI
import UIKit

enum StreakmapTheme {
    static let background = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 1) : UIColor(red: 0.973, green: 0.973, blue: 0.965, alpha: 1)
    })

    static let card = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(red: 0.11, green: 0.11, blue: 0.118, alpha: 1) : .white
    })

    static let textPrimary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(red: 0.976, green: 0.98, blue: 0.984, alpha: 1) : UIColor(red: 0.067, green: 0.094, blue: 0.153, alpha: 1)
    })

    static let textSecondary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(red: 0.612, green: 0.639, blue: 0.686, alpha: 1) : UIColor(red: 0.42, green: 0.447, blue: 0.502, alpha: 1)
    })

    static let neutralCell = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(red: 0.173, green: 0.173, blue: 0.18, alpha: 1) : UIColor(red: 0.914, green: 0.925, blue: 0.937, alpha: 1)
    })

    static let accent = Color(hex: "#4F46E5")

    static let shadow = Color.black.opacity(0.06)
}
