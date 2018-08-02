import unittest
import os

from unit_converters import UnitConverterModeler

class UnitConverterModelerTests(unittest.TestCase):
    """Tests unit converter code generation.
    """

    @classmethod
    def setUp(self):
        """Sets up the output location to current path.
        """
        test_folder = 'unit_conv_tests'
        self.outpath = os.path.join(os.getcwd(), test_folder)

        self.conv = UnitConverterModeler()


    def test_write_unit_converters(self):
        """Tests if the unit converters get written.
        """
        self.conv.write_unit_converters()


    def test_write_unit_converter_validators(self):
        """Tests if the unit converters get written.
        """
        self.conv.write_unit_converter_validators()