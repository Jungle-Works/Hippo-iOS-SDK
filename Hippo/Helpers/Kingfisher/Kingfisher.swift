//
//  Kingfisher.swift
//  Kingfisher
//
//  Created by Wei Wang on 16/9/14.
//
//  Copyright (c) 2017 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import ImageIO

#if os(macOS)
    import AppKit
      typealias Image = NSImage
      typealias View = NSView
      typealias Color = NSColor
      typealias ImageView = NSImageView
      typealias Button = NSButton
#else
    import UIKit
      typealias Image = UIImage
      typealias Color = UIColor
    #if !os(watchOS)
      typealias ImageView = UIImageView
      typealias View = UIView
      typealias Button = UIButton
    #endif
#endif

  final class Kingfisher<Base> {
      let base: Base
      init(_ base: Base) {
        self.base = base
    }
}

/**
 A type that has Kingfisher extensions.
 */
  protocol KingfisherCompatible {
    associatedtype CompatibleType
    var kf: CompatibleType { get }
}

  extension KingfisherCompatible {
      var kf: Kingfisher<Self> {
        get { return Kingfisher(self) }
    }
}

extension Image: KingfisherCompatible { }
#if !os(watchOS)
extension ImageView: KingfisherCompatible { }
extension Button: KingfisherCompatible { }
#endif
