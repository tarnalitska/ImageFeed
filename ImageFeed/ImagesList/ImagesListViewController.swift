import UIKit

protocol ImagesListViewProtocol: AnyObject {
    func updatePhotos(_ photos: [Photo])
    func insertRows(at indexPaths: [IndexPath])
    func reloadTable()
    func navigateToSingleImageScreen(with url: URL)
    func reloadRow(at indexPath: IndexPath)
}

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    let tokenStorage = OAuth2TokenStorage()
    @IBOutlet private var tableView: UITableView!
    private var presenter: ImagesListPresenter!
    private var photos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        presenter = ImagesListPresenter(view: self)
        presenter.viewDidLoad()
    }
    
    func updatePhotos(_ photos: [Photo]) {
        self.photos = photos
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL)
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        presenter.willDisplayRow(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        presenter.configure(imageListCell, at: indexPath)
        
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        presenter.heightForRow(at: indexPath, tableViewWidth: tableView.bounds.width)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter.didTapLike(at: indexPath)
    }
}

extension ImagesListViewController: ImagesListViewProtocol {
    func insertRows(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func reloadTable() {
        tableView.reloadData()
    }
    
    func navigateToSingleImageScreen(with url: URL) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SingleImageViewController") as! SingleImageViewController
        viewController.imageURL = url
        self.present(viewController, animated: true)
    }
    
    func reloadRow(at indexPath: IndexPath){
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
