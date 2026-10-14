import SwiftUI
import WebKit

/// Miya 半醒手记 — 网页壳
struct MiyaWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

@main
struct MiyaApp: App {
    var body: some Scene {
        WindowGroup {
            MiyaWebView(url: URL(string: "https://ophelia-0116.github.io/miya/")!)
                .ignoresSafeArea()
                .statusBarHidden(true)
        }
    }
}
