
import unittest
from utils import check_policy, validate_line, hash_password


class TestCheckPolicy(unittest.TestCase):

    def test_short_password(self):
        self.assertEqual(check_policy("abc"), "WEAK")

    def test_letters_only(self):
        self.assertEqual(check_policy("abcdefgh"), "WEAK")

    def test_common_password(self):
        self.assertEqual(check_policy("password"), "WEAK")

    def test_compliant_password(self):
        self.assertEqual(check_policy("Hello123!"), "COMPLIANT")


class TestValidateLine(unittest.TestCase):

    def test_valide_email(self):
        self.assertTrue(validate_line("john@doe.com:testete"))

    def test_invalid_email(self):
        self.assertFalse(validate_line("john-doe.fr:testete"))

    def test_missing_line(self):
        self.assertFalse(validate_line(":testete"))
        self.assertFalse(validate_line("john@doe.com:"))


class TestHashPassword(unittest.TestCase):

    def test_same_input_same_hash(self):
        password = "Hello123!"
        salt = "BreachCheckSalt"

        hash1 = hash_password(password, salt)
        hash2 = hash_password(password, salt)

        self.assertEqual(hash1, hash2)


if __name__ == "__main__":
    unittest.main()
