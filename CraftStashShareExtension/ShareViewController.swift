import UIKit
import Social
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let saveButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let checkmarkImageView = UIImageView()

    private var sharedURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        extractSharedContent()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 20
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

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

        subtitleLabel.text = "Knutselidee wordt opgeslagen..."
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(subtitleLabel)

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

            iconLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            iconLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            activityIndicator.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            checkmarkImageView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            checkmarkImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 32),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 32),

            saveButton.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 48),

            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 8),
            cancelButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
        ])
    }

    private func extractSharedContent() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            subtitleLabel.text = "Kon content niet laden"
            activityIndicator.stopAnimating()
            return
        }

        for item in extensionItems {
            guard let attachments = item.attachments else { continue }

            for attachment in attachments {
                // Try URL first
                if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    attachment.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] data, _ in
                        DispatchQueue.main.async {
                            if let url = data as? URL {
                                self?.sharedURL = url.absoluteString
                                self?.subtitleLabel.text = self?.detectPlatform(from: url.absoluteString) ?? "Link gevonden"
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
                                self?.subtitleLabel.text = self?.detectPlatform(from: text) ?? "Link gevonden"
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
        guard let urlString = sharedURL else {
            subtitleLabel.text = "Geen link gevonden"
            return
        }

        let platform = detectPlatform(from: urlString)
        let item = SharedDataManager.SharedItem(
            urlString: urlString,
            title: nil,
            sourcePlatform: platform,
            dateAdded: Date()
        )

        SharedDataManager.savePendingItem(item)

        // Show success
        UIView.animate(withDuration: 0.3) {
            self.activityIndicator.isHidden = true
            self.checkmarkImageView.isHidden = false
            self.subtitleLabel.text = "Opgeslagen! ✂️"
            self.saveButton.isHidden = true
        }

        // Auto-dismiss after short delay
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
