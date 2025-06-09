import UIKit

protocol ImagesListCellProtocol: AnyObject {
    var dateLabelText: String? { get set }
    func setIsLiked(_ isLiked: Bool)
    func setImage(with url: URL?, placeholder: UIImage?)
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        cellImage.kf.indicatorType = .none
    }
    
    @IBAction private func likeButtonClicked(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked ? "like_button_on" : "like_button_off"
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }
}

extension ImagesListCell: ImagesListCellProtocol {
    var dateLabelText: String? {
        get {
            dateLabel.text
        }
        set {
            dateLabel.text = newValue
        }
    }
    
    func setImage(with url: URL?, placeholder: UIImage?) {
        cellImage.kf.indicatorType = .activity
        
        cellImage.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [.transition(.fade(0.3))]
        )
    }
}
