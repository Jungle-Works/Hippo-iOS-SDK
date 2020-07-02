
import Foundation
import UIKit

protocol chatViewDelegateProtocol {
    func selectedSuggestion(indexPath: IndexPath)
}

class SuggestionViewDelegate: NSObject, UICollectionViewDelegate {
    private var getSelection: chatViewDelegateProtocol!

    func update(vc: chatViewDelegateProtocol) {
        getSelection = vc
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        getSelection.selectedSuggestion(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let ncell = cell as? SuggestionCell
        ncell?.prepareCellUI()
        ncell?.layoutIfNeeded()
    }
}



