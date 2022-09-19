//
//  KeyboardVocabulary.swift
//  KeyboardKit
//
//  Created by Valentin Shergin on 6/21/16.
//  Copyright © 2016 AnchorFree. All rights reserved.
//

import Foundation
import UIKit


extension UITextChecker {
    func isValidWord(nsWord nsWord: NSString, nsLanguage: NSString) -> Bool {
        guard nsWord.rangeOfCharacterFromSet(cachedNonLetterCharacterSet).location == NSNotFound else {
            return false
        }

        guard nsLanguage.isEqual("en") else {
            return true
        }

        guard nsWord.length > 2 else {
            return false
        }

        return nsWord.canBeConvertedToEncoding(NSASCIIStringEncoding)
    }

    func completions(word: String, language: String) -> [String] {
        let nsLanguage: NSString = language
        let nsWord: NSString = word
        let nsRange = NSRange(location: 0, length: nsWord.length)

        guard self.isValidWord(nsWord: nsWord, nsLanguage: nsLanguage) else { return [] }

        return self.completionsForPartialWordRange(nsRange, inString: nsWord as? String, language: nsLanguage as String) as? [String] ?? []
    }

    func guesses(word: String, language: String) -> [String] {
        let nsLanguage: NSString = language
        let nsWord: NSString = word
        let nsRange = NSRange(location: 0, length: nsWord.length)

        guard self.isValidWord(nsWord: nsWord, nsLanguage: nsLanguage) else { return [] }

        return self.guessesForWordRange(nsRange, inString: nsWord as String, language: nsLanguage as String) as? [String] ?? []
    }

    func isMisspelled(word: String, language: String) -> Bool {
        let nsLanguage: NSString = language
        let nsWord: NSString = word
        let nsRange = NSRange(location: 0, length: nsWord.length)

        guard self.isValidWord(nsWord: nsWord, nsLanguage: nsLanguage) else { return false }

        return self.rangeOfMisspelledWordInString(
            nsWord as String,
            range: nsRange,
            startingAt: 0,
            wrap: false,
            language: nsLanguage as String
        ).location == NSNotFound
    }
}


private let maxCompletionsCount = 10
private let maxCorrectionsCount = 100


internal class KeyboardVocabulary {
    internal let language: String

    private let words: [String: Int]
    private let checker = UITextChecker()

    internal init(language: String, commaSeparatedWords: String = "") {
        self.language = language

        var score = 0
        var words: [String: Int] = [:]
        for word in commaSeparatedWords.componentsSeparatedByString(",") {
            words[word] = score
            score += 1
        }

        self.words = words
    }

    internal func score(word: String) -> Int? {
        return self.words[word]
    }

    internal func completions(query: KeyboardSuggestionQuery) -> [String] {
        let prefix = query.placement

        guard !prefix.isEmpty else {
            return []
        }

        let lowercasePrefix = prefix.lowercaseString
        let prefixLength = prefix.characters.count

        var scoredComplitions: [(word: String, score: Int)] = []

        for (word, score) in self.words {
            if word.hasPrefix(lowercasePrefix) {
                guard word.characters.count > prefixLength else {
                    continue
                }

                let word = prefix + word.substringFromIndex(word.startIndex.advancedBy(prefixLength))

                scoredComplitions.append((word: word, score: score))
            }
        }

        /*
        // This is crashing sometimes.
        var checkerCompletions =
            checker.completionsForPartialWordRange(
                query.range,
                inString: query.context,
                language: self.language
            ) as? [String] ?? []
        */

        if !prefix.isEmpty {
            var checkerCompletions = checker.completions(prefix, language: self.language)
            let scoredCheckerCompletions = checkerCompletions.map { (word: $0, score: self.words[$0] ?? (100000 + $0.characters.count) ) }
            scoredComplitions.appendContentsOf(scoredCheckerCompletions)
        }

        // Filter

        // Sort
        scoredComplitions.sortInPlace { (left, right) -> Bool in
            left.score < right.score
        }

        var completions = scoredComplitions.map { $0.word }

        if completions.count > maxCompletionsCount {
            completions = Array(completions.prefix(maxCompletionsCount))
        }

        // Applying all-caps if needed.
        if prefixLength > 1 && prefix == prefix.uppercaseString {
            completions = completions.map { $0.uppercaseString }
        }

        return completions
    }

    internal func corrections(query: KeyboardSuggestionQuery) -> [String] {
        /*
        return checker.guessesForWordRange(
                query.range,
                inString: query.context,
                language: self.language
            ) as? [String] ?? []
        */
        let placement = query.placement

        guard !placement.isEmpty else {
            return []
        }

        var corrections = self.checker.guesses(placement, language: self.language)

        if corrections.count > maxCorrectionsCount {
            corrections = Array(corrections.prefix(maxCorrectionsCount))
        }

        return corrections
    }

    internal func isSpellProperly(query: KeyboardSuggestionQuery) -> Bool {
        let placement = query.placement

        guard !placement.isEmpty else {
            return true
        }

        if self.words[placement.lowercaseString] != nil {
            return true
        }

        /*
        return self.checker.rangeOfMisspelledWordInString(
                query.context,
                range: query.range,
                startingAt: query.range.location,
                wrap: false,
                language: self.language
            ).location == NSNotFound
        */

        return self.checker.isMisspelled(placement, language: self.language)
    }

}


extension KeyboardVocabulary {
    static var cachedVocabularies: [String: KeyboardVocabulary?] = [:]

    static func vocabulary(language language: String) -> KeyboardVocabulary? {
        guard language.characters.count >= 2 else {
            return nil
        }

        // Predefined
        switch language.substringToIndex(language.startIndex.advancedBy(2)).lowercaseString {
        case "en":
            return englishVocabulary
        case "ru":
            return russianVocabulary
        default:
            break
        }

        //
        if let vocabulary = self.cachedVocabularies[language] {
            return vocabulary
        }

        let vocabulary = KeyboardVocabulary(language: language)
        self.cachedVocabularies[language] = vocabulary
        return vocabulary
    }
}
