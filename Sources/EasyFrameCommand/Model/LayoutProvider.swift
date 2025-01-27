//
//  LayoutProvider.swift
//  easy-frame
//
//  Created by Alexander Schmutz on 27.01.25.
//

import Foundation

protocol LayoutProvider {
    var size: CGSize { get }
    var deviceFrameOffset: CGSize { get }
}
