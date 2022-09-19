//
//  KeyboardTextInputTraitsObserver.swift
//  KeyboardKit
//
//  Created by Valentin Shergin on 1/15/16.
//  Copyright © 2016 AnchorFree. All rights reserved.
//

import UIKit


internal final class KeyboardTextInputTraitsObserver: NSObject {
    internal typealias Handler = (UITextInputTraits) -> Void

    private var handler: Handler
    private var previousKeyboardAppearance: UIKeyboardAppearance!
    private var previousKeyboardType: UIKeyboardType!

    private var pollingTimer: CADisplayLink?

    internal init(handler: Handler) {
        self.handler = handler
        super.init()

        self.enable()
    }

    internal func disable() {
        self.pollingTimer?.invalidate()
        self.pollingTimer = nil
    }

    internal func enable() {
        self.disable()
        self.pollingTimer = UIScreen.mainScreen().displayLinkWithTarget(self, selector: #selector(self.poll))
        self.pollingTimer?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    }

    internal dynamic func poll() {
        guard let inputViewController = UIInputViewController.optionalRootInputViewController else {
            return
        }

        let strange = String(inputViewController.dynamicType) == "UICompatibilityInputViewController"
        if strange {
            #if DEBUG
                fatalError("UICompatibilityInputViewController")
            #else
                return
            #endif
        }

        let textInputTraits = inputViewController.textDocumentProxy as UITextInputTraits

        if self.previousKeyboardAppearance != nil && self.previousKeyboardType != nil {
            // TODO: Rewrite this.
            if
                self.previousKeyboardAppearance == textInputTraits.keyboardAppearance &&
                self.previousKeyboardType == textInputTraits.keyboardType
            {
                return
            }
        }

        self.previousKeyboardAppearance = textInputTraits.keyboardAppearance
        self.previousKeyboardType = textInputTraits.keyboardType

        self.handler(textInputTraits)
    }
}
