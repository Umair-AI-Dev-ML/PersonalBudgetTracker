
package com.budgettracker.util;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Arrays;
import java.util.Base64;

public class PasswordUtil {

    private static final int ITERATIONS = 600000;
    private static final int SALT_LENGTH = 16;
    private static final int KEY_LENGTH = 256;

    private static final int MAX_ITERATIONS = 2000000;

    private static final String HASH_ALGORITHM =
            "PBKDF2WithHmacSHA256";

    private static final String HASH_PREFIX =
            "pbkdf2_sha256";

    private static final SecureRandom RANDOM =
            new SecureRandom();


    // Hash a password before storing it in MySQL
    public static String hashPassword(String password) {

        if (password == null) {
            throw new IllegalArgumentException(
                    "Password cannot be null."
            );
        }

        byte[] salt = new byte[SALT_LENGTH];

        // Generate a new random salt for every password
        RANDOM.nextBytes(salt);

        char[] passwordChars = password.toCharArray();

        try {

            byte[] hash = generateHash(
                    passwordChars,
                    salt,
                    ITERATIONS
            );

            try {

                return HASH_PREFIX + ":" +
                        ITERATIONS + ":" +
                        Base64.getEncoder().encodeToString(salt) + ":" +
                        Base64.getEncoder().encodeToString(hash);

            } finally {

                // Clear the derived key from this temporary array
                Arrays.fill(hash, (byte) 0);
            }

        } finally {

            // Clear temporary password characters
            Arrays.fill(passwordChars, '\0');
        }
    }


    // Verify the password entered during login
    public static boolean verifyPassword(
            String password,
            String storedHash) {

        if (password == null || storedHash == null) {
            return false;
        }

        try {

            // Check stored hash structure
            String[] parts = storedHash.split(":", -1);

            if (parts.length != 4 ||
                    !HASH_PREFIX.equals(parts[0])) {
                return false;
            }

            // Read iteration count
            int iterations = Integer.parseInt(parts[1]);

            if (iterations < 1 ||
                    iterations > MAX_ITERATIONS) {
                return false;
            }

            // Decode the stored salt and password hash
            byte[] salt =
                    Base64.getDecoder().decode(parts[2]);

            byte[] expectedHash =
                    Base64.getDecoder().decode(parts[3]);

            if (salt.length != SALT_LENGTH ||
                    expectedHash.length != KEY_LENGTH / 8) {
                return false;
            }

            char[] passwordChars = password.toCharArray();

            try {

                byte[] actualHash = generateHash(
                        passwordChars,
                        salt,
                        iterations
                );

                try {

                    // Compare without ordinary String equality
                    return MessageDigest.isEqual(
                            expectedHash,
                            actualHash
                    );

                } finally {

                    Arrays.fill(actualHash, (byte) 0);
                }

            } finally {

                Arrays.fill(passwordChars, '\0');
                Arrays.fill(expectedHash, (byte) 0);
            }

        } catch (IllegalArgumentException e) {

            // Invalid stored hash format
            return false;
        }
    }


    // Generate a PBKDF2 password hash
    private static byte[] generateHash(
            char[] password,
            byte[] salt,
            int iterations) {

        PBEKeySpec spec = new PBEKeySpec(
                password,
                salt,
                iterations,
                KEY_LENGTH
        );

        try {

            SecretKeyFactory factory =
                    SecretKeyFactory.getInstance(
                            HASH_ALGORITHM
                    );

            return factory.generateSecret(spec).getEncoded();

        } catch (GeneralSecurityException e) {

            throw new IllegalStateException(
                    "Password hashing failed.",
                    e
            );

        } finally {

            // Clear password copy held by PBEKeySpec
            spec.clearPassword();
        }
    }
}
