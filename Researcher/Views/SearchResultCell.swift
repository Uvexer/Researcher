import UIKit

class SearchResultCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .lightGray
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])

        contentView.addSubview(authorLabel)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            authorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with mediaItem: MediaItem) {
        titleLabel.text = mediaItem.description ?? "Описание отсутствует"
        authorLabel.text = "Автор: \(mediaItem.user.name)"

        if let url = URL(string: mediaItem.urls.small) {
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
}

