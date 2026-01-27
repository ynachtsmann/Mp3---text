import unittest
from unittest.mock import MagicMock
import sys
import io

# 1. Mock Aeneas modules BEFORE importing app
sys.modules['aeneas'] = MagicMock()
sys.modules['aeneas.executetask'] = MagicMock()
sys.modules['aeneas.task'] = MagicMock()
sys.modules['aeneas.language'] = MagicMock()

# 2. Mock Streamlit
mock_st = MagicMock()
sys.modules['streamlit'] = mock_st

# Critical: Make file_uploader return None by default so the script top-level logic doesn't run process_files immediately
mock_st.file_uploader.return_value = None

# 3. Now import the app
import app

class TestAppLogic(unittest.TestCase):
    def test_process_files(self):
        # Mocking the file objects
        mock_audio = io.BytesIO(b"fake audio data")
        mock_text = io.BytesIO(b"Aya 1\nAya 2")

        # Setup the mocks for Aeneas Task instance
        mock_task_instance = MagicMock()

        # Mocking the sync_map_leaves to return fragments
        fragment1 = MagicMock()
        fragment1.begin = "0.000"
        fragment1.end = "2.500"
        fragment1.text = "Aya 1"

        fragment2 = MagicMock()
        fragment2.begin = "2.500"
        fragment2.end = "5.000"
        fragment2.text = "Aya 2"

        mock_task_instance.sync_map_leaves.return_value = [fragment1, fragment2]

        # Configure the Task class mock to return our instance
        app.Task.return_value = mock_task_instance

        # Call the function directly
        result = app.process_files(mock_audio, mock_text)

        # Verify the configuration string
        args, kwargs = app.Task.call_args
        config_used = kwargs.get('config_string')
        self.assertIn("task_adjust_boundary_algorithm=percent", config_used)
        self.assertIn("task_adjust_boundary_percent_value=50", config_used)
        self.assertIn("is_audio_file_head_length=0", config_used)
        self.assertIn("is_audio_file_tail_length=0", config_used)

        # Verify the result
        self.assertEqual(len(result), 2)
        self.assertEqual(result[0]['text'], "Aya 1")
        self.assertEqual(result[0]['start'], 0.0)
        self.assertEqual(result[0]['end'], 2.5)
        self.assertEqual(result[1]['index'], 2)

        print("\nTest passed: Logic correctly processes mock Aeneas output into JSON structure.")

if __name__ == '__main__':
    unittest.main()
