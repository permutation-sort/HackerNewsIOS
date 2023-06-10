import Combine
import Foundation

class HackerNewsViewModel: ObservableObject {
    @Published var hackerNewsPosts: [HackerNewsPost] = []
    // STAR FEATURE
    @Published var favoritePostsIDs: [UUID] = []

    
    func fetchHackerNewsPosts() {
        guard let url = URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching Hacker News posts: \(error)")
                return
            }
            
            if let data = data {
                do {
                    let postIDs = try JSONDecoder().decode([Int].self, from: data)
                    
                    let postIDsSlice = postIDs.prefix(10)
                    let group = DispatchGroup()
                    
                    // Temporary array to store newly fetched posts
                    var newPosts: [HackerNewsPost] = []
                    
                    for postID in postIDsSlice {
                        group.enter()
                        
                        let postURL = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(postID).json")!
                        
                        URLSession.shared.dataTask(with: postURL) { postData, _, _ in
                            defer { group.leave() }
                            
                            if let postData = postData {
                                do {
                                    let post = try JSONDecoder().decode(HackerNewsPost.self, from: postData)
                                    DispatchQueue.main.async {
                                        // Append to the temporary array
                                        newPosts.append(post)
                                    }
                                } catch {
                                    print("Error decoding post data: \(error)")
                                }
                            }
                        }.resume()
                    }
                    
                    group.notify(queue: DispatchQueue.main) {
                        // Replace hackerNewsPosts with newPosts once all posts are fetched
                        DispatchQueue.main.async {
                            self.hackerNewsPosts = newPosts
                        }
                    }
                } catch {
                    print("Error decoding post IDs: \(error)")
                }
            }
        }.resume()
    }
    // STAR FEATURE
    func toggleFavorite(post: HackerNewsPost) {
        if let index = self.favoritePostsIDs.firstIndex(of: post.id) {
            self.favoritePostsIDs.remove(at: index)
        } else {
            self.favoritePostsIDs.append(post.id)
        }
    }

}
