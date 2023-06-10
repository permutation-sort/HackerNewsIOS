import SwiftUI
import UIKit
import WebKit

struct ContentView: View {
    @ObservedObject var viewModel = HackerNewsViewModel()
    @State private var selectedPost: HackerNewsPost?

    var body: some View {
        NavigationView {
            VStack {
                Text("Hacker News")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .foregroundColor(Color.white) // Set text color to orange
                
                List(viewModel.hackerNewsPosts) { post in
                    Button(action: {
                        selectedPost = post
                    }) {
                        VStack(alignment: .leading) {
                            Text(post.title)
                                .font(.headline)
                                .foregroundColor(.black)
                                .lineLimit(2)
                            if let url = post.url {
                                Text(url)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                            }
                        }
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .listRowSeparator(.hidden) // Hide the default row separator
                }
                .background(Color.white) // Set the background color to white
                .refreshable {
                    await viewModel.fetchHackerNewsPosts()
                }
                .padding(.top, 10)
                .listStyle(PlainListStyle()) // Use plain list style to remove the default grouped style
            }
            .background(Color.orange)
            .onAppear {
                viewModel.fetchHackerNewsPosts()
            }
            .fullScreenCover(item: $selectedPost) { post in
                NavigationView {
                    DetailedView(post: post)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // New line added here
    }
}

struct DetailedView: View {
    let post: HackerNewsPost
    @Environment(\.presentationMode) var presentationMode
    @State private var showingShareSheet = false

    var body: some View {
        WebViewWrapper(url: URL(string: post.url ?? ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: [URL(string: post.url ?? "") as Any])
            }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Update the view controller if necessary.
    }
}

struct WebViewWrapper: UIViewControllerRepresentable {
    let url: URL?

    func makeUIViewController(context: Context) -> WebViewController {
        let viewController = WebViewController()
        viewController.url = url
        return viewController
    }

    func updateUIViewController(_ uiViewController: WebViewController, context: Context) {}
}

class WebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var url: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadURL()
        setupNavigationBarItems()
    }

    private func setupWebView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    private func loadURL() {
        if let url = url {
            webView.load(URLRequest(url: url))
        }
    }

    private func setupNavigationBarItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeWebView))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareURL))
    }

    @objc private func closeWebView() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func shareURL() {
        guard let url = url else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some
    
    View {
    ContentView()
    }
    }
