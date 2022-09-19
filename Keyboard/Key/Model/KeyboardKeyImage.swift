//
//  KeyboardKeyImage.swift
//  KeyboardKit
//
//  Created by Valentin Shergin on 1/22/16.
//  Copyright © 2016 AnchorFree. All rights reserved.
//

import Foundation


public enum KeyboardKeyImage {
    case BackspaceImage
    case ShiftImage
    case AdvanceToNextInputModeImage
    case Emoji
    case CustomView(ViewType: UIView.Type)
}


extension KeyboardKeyImage {
    public init?(keyType: KeyboardKeyType) {
        switch keyType {
        case .Backspace:
            self = .BackspaceImage
            break
        case .Shift:
            self = .ShiftImage
            break
        case .AdvanceToNextInputMode:
            self = .AdvanceToNextInputModeImage
            break
        default:
            return nil
        }
    }

    public func view(keyboardMode keyboardMode: KeyboardMode, keyMode: KeyboardKeyMode) -> UIView {
        switch self {
        case .BackspaceImage:
            return KeyboardKeyBackspaceSymbolView()
        case .ShiftImage:
            switch keyboardMode.shiftMode {
            case .Enabled:
                return KeyboardKeyEnabledShiftSymbolView()
            case .Disabled:
                return KeyboardKeyDisabledShiftSymbolView()
            case .Locked:
                return KeyboardKeyLockedShiftSymbolView()
            }
        case .AdvanceToNextInputModeImage:
            return KeyboardKeyAdvanceToNextInputModeSymbolView()
        case .Emoji:
            return KeyboardKeyEmojiSymbolView()
        case .CustomView(let ViewType):
            return ViewType.init()
        }
    }
}
