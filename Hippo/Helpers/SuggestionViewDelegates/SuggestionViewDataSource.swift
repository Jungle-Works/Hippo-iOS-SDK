
import Foundation
import UIKit

class SuggestionViewDataSource: NSObject, UICollectionViewDataSource {
    private var suggestions: [String] = []
    private var nextURL: String?
    private var getSelection: chatViewDelegateProtocol!
    
    init(suggestions: [String]) {
        self.suggestions = suggestions
    }
    
    func initializeDelegate(vc: chatViewDelegateProtocol) {
        getSelection = vc
    }
    
    func update(suggestions: [String], nextURL: String?) {
        self.suggestions = suggestions
        self.nextURL = nextURL
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestionCell", for: indexPath) as! SuggestionCell
        cell.prepareCellUI()
        cell.layoutIfNeeded()
        cell.titleLabel.text = suggestions[indexPath.item]
        cell.layoutIfNeeded()
        return cell
    }
}



