#!/usr/bin/env python3
"""Test the one-shot publisher with private child-process fakes."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "bin/bluetooth-power.sh"


class BridgeTests(unittest.TestCase):
    def setUp(self) -> None:
        directory = tempfile.TemporaryDirectory(prefix="omniwm battery bridge ")
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        self.capture = self.root / "arguments.json"
        self.ctl = self.command("fake ctl", """
import json, os, sys
from pathlib import Path
Path(os.environ['CAPTURE']).write_text(json.dumps(sys.argv[1:]))
sys.exit(int(os.environ.get('CTL_EXIT', '0')))
""")
        self.power = self.command("fake power", """
import os, sys
assert sys.argv[1:] == ['-g', 'accps']
print(os.environ.get('POWER_REPORT', ''))
sys.exit(int(os.environ.get('POWER_EXIT', '0')))
""")

    def command(self, name: str, source: str) -> Path:
        path = self.root / name
        path.write_text(f"#!{sys.executable}\n{source}")
        path.chmod(0o755)
        return path

    def run_bridge(self, **values: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["/bin/sh", str(SCRIPT), str(self.ctl), str(self.power)],
            env={**os.environ, "CAPTURE": str(self.capture), **values},
            text=True,
            capture_output=True,
            check=False,
        )

    def test_report_is_one_literal_timestamped_ipc_argument(self) -> None:
        sentinel = self.root / "must-not-exist"
        report = f"Now drawing from 'AC Power'\n -Keyboard; touch {sentinel} (id=1) 45%;"
        result = self.run_bridge(POWER_REPORT=report)
        self.assertEqual(result.returncode, 0, result.stderr)
        arguments = json.loads(self.capture.read_text())
        self.assertEqual(arguments[:3], ["shell", "set", "noctalia_bluetooth_power"])
        self.assertEqual(len(arguments), 4)
        timestamp, actual = arguments[3].split("\n", 1)
        self.assertLess(abs(time.time() - int(timestamp)), 10)
        self.assertEqual(actual, report)
        self.assertFalse(sentinel.exists())

    def test_failed_collection_clears_old_runtime_data(self) -> None:
        result = self.run_bridge(POWER_EXIT="1", POWER_REPORT="partial report")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(self.capture.read_text()), ["shell", "unset", "noctalia_bluetooth_power"])

    def test_ipc_failure_is_reported_for_the_next_scheduled_retry(self) -> None:
        result = self.run_bridge(CTL_EXIT="7")
        self.assertEqual(result.returncode, 7)


if __name__ == "__main__":
    unittest.main()
