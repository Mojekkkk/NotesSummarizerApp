
import UIKit

func getWindows() -> [UIWindow] {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
        return []
    }
    return windowScene.windows
}
