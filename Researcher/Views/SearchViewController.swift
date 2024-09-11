import UIKit

class SearchViewController: UIViewController {
    private let searchBar = UISearchBar()
    private let collectionView: UICollectionView
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let errorLabel = UILabel()
    
    private var photos: [MediaItem] = []
    private var currentPage = 1
    private var isLoading = false
    private var currentQuery: String = ""
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 2 - 24, height: 250)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPhotos()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        searchBar.delegate = self
        searchBar.placeholder = "Поиск фотографий"
        navigationItem.titleView = searchBar
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        errorLabel.textColor = .red
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true
        view.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadPhotos(query: String = "") {
        guard !isLoading else { return }
        isLoading = true
        activityIndicator.startAnimating()
        errorLabel.isHidden = true
        
        let fetchMethod: (Int, @escaping (Result<[MediaItem], Error>) -> Void) -> Void
        if query.isEmpty {
            fetchMethod = NetworkManager.shared.fetchPhotos
        } else {
            fetchMethod = { page, completion in
                NetworkManager.shared.searchMedia(query: query, page: page, completion: completion)
            }
        }
        
        fetchMethod(currentPage) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.isLoading = false
                switch result {
                case .success(let mediaItems):
                    if self?.currentPage == 1 {
                        self?.photos = mediaItems
                    } else {
                        self?.photos.append(contentsOf: mediaItems)
                    }
                    self?.collectionView.reloadData()
                    self?.currentPage += 1
                case .failure(let error):
                    self?.errorLabel.text = "Ошибка: \(error.localizedDescription)"
                    self?.errorLabel.isHidden = false
                }
            }
        }
    }
    
    private func resetSearch() {
        photos = []
        currentPage = 1
        loadPhotos(query: currentQuery)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let query = searchBar.text, !query.isEmpty else { return }
        currentQuery = query
        resetSearch()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = nil
        currentQuery = ""
        resetSearch()
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let photo = photos[indexPath.item]
        cell.configure(with: photo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos[indexPath.item]
        guard let imageUrl = URL(string: photo.urls.full) else { return }
        
        let alertController = UIAlertController(title: "Выберите действие", message: nil, preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: "Сохранить изображение", style: .default) { _ in
            self.saveImage(from: imageUrl)
        }
        let sendAction = UIAlertAction(title: "Отправить изображение", style: .default) { _ in
            let activityVC = UIActivityViewController(activityItems: [imageUrl], applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(sendAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func saveImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        task.resume()
    }
}

