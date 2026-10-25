// Uses the C++ SecureRandom provider backed by QRandomGenerator::system().

var UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
var LOWERCASE = "abcdefghijklmnopqrstuvwxyz";
var DIGITS = "0123456789";
var SPECIAL = "!@#$%^&*";

function randomIndex(max, secureRandom) {
    return secureRandom.bounded(max);
}

function shuffle(characters, secureRandom) {
    // Fisher-Yates shuffle using secure random indices.
    for (var i = characters.length - 1; i > 0; i--) {
        var j = randomIndex(i + 1, secureRandom);

        var temp = characters[i];
        characters[i] = characters[j];
        characters[j] = temp;
    }

    return characters;
}

function generate(
    passwordLength,
    includeUppercase,
    includeLowercase,
    includeDigits,
    includeSpecialCharacters,
    minimumNumbers,
    minimumSpecialCharacters,
    secureRandom
) {
    if (!secureRandom)
        return "";

    passwordLength = Math.max(5, Math.min(128, Number(passwordLength) || 16));
    minimumNumbers = Math.max(0, Number(minimumNumbers) || 0);
    minimumSpecialCharacters = Math.max(0, Number(minimumSpecialCharacters) || 0);

    var characterPool = "";
    var characters = [];

    if (includeUppercase)
        characterPool += UPPERCASE;

    if (includeLowercase)
        characterPool += LOWERCASE;

    if (includeDigits)
        characterPool += DIGITS;

    if (includeSpecialCharacters)
        characterPool += SPECIAL;

    // At least one character set must be enabled.
    if (characterPool.length === 0)
        return "";


    // Apply minimum requirements only to enabled character sets.
    var requiredNumbers = includeDigits ? minimumNumbers : 0;
    var requiredSpecial = includeSpecialCharacters ? minimumSpecialCharacters : 0;
    
    if (requiredNumbers + requiredSpecial > passwordLength)
        return "";
    
    // Generate mandatory digits.
    for (var i = 0; i < requiredNumbers; i++) {
        characters.push(
            DIGITS.charAt(randomIndex(DIGITS.length, secureRandom))
        );
    }
    
    // Generate mandatory special characters.
    for (var j = 0; j < requiredSpecial; j++) {
        characters.push(
            SPECIAL.charAt(randomIndex(SPECIAL.length, secureRandom))
        );
    }
    
    // Fill remaining positions from the enabled character pool.
    while (characters.length < passwordLength) {
        characters.push(
            characterPool.charAt(randomIndex(characterPool.length, secureRandom))
        );
    }
    
    // Shuffle the generated password.
    shuffle(characters, secureRandom);
    
    return characters.join("");
}

// Estimates entropy using the mandatory character requirements.
// This is an approximation based on the generation strategy:
// mandatory positions are generated from their respective sets,
// remaining positions are selected from the combined pool,
// and the final password is shuffled.

function estimateEntropy(
    passwordLength,
    poolSize,
    minimumNumbers,
    minimumSpecialCharacters
) {
    passwordLength = Math.max(0, Number(passwordLength) || 0);
    poolSize = Math.max(0, Number(poolSize) || 0);
    minimumNumbers = Math.max(0, Number(minimumNumbers) || 0);
    minimumSpecialCharacters = Math.max(0, Number(minimumSpecialCharacters) || 0);

    if (poolSize === 0 || minimumNumbers + minimumSpecialCharacters > passwordLength)
        return 0;

    var entropy = 0;
    var remainingLength = passwordLength - minimumNumbers - minimumSpecialCharacters;

    // Mandatory digits.
    if (minimumNumbers > 0)
        entropy += minimumNumbers * Math.log2(DIGITS.length);

    // Mandatory special characters.
    if (minimumSpecialCharacters > 0)
        entropy += minimumSpecialCharacters * Math.log2(SPECIAL.length);

    // Remaining characters are selected from the combined pool.
    entropy += remainingLength * Math.log2(poolSize);

    return entropy;
}