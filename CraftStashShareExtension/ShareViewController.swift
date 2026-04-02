import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let previewImageView = UIImageView()
    private let nameTextField = UITextField()
    private let saveButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let checkmarkImageView = UIImageView()

    private var sharedURL: String?
    private var sharedTitle: String?
    private var sharedImageData: Data?
    private var sharedImageFileName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        extractSharedContent()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 20
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        // Preview image
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        previewImageView.backgroundColor = UIColor(red: 1.0, green: 0.44, blue: 0.37, alpha: 0.1)
        previewImageView.isHidden = true
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(previewImageView)

        // App icon / scissors emoji
        let iconLabel = UILabel()
        iconLabel.text = "✂️"
        iconLabel.font = .systemFont(ofSize: 48)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(iconLabel)

        titleLabel.text = "Opslaan in CraftStash"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        subtitleLabel.text = "Knutselidee wordt geladen..."
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(subtitleLabel)

        // Name text field
        nameTextField.placeholder = "Geef een naam (optioneel)"
        nameTextField.font = .systemFont(ofSize: 15)
        nameTextField.borderStyle = .none
        nameTextField.backgroundColor = UIColor.secondarySystemBackground
        nameTextField.layer.cornerRadius = 10
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        nameTextField.leftViewMode = .always
        nameTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        nameTextField.rightViewMode = .always
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameTextField)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        containerView.addSubview(activityIndicator)

        checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        checkmarkImageView.tintColor = UIColor(red: 0.18, green: 0.74, blue: 0.56, alpha: 1.0)
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.isHidden = true
        containerView.addSubview(checkmarkImageView)

        saveButton.setTitle("Bewaar", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        saveButton.backgroundColor = UIColor(red: 1.0, green: 0.44, blue: 0.37, alpha: 1.0)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 12
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        containerView.addSubview(saveButton)

        cancelButton.setTitle("Annuleer", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 15)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        containerView.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),

            previewImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            previewImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            previewImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            previewImageView.heightAnchor.constraint(equalToConstant: 160),

            iconLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            iconLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            nameTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),

            activityIndicator.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 12),
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            checkmarkImageView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 12),
            checkmarkImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 32),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 32),

            saveButton.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16),
            saveButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 48),

            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 8),
            cancelButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
        ])
    }

    private var iconLabelTopWithPreview: NSLayoutConstraint?
    private var iconLabelTopWithoutPreview: NSLayoutConstraint?

    private func showPreviewImage(_ image: UIImage) {
        previewImageView.image = image
        previewImageView.isHidden = false
        // Move icon below the preview
        for constraint in containerView.constraints {
            if constraint.firstItem as? UILabel != nil && constraint.secondItem as? UIView === containerView && constraint.firstAttribute == .top {
                constraint.constant = 184
                break
            }
        }
    }

    private func extractSharedContent() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            subtitleLabel.text = "Kon content niet laden"
            activityIndicator.stopAnimating()
            return
        }

        for item in extensionItems {
            // Extract title from the shared item (e.g. page title from browser)
            if let attributedTitle = item.attributedContentText?.string, !attributedTitle.isEmpty {
                sharedTitle = attributedTitle
            }

            guard let attachments = item.attachments else { continue }

            for attachment in attachments {
                // Try image first
                if attachment.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    attachment.loadItem(forTypeIdentifier: UTType.image.identifier) { [weak self] data, _ in
                        var imageData: Data?

                        if let url = data as? URL {
                            imageData = try? Data(contentsOf: url)
                        } else if let image = data as? UIImage {
                            imageData = image.jpegData(compressionQuality: 0.8)
                        } else if let rawData = data as? Data {
                            imageData = rawData
                        }

                        DispatchQueue.main.async {
                            if let imageData = imageData {
                                self?.sharedImageData = imageData
                                if let uiImage = UIImage(data: imageData) {
                                    self?.showPreviewImage(uiImage)
                                }
                                self?.subtitleLabel.text = "Afbeelding klaar om op te slaan"
                            }
                            if let title = self?.sharedTitle {
                                self?.nameTextField.text = title
                            }
                            self?.activityIndicator.stopAnimating()
                        }
                    }
                    return
                }

                // Try URL
                if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    attachment.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] data, _ in
                        DispatchQueue.main.async {
                            if let url = data as? URL {
                                self?.sharedURL = url.absoluteString
                                let platform = self?.detectPlatform(from: url.absoluteString) ?? "Link"
                                self?.subtitleLabel.text = "\(platform) link gevonden"
                            }
                            if let title = self?.sharedTitle {
                                self?.nameTextField.text = title
                            }
                            self?.activityIndicator.stopAnimating()
                        }
                    }
                    return
                }

                // Try plain text (some apps share URLs as text)
                if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier) { [weak self] data, _ in
                        DispatchQueue.main.async {
                            if let text = data as? String, text.hasPrefix("http") {
                                self?.sharedURL = text
                                let platform = self?.detectPlatform(from: text) ?? "Link"
                                self?.subtitleLabel.text = "\(platform) link gevonden"
                            }
                            if let title = self?.sharedTitle {
                                self?.nameTextField.text = title
                            }
                            self?.activityIndicator.stopAnimating()
                        }
                    }
                    return
                }
            }
        }
    }

    @objc private func saveTapped() {
        // Get user-entered or auto-filled title
        let userTitle = nameTextField.text?.trimmingCharacters(in: .whitespaces)
        let finalTitle = (userTitle?.isEmpty == false) ? userTitle : sharedTitle

        // Save shared image
        if let imageData = sharedImageData {
            if let fileName = SharedDataManager.saveImageToSharedContainer(imageData) {
                let item = SharedDataManager.SharedItem(
                    urlString: "local-image://\(fileName)",
                    title: finalTitle ?? "Knutselidee",
                    sourcePlatform: "Screenshot",
                    dateAdded: Date(),
                    imageFileName: fileName
                )
                SharedDataManager.savePendingItem(item)
                showSuccess()
            }
            return
        }

        // Save shared URL
        guard let urlString = sharedURL else {
            subtitleLabel.text = "Geen link of afbeelding gevonden"
            return
        }

        let platform = detectPlatform(from: urlString)
        let item = SharedDataManager.SharedItem(
            urlString: urlString,
            title: finalTitle,
            sourcePlatform: platform,
            dateAdded: Date(),
            imageFileName: nil
        )

        SharedDataManager.savePendingItem(item)
        showSuccess()
    }

    private func showSuccess() {
        UIView.animate(withDuration: 0.3) {
            self.activityIndicator.isHidden = true
            self.checkmarkImageView.isHidden = false
            self.subtitleLabel.text = "Opgeslagen! ✂️"
            self.saveButton.isHidden = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.extensionContext?.completeRequest(returningItems: nil)
        }
    }

    @objc private func cancelTapped() {
        extensionContext?.cancelRequest(withError: NSError(domain: "com.craftstash", code: 0))
    }

    private func detectPlatform(from url: String) -> String {
        let lowered = url.lowercased()
        if lowered.contains("youtube") || lowered.contains("youtu.be") { return "YouTube" }
        if lowered.contains("pinterest") { return "Pinterest" }
        if lowered.contains("instagram") { return "Instagram" }
        if lowered.contains("tiktok") { return "TikTok" }
        if lowered.contains("facebook") || lowered.contains("fb.watch") { return "Facebook" }
        if lowered.contains("twitter") || lowered.contains("x.com") { return "X" }
        if lowered.contains("vimeo") { return "Vimeo" }
        if lowered.contains("reddit") { return "Reddit" }
        return "Web"
    }
}
