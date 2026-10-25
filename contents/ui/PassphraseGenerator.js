// Uses the C++ SecureRandom provider backed by QRandomGenerator::system().

function randomIndex(max, secureRandom) {
    if (!secureRandom || max <= 0) {
        return -1;
    }

    var index = secureRandom.bounded(max);

    return index >= 0 && index < max ? index : -1;
}

function normalizeWordCount(wordCount) {
    var count = Number(wordCount);

    if (!isFinite(count)) {
        count = 4;
    }

    return Math.max(1, Math.min(12, Math.floor(count)));
}

function generate(wordList, wordCount, includeCapitals, includeNumbers, separator, secureRandom) {
    if (!wordList || wordList.length === 0 || !secureRandom) {
        return "";
    }

    var words = [];

    wordCount = normalizeWordCount(wordCount);

    for (var i = 0; i < wordCount; i++) {
        var index = randomIndex(wordList.length, secureRandom);

        if (index < 0) {
            return "";
        }

        var word = wordList[index];

        if (typeof word !== "string" || word.length === 0) {
            return "";
        }

        if (includeCapitals) {
            word = word.charAt(0).toUpperCase() + word.slice(1);
        }

        words.push(word);
    }

    if (includeNumbers) {
        var wordIndex = randomIndex(words.length, secureRandom);
        var digit = randomIndex(10, secureRandom);

        if (wordIndex < 0 || digit < 0) {
            return "";
        }

        words[wordIndex] += digit.toString();
    }

    return words.join(separator);
}

// Estimates theoretical entropy from independent, uniformly random choices.
// Deterministic capitalization and separators add no entropy.
// Random digit placement contributes log2(wordCount) bits.
// Repeated words can make the actual output entropy slightly lower.

function estimateEntropy(wordCount, wordList, includeNumbers) {
    if (!wordList || wordList.length === 0) {
        return 0;
    }

    wordCount = normalizeWordCount(wordCount);

    var entropy = wordCount * Math.log2(wordList.length);

    if (includeNumbers) {
        entropy += Math.log2(10);
        entropy += Math.log2(wordCount);
    }

    return entropy;
}