import SwiftUI
import WebKit

/// Luv — Miya 网页壳（带加载状态 / 错误提示 / 重试）
struct MiyaWebView: UIViewRepresentable {
    let url: URL
    var onLoadingChange: (Bool) -> Void
    var onError: (String) -> Void
    @Binding var retryTrigger: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(onLoading: onLoadingChange, onError: onError)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let onLoading: (Bool) -> Void
        let onError: (String) -> Void
        var webView: WKWebView?
        var url: URL?

        init(onLoading: @escaping (Bool) -> Void, onError: @escaping (String) -> Void) {
            self.onLoading = onLoading
            self.onError = onError
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            onLoading(true)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            onLoading(false)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            onLoading(false)
            onError(error.localizedDescription)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            onLoading(false)
            onError(error.localizedDescription)
        }
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        // 强制使用标准 iPhone Safari 标识，避免网页环境检测误判
        webView.customUserAgent =
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) " +
            "AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 Safari/604.1"
        context.coordinator.webView = webView
        context.coordinator.url = url
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if retryTrigger > 0 {
            if let u = context.coordinator.url {
                uiView.load(URLRequest(url: u))
            }
        }
    }
}

struct WebViewContainer: View {
    let url: URL
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var retryTrigger = 0

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            MiyaWebView(
                url: url,
                onLoadingChange: { loading in
                    if loading {
                        errorMessage = nil
                        isLoading = true
                    } else {
                        isLoading = false
                    }
                },
                onError: { err in
                    errorMessage = err
                    isLoading = false
                },
                retryTrigger: $retryTrigger
            )
            .ignoresSafeArea()

            if isLoading && errorMessage == nil {
                VStack(spacing: 14) {
                    ProgressView()
                        .scaleEffect(1.6)
                    Text("正在加载 Luv ...")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }

            if let err = errorMessage {
                VStack(spacing: 16) {
                    Text("网页加载失败")
                        .font(.headline)
                    Text(err)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 24)
                    Button("重试") {
                        retryTrigger += 1
                        isLoading = true
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
    }
}

@main
struct MiyaApp: App {
    var body: some Scene {
        WindowGroup {
            WebViewContainer(url: URL(string: "https://ophelia-0116.github.io/miya/")!)
                .ignoresSafeArea()
                .statusBarHidden(true)
        }
    }
}
