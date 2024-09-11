import UIKit

class DetailViewController: UIViewController {
    private let imageView = UIImageView()
    private let descriptionLabel = UILabel()
    private let authorLabel = UILabel()
    private let shareButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    
    private let viewModel: DetailViewModel
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = .black
        descriptionLabel.numberOfLines = 0
        view.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        
        authorLabel.font = UIFont.systemFont(ofSize: 14)
        authorLabel.textColor = .darkGray
        view.addSubview(authorLabel)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            authorLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        shareButton.setTitle("Поделиться", for: .normal)
        shareButton.addTarget(self, action: #selector(shareImage), for: .touchUpInside)
        view.addSubview(shareButton)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareButton.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 16),
            shareButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        configureView()
    }
    
    private func configureView() {
        descriptionLabel.text = viewModel.descriptionText
        authorLabel.text = viewModel.authorText
        if let url = viewModel.imageUrl {
            loadImage(from: url)
        }
    }
    
    private func loadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
        task.resume()
    }
    
    @objc private func shareImage() {
        guard let image = imageView.image else { return }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
    @objc private func saveImage() {
        guard let image = imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let alertTitle = error == nil ? "Сохранено!" : "Ошибка сохранения"
        let alertMessage = error?.localizedDescription ?? "Ваше изображение сохранено в фотоальбом."
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}

