import UIKit

class PhotoCell: UICollectionViewCell {
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
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7)
        ])

        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = .black
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
        
        authorLabel.font = UIFont.systemFont(ofSize: 12)
        authorLabel.textColor = .darkGray
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
        if let url = URL(string: mediaItem.urls.small) {
            loadImage(from: url)
            imageView.isHidden = false
        } else {
            imageView.isHidden = true
        }

        titleLabel.text = mediaItem.description ?? "Описание отсутствует"
        authorLabel.text = "Автор: \(mediaItem.user.name)"
    }

    private func loadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self?.imageView.isHidden = true
                }
                return
            }
            DispatchQueue.main.async {
                self?.imageView.image = image
                self?.imageView.isHidden = false
            }
        }
        task.resume()
    }
}

