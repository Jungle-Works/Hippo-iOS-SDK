//
//  SharedMediaModel.swift
//  HippoAgent
//
//  Created by Arohi Magotra on 18/03/21.
//  Copyright © 2021 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation

struct ShareMediaModel: Decodable {
    let message_type: Int?
    let muid: String?
    let message: String?
    let file_name: String?
    /// Pre-formatted by the backend ("3.74 kB"), and absent on some attachments —
    /// the subtitle drops the component rather than showing a placeholder.
    let file_size: String?
    let image_url: String?
    let thumbnail_url: String?
    let integration_source: Int?
    let document_type : String?
    let url : String?
}

/// The two tabs the Shared Media screen splits attachments across.
enum SharedMediaTab {
    /// Photos and videos, shown as a square grid.
    case media
    /// Documents and audio, shown as a list of rows.
    case docs
}

// MARK: - Presentation

extension ShareMediaModel {

    /// Length of the UUID that prefixes every muid, e.g.
    /// "dc320e7d-7453-42be-a961-a3abe1823020".
    private static let muidUUIDLength = 36

    /// Attachments older than this are assumed to be a mis-parse rather than a real
    /// send date. 2010-01-01, comfortably before the product existed.
    private static let earliestPlausibleTimestamp: TimeInterval = 1_262_304_000

    /// Recordings made in-app arrive as these; any other audio is a file the user
    /// picked and shared, so it gets a different label.
    private static let voiceNoteExtensions: Set<String> = ["AAC", "M4A"]

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMM"
        return formatter
    }()

    var fileType: FileType? {
        guard let document_type = document_type else { return nil }
        return FileType(rawValue: document_type)
    }

    /// `FileType` is a closed four-case enum written at upload time from the MIME
    /// prefix, so this switch is total. A missing `document_type` means a legacy
    /// attachment that predates the field; those have always been rendered as
    /// images, so they stay in the grid.
    var tab: SharedMediaTab {
        switch fileType {
        case .audio, .document:
            return .docs
        case .image, .video, nil:
            return .media
        }
    }

    /// Uppercased extension for the badge and subtitle, e.g. "PDF". Nil when the
    /// filename carries no extension at all.
    var fileExtension: String? {
        guard let file_name = file_name else { return nil }
        let ext = (file_name as NSString).pathExtension
        return ext.isEmpty ? nil : ext.uppercased()
    }

    /// The send time, recovered from the epoch-ms the backend appends to the muid —
    /// `getAttachments` returns no date field of its own. Two shapes are in the
    /// wild, with and without a "." before the timestamp.
    ///
    /// Deliberately strict: anything unexpected yields nil so the subtitle omits the
    /// date, rather than rendering a date that is wrong.
    var sentDate: Date? {
        guard let muid = muid, muid.count > Self.muidUUIDLength else { return nil }

        var suffix = String(muid.dropFirst(Self.muidUUIDLength))
        if suffix.hasPrefix(".") { suffix.removeFirst() }

        guard suffix.count == 13,
              suffix.allSatisfy({ $0.isASCII && $0.isNumber }),
              let milliseconds = Double(suffix) else { return nil }

        let seconds = milliseconds / 1000
        guard seconds >= Self.earliestPlausibleTimestamp,
              seconds <= Date().timeIntervalSince1970 + 86_400 else { return nil }

        return Date(timeIntervalSince1970: seconds)
    }

    /// Filenames come back as UUIDs, so the caption the sender typed is the only
    /// human-written text available. Falls back to a label built from the type.
    var displayTitle: String {
        let caption = (message ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return caption.isEmpty ? typeLabel : caption
    }

    private var typeLabel: String {
        if fileType == .audio {
            let isVoiceNote = fileExtension.map(Self.voiceNoteExtensions.contains) ?? false
            return isVoiceNote ? HippoStrings.sharedMediaVoiceMessage
                               : HippoStrings.sharedMediaAudioFile
        }
        guard let fileExtension = fileExtension else {
            return HippoStrings.sharedMediaGenericDocument
        }
        return String(format: HippoStrings.sharedMediaDocumentFormat, fileExtension)
    }

    /// "AAC · 3.74 kB · 8 Sep", dropping whichever components are unavailable so a
    /// missing size never leaves a dangling separator.
    func displaySubtitle(timeZone: TimeZone = .current) -> String {
        var components: [String] = []

        if let fileExtension = fileExtension {
            components.append(fileExtension)
        }
        if let size = file_size?.trimmingCharacters(in: .whitespaces), !size.isEmpty {
            components.append(size)
        }
        if let sentDate = sentDate {
            Self.shortDateFormatter.timeZone = timeZone
            components.append(Self.shortDateFormatter.string(from: sentDate))
        }

        return components.joined(separator: " · ")
    }
}

extension Array where Element == ShareMediaModel {
    /// Partitions without sorting: the backend already returns newest-first, and a
    /// client-side sort would be a second place the muid format could bite us.
    func sharedMediaItems(for tab: SharedMediaTab) -> [ShareMediaModel] {
        filter { $0.tab == tab }
    }
}
