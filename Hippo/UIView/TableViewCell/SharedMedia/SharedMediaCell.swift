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

import UIKit

class SharedMediaCell: UICollectionViewCell {

    static let cornerRadius: CGFloat = 12

    /// Backdrop for a video tile, so letterboxed thumbnails blend into the frame.
    private static let videoBackground = UIColor(red: 0.078, green: 0.078, blue: 0.078, alpha: 1)

    //MARK:- IBOutlets
    @IBOutlet weak var imageViewMedia : UIImageView!
    @IBOutlet weak var buttonPlay : UIButton!

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
        buttonPlay.setImage(buttonPlay.image(for: .normal)?.withRenderingMode(.alwaysTemplate),
                            for: .normal)
        buttonPlay.tintColor = .white
        buttonPlay.isUserInteractionEnabled = false

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
        downloadIndicator.stopAnimating()
    }

    // MARK: Configuration

    func configure(with item: ShareMediaModel) {
        let colorConfig = HippoConfig.shared.colorConfig
        let isVideo = item.fileType == .video
        let isDownloading = item.openURL.map { DownloadManager.shared.isFileBeingDownloadedWith(url: $0) } ?? false

        buttonPlay.isHidden = !isVideo || isDownloading
        if isDownloading {
            downloadIndicator.startAnimating()
        } else {
            downloadIndicator.stopAnimating()
        }
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
}
