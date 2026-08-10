//
//  ImagePreviewViewController.swift
//  Hippo
//

import UIKit
import CropViewController

final class ImagePreviewViewController: UIViewController {

    var image: UIImage? {
        didSet { imageView.image = image }
    }
    var onSend: ((UIImage) -> Void)?

    private let imageView = UIImageView()
    private let topBar = UIView()
    private let cropButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)
    private let sendButton = UIButton(type: .system)

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupImageView()
        setupTopBar()
        setupSendButton()
    }

    private func setupImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupTopBar() {
        topBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.backgroundColor = UIColor(white: 0.15, alpha: 1)
        view.addSubview(topBar)
        NSLayoutConstraint.activate([
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.topAnchor.constraint(equalTo: view.topAnchor),
            topBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44)
        ])

        cropButton.setImage(UIImage(systemName: "crop"), for: .normal)
        closeButton.setImage(HippoConfig.shared.theme.crossBarButtonImage ?? UIImage(systemName: "xmark"), for: .normal)

        [cropButton, closeButton].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = UIColor(white: 0.32, alpha: 1)
            button.tintColor = .white
            button.layer.cornerRadius = 16
            button.layer.masksToBounds = true
            topBar.addSubview(button)
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 32),
                button.heightAnchor.constraint(equalToConstant: 32),
                button.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22)
            ])
        }

        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: topBar.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            cropButton.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -12)
        ])

        cropButton.addTarget(self, action: #selector(cropTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }

    private func setupSendButton() {
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setImage(HippoConfig.shared.theme.sendBtnIcon?.withRenderingMode(.alwaysOriginal), for: .normal)
        sendButton.imageView?.contentMode = .scaleAspectFit
        sendButton.imageView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sendButton)
        NSLayoutConstraint.activate([
            sendButton.widthAnchor.constraint(equalToConstant: 52),
            sendButton.heightAnchor.constraint(equalToConstant: 52),
            sendButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
        if let sendImageView = sendButton.imageView {
            NSLayoutConstraint.activate([
                sendImageView.widthAnchor.constraint(equalTo: sendButton.widthAnchor),
                sendImageView.heightAnchor.constraint(equalTo: sendButton.heightAnchor),
                sendImageView.centerXAnchor.constraint(equalTo: sendButton.centerXAnchor),
                sendImageView.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor)
            ])
        }
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
    }

    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func cropTapped() {
        guard let image = image else { return }
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        cropViewController.modalPresentationStyle = .fullScreen
        present(cropViewController, animated: true, completion: nil)
    }

    @objc private func sendTapped() {
        guard let image = image else { return }
        onSend?(image)
        dismiss(animated: true, completion: nil)
    }
}

extension ImagePreviewViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.image = image
        cropViewController.dismiss(animated: true, completion: nil)
    }

    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
}
