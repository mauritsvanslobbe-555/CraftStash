import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    // Design tokens (matching Theme.swift)
    private let bgColor = UIColor(red: 0.04, green: 0.03, blue: 0.06, alpha: 1.0)           // 0x0A0810
    private let surfaceColor = UIColor(red: 0.086, green: 0.071, blue: 0.122, alpha: 1.0)    // 0x16121F
    private let surfaceHiColor = UIColor(red: 0.122, green: 0.102, blue: 0.173, alpha: 1.0)  // 0x1F1A2C
    private let inkColor = UIColor(red: 0.957, green: 0.945, blue: 0.98, alpha: 1.0)         // 0xF4F1FA
    private let inkMuteColor = UIColor(red: 0.957, green: 0.945, blue: 0.98, alpha: 0.62)
    private let inkDimColor = UIColor(red: 0.957, green: 0.945, blue: 0.98, alpha: 0.38)
    private let primaryColor = UIColor(red: 0.482, green: 0.361, blue: 1.0, alpha: 1.0)      // 0x7B5CFF
    private let borderColor = UIColor.white.withAlphaComponent(0.07)
    private let mintColor = UIColor(red: 0.31, green: 0.89, blue: 0.69, alpha: 1.0)          // 0x4FE3B0

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
        view.backgroundColor = UIColor.black.withAlphaComponent(0.55)

        containerView.backgroundColor = bgColor
        containerView.layer.cornerRadius = 28
        containerView.clipsToBounds = true
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        // Preview image
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        previewImageView.backgroundColor = surfaceColor
        previewImageView.isHidden = true
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(previewImageView)

        // App icon
        let iconLabel = UILabel()
        iconLabel.text = "\u{2702}\u{FE0F}"
        iconLabel.font = .systemFont(ofSize: 42)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(iconLabel)

        titleLabel.text = "Opslaan in StuffStash"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = inkColor
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        subtitleLabel.text = "Idee wordt geladen..."
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = inkMuteColor
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(subtitleLabel)

        // Name text field
        nameTextField.placeholder = "Geef een naam (optioneel)"
        nameTextField.font = .systemFont(ofSize: 14.5)
        nameTextField.borderStyle = .none
        nameTextField.backgroundColor = surfaceColor
        nameTextField.textColor = inkColor
        nameTextField.tintColor = primaryColor
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "Geef een naam (optioneel)",
            attributes: [.foregroundColor: inkDimColor]
        )
        nameTextField.layer.cornerRadius = 14
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = borderColor.cgColor
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        nameTextField.leftViewMode = .always
        nameTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        nameTextField.rightViewMode = .always
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameTextField)

        activityIndicator.color = primaryColor
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        containerView.addSubview(activityIndicator)

        checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        checkmarkImageView.tintColor = mintColor
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.isHidden = true
        containerView.addSubview(checkmarkImageView)

        saveButton.setTitle("Bewaar", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        saveButton.backgroundColor = primaryColor
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 16
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        containerView.addSubview(saveButton)

        cancelButton.setTitle("Annuleer", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 14)
        cancelButton.setTitleColor(inkMuteColor, for: .normal)
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

            nameTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 14),
            nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),

            activityIndicator.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 14),
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            checkmarkImageView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 14),
            checkmarkImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 32),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 32),

            saveButton.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16),
            saveButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 52),

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
                        let urlString = (data as? URL)?.absoluteString
                        DispatchQueue.main.async {
                            if let urlString {
                                self?.sharedURL = urlString
                                let platform = self?.detectPlatform(from: urlString) ?? "Link"
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

                // Try plain text
                if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier) { [weak self] data, _ in
                        let text = data as? String
                        DispatchQueue.main.async {
                            if let text, text.hasPrefix("http") {
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
            self.subtitleLabel.text = "Opgeslagen!"
            self.subtitleLabel.textColor = self.mintColor
            self.saveButton.isHidden = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.extensionContext?.completeRequest(returningItems: nil)
        }
    }

    @objc private func cancelTapped() {
        extensionContext?.cancelRequest(withError: NSError(domain: "com.stuffstash", code: 0))
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
