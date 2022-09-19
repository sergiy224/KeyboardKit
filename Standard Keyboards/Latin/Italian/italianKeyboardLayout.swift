//
//  italianKeyboardLayout.swift
//  KeyboardKit
//
//  Created by Valentin Shergin on 3/31/16.
//  Copyright © 2016 AnchorFree. All rights reserved.
//

import Foundation


public let italianKeyboardLayout: KeyboardLayout = {
    var keyboardLayout = qwertyKeyboardLayout
    keyboardLayout.language = "it"
    return keyboardLayout
} ()
