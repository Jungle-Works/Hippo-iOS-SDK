//
//  SharedMediaCell.swift
//  HippoAgent
//
//  Created by Arohi Magotra on 06/04/21.
//  Copyright © 2021 Socomo Technologies Private Limited. All rights reserved.
//
//  Square tile for the Media tab. The xib still supplies the image view and the play
//  button, but both are restyled here: the design wants a bare white triangle over a
//  dark tile rather than the nib's white circular badge.
//
//  Videos that aren't on the device yet show a download arrow instead of the play
//  triangle (opening them before the file lands left Quick Look blank). While one
//  downloads, a progress ring fills around the glyph and the glyph becomes × (tap
//  cancels) - same states as the chat's audio/file bubbles.
//

import UIKit

class SharedMediaCell: UICollectionViewCell {

    static let cornerRadius: CGFloat = 12

    /// Backdrop for a video tile, so letterboxed thumbnails blend into the frame.
    private static let videoBackground = UIColor(red: 0.078, green: 0.078, blue: 0.078, alpha: 1)

    //MARK:- IBOutlets
    @IBOutlet weak var imageViewMedia : UIImageView!
    @IBOutlet weak var buttonPlay : UIButton!

    /// Centre glyph while a video downloads - tapping the tile then cancels it.
    private static let cancelIcon = UIImage(systemName: "xmark",
                                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold))?
        .withRenderingMode(.alwaysTemplate)

    /// The nib's play triangle, kept so a reused tile can switch back from download / ×.
    private var playIcon: UIImage?

    /// Dark circle behind the download arrow / × so they read on any thumbnail; the
    /// progress ring sits on its edge. Hidden for a downloaded video (bare triangle).
    private let downloadBadge: UIView = {
        let badge = UIView()
        badge.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        badge.layer.cornerRadius = 22
        badge.isUserInteractionEnabled = false
        badge.isHidden = true
        badge.translatesAutoresizingMaskIntoConstraints = false
        return badge
    }()

    private let progressRing: DownloadProgressRingView = {
        let ring = DownloadProgressRingView()
        ring.color = .white
        ring.isHidden = true
        ring.translatesAutoresizingMaskIntoConstraints = false
        return ring
    }()

    /// Shown while the full-size file downloads ahead of opening it in Quick Look.
    private let downloadIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        // Clip on the contentView rather than the image view so the video backdrop
        // is rounded too.
        contentView.layer.cornerRadius = Self.cornerRadius
        contentView.layer.masksToBounds = true
        imageViewMedia.layer.cornerRadius = 0
        imageViewMedia.layer.masksToBounds = true

        // The nib draws an opaque white 44pt circle behind the glyph; the design is a
        // plain white triangle sitting directly on the thumbnail.
        buttonPlay.backgroundColor = .clear
        buttonPlay.layer.cornerRadius = 0
        buttonPlay.imageEdgeInsets = .zero
        playIcon = buttonPlay.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        buttonPlay.setImage(playIcon, for: .normal)
        buttonPlay.tintColor = .white
        buttonPlay.isUserInteractionEnabled = false

        contentView.insertSubview(downloadBadge, belowSubview: buttonPlay)
        downloadBadge.addSubview(progressRing)
        NSLayoutConstraint.activate([
            downloadBadge.widthAnchor.constraint(equalToConstant: 44),
            downloadBadge.heightAnchor.constraint(equalToConstant: 44),
            downloadBadge.centerXAnchor.constraint(equalTo: buttonPlay.centerXAnchor),
            downloadBadge.centerYAnchor.constraint(equalTo: buttonPlay.centerYAnchor),
            progressRing.topAnchor.constraint(equalTo: downloadBadge.topAnchor),
            progressRing.bottomAnchor.constraint(equalTo: downloadBadge.bottomAnchor),
            progressRing.leadingAnchor.constraint(equalTo: downloadBadge.leadingAnchor),
            progressRing.trailingAnchor.constraint(equalTo: downloadBadge.trailingAnchor),
        ])

        contentView.addSubview(downloadIndicator)
        NSLayoutConstraint.activate([
            downloadIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            downloadIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageViewMedia.kf.cancelDownloadTask()
        imageViewMedia.image = nil
        imageViewMedia.tintColor = nil
        buttonPlay.isHidden = true
        buttonPlay.setImage(playIcon, for: .normal)
        downloadBadge.isHidden = true
        progressRing.reset()
        progressRing.isHidden = true
        downloadIndicator.stopAnimating()
    }

    // MARK: Configuration

    func configure(with item: ShareMediaModel) {
        let colorConfig = HippoConfig.shared.colorConfig
        let isVideo = item.fileType == .video
        updateDownloadState(for: item)
        contentView.backgroundColor = isVideo ? Self.videoBackground
                                              : colorConfig.hippoSurfaceInput
        imageViewMedia.contentMode = .scaleAspectFill

        // Thumbnails keep the grid cheap; the full-size URL is only fetched when the
        // tile is opened.
        let thumbnail = isVideo ? item.thumbnail_url
                                : (item.thumbnail_url ?? item.image_url ?? item.url)

        guard let urlString = thumbnail, let url = URL(string: urlString) else {
            imageViewMedia.image = nil
            return
        }
        imageViewMedia.kf.setImage(with: url)

        accessibilityLabel = isVideo ? HippoStrings.video : HippoStrings.image
    }

    /// Glyph / ring / spinner for the tile's current download state. Cheap enough to
    /// call on every progress tick - it never touches the thumbnail.
    func updateDownloadState(for item: ShareMediaModel) {
        let isVideo = item.fileType == .video
        let isDownloading = item.openURL.map { DownloadManager.shared.isFileBeingDownloadedWith(url: $0) } ?? false

        guard isVideo else {
            // Photos: unchanged - spinner while the gallery preloads the full image.
            buttonPlay.isHidden = true
            downloadBadge.isHidden = true
            if isDownloading {
                downloadIndicator.startAnimating()
            } else {
                downloadIndicator.stopAnimating()
            }
            return
        }

        downloadIndicator.stopAnimating()
        buttonPlay.isHidden = false
        let isDownloaded = item.openURL.map { DownloadManager.shared.isFileDownloadedWith(url: $0) } ?? false

        if isDownloaded {
            buttonPlay.setImage(playIcon, for: .normal)
            downloadBadge.isHidden = true
            progressRing.reset()
            progressRing.isHidden = true
        } else if isDownloading, let url = item.openURL {
            buttonPlay.setImage(Self.cancelIcon, for: .normal)
            downloadBadge.isHidden = false
            progressRing.isHidden = false
            if let progress = DownloadManager.shared.downloadProgressFor(url: url) {
                progressRing.setProgress(progress)
            } else {
                progressRing.setIndeterminate()
            }
        } else {
            buttonPlay.setImage(HippoConfig.shared.theme.downloadIcon, for: .normal)
            downloadBadge.isHidden = false
            progressRing.reset()
            progressRing.isHidden = true
        }
    }
}
