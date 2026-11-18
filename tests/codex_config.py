"""Check profile linking and actual shell argument routing without starting agents."""
import os
import subprocess
import tempfile
from pathlib import Path
repo = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix="dotfiles-codex-") as scratch:
    home = Path(scratch)/"home"
    config = home/".codex/config.toml"
    env = dict(os.environ, DOTFILES_TARGET_HOME=str(home), DOTFILES_CONFIG_HOME=str(home/".config"))
    def link(*args):
        subprocess.run([str(repo/"scripts/link.sh"), *args], env=env, check=True, capture_output=True)
    link("--dry-run")
    assert not home.exists()
    config.parent.mkdir(parents=True)
    private = 'model = "private-choice"\n[mcp_servers.local]\ncommand = "private-command"\n'
    config.write_text(private)
    link()
    link()
    assert config.read_text() == private, "Must never rewrite private Codex config"
    assert (config.parent/"dotfiles.config.toml").resolve() == repo/"codex/dotfiles.config.toml"
    bin_dir=Path(scratch)/"bin"
    bin_dir.mkdir()
    stub=bin_dir/"codex"
    stub.write_text('#!/bin/sh\nprintf "%s\\n" "$@"\n')
    stub.chmod(0o755)
    env["PATH"]=str(bin_dir)+":"+env["PATH"]
    for args, expected in [([], ["--profile", "dotfiles"]),
                           (["resume", "--all"], ["--profile", "dotfiles", "resume", "--all"]),
                           (["fork"], ["--profile", "dotfiles", "fork"]),
                           (["features", "list"], ["features", "list"]),
                           (["--version"], ["--version"]),
                           (["resume", "-p", "work"], ["resume", "-p", "work"]),
                           (["resume", "--profile=work"], ["resume", "--profile=work"])]:
        result=subprocess.run(["/bin/zsh", "-f", "-c", 'source "$1"; shift; codex "$@"',
                               "test", str(repo/"codex/shell.zsh"), *args],env=env,
                               capture_output=True,text=True,check=True)
        assert result.stdout.splitlines()==expected, (args,result.stdout)
print("Codex profile passed: symlink, dry-run, private config preservation, idempotence, shell routing, explicit profile")
