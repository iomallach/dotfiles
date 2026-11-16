#!/usr/bin/env python3
"""Render inherited widgets against a small offline host, not native AppKit."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import tomllib


ROOT = Path(__file__).resolve().parents[1]
PROFILE = ROOT / "shell/noctalia"
SHELL = Path(os.environ.get("OMNIWM_SHELL_DIR", Path.home() / ".config/omniwm/shell"))


def main() -> None:
    luau = shutil.which("luau")
    if luau is None:
        raise SystemExit("luau is required; see shell/noctalia/README.md for the pinned Nix command")

    subprocess.run([sys.executable, str(ROOT / "tests/bridge.py")], check=True)

    config = tomllib.loads((PROFILE / "shell.toml").read_text())
    manifest = tomllib.loads((PROFILE / "style.toml").read_text())
    theme = tomllib.loads((PROFILE / "themes/macchiato.toml").read_text())
    names = config["leading"] + config["center"] + config["trailing"]
    assert len(names) == len(set(names)), "A widget must not appear in multiple lanes"
    assert config["center"] == ["active-window"]
    assert names == ["workspaces", "media", "active-window", "agents", "control-center", "bluetooth", "weather"]
    assert config["trailing"] == ["agents", "control-center", "bluetooth", "weather"]
    assert config["widgets"]["workspaces"]["compact"] is False
    assert config["widgets"]["media"]["interval"] == 1
    assert config["widgets"]["bluetooth"]["interval"] == 15
    assert config["workspaceBar"]["showLabels"] is True
    assert config["workspaceBar"]["transparentBackground"] is True
    assert config["workspaceBar"]["showItemBackgrounds"] is True
    assert config["workspaceBar"]["reserveLayoutSpace"] is False
    assert manifest["name"] == PROFILE.name and manifest["api"] == 1
    assert theme["light"] == theme["dark"], "The Macchiato style stays dark in either appearance"
    print("ok - profile metadata, unique native-widget layout, and dark palette", flush=True)

    # OmniShell resolves shared libraries in user / profile / default order.
    libraries: dict[str, Path] = {}
    for folder in [SHELL / "lib", PROFILE / "lib", SHELL / "default/lib"]:
        for path in folder.glob("*.luau"):
            libraries.setdefault(path.stem, path)
    if "skin" not in libraries:
        raise SystemExit(f"Missing installed OmniWM libraries under {SHELL / 'default/lib'}")
    if libraries["look"] != PROFILE / "lib/look.luau":
        raise SystemExit("A top-level lib/look.luau overrides this profile; remove it before testing")

    chunks = [(ROOT / "tests/widgets.luau").read_text()]
    for name, path in sorted(libraries.items()):
        chunks.append(f"loaders[{json.dumps('lib/' + name)}] = function(require, ui, omniwm)\n{path.read_text()}\nend\n")

    def widget_source(name: str) -> str:
        candidates = [folder / f"widgets/{name}/init.luau" for folder in [SHELL, PROFILE, SHELL / "default"]]
        path = next((candidate for candidate in candidates if candidate.is_file()), None)
        if path is None:
            raise SystemExit(f"Missing widget source: {name}")
        return "local render, popout, spanIslands, trigger, interval\n" + path.read_text() + "\nreturn { render = render, popout = popout, trigger = trigger }"

    def module(name: str, source: str) -> None:
        chunks.append(f"loaders[{json.dumps(name)}] = function(require, ui, omniwm)\n{source}\nend\n")

    for name in names:
        module("widgets/" + name, widget_source(name))
    for name in ["workspaces", "media", "active-window", "weather", "notifications", "bluetooth", "volume",
                 "battery-details", "control-center", "clock", "agents"]:
        if name == "weather":
            source = 'return require("../lib/weather-widget")'
        elif name in ["workspaces", "media", "active-window", "agents"]:
            source = widget_source(name)
        else:
            adapter = "noctalia-native-" + name
            if adapter not in libraries:
                raise SystemExit(f"Missing {adapter}; install the Home Manager native-adapter links first")
            source = f'return require("../lib/{adapter}")'
        module("units/" + name, source)
    chunks.append("runTests()\n")
    with tempfile.TemporaryDirectory(prefix="omnishell-noctalia-tests-") as directory:
        bundle = Path(directory) / "widgets.luau"
        bundle.write_text("\n".join(chunks))
        subprocess.run([luau, str(bundle)], check=True)


if __name__ == "__main__":
    main()
