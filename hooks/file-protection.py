#!/usr/bin/env python3
"""
File Protection Hook - Protege archivos sensibles de lectura/escritura
Bloquea acceso a archivos de configuración, secretos y credenciales
Enterprise Edition v2.0
"""

import json
import sys
import os
import fnmatch

# Patrones de archivos protegidos (glob patterns)
PROTECTED_PATTERNS = [
    # Environment files
    ".env",
    ".env.*",
    ".env.local",
    ".env.production",
    ".env.development",
    "*.env",

    # AWS credentials
    ".aws/credentials",
    ".aws/config",

    # SSH keys
    ".ssh/id_*",
    ".ssh/known_hosts",
    "*_rsa",
    "*_ed25519",
    "*.pem",
    "*.key",

    # Secrets directories (exact patterns, not recursive wildcards)
    "secrets/*.json",
    "secrets/*.yaml",
    "secrets/*.yml",
    ".secrets/*.json",
    ".secrets/*.yaml",

    # Git credentials
    ".git-credentials",

    # NPM tokens
    ".npmrc",

    # Docker secrets
    ".docker/config.json",

    # Kubernetes secrets (specific files, not wildcards)
    "k8s/secrets/*.yaml",
    "k8s/secrets/*.yml",
    "kubernetes/secrets/*.yaml",
    "kubernetes/secrets/*.yml",

    # Terraform state (contains secrets)
    "*.tfstate",
    "*.tfstate.backup",
    "terraform.tfvars",
    "*.auto.tfvars",

    # Database configs with passwords
    "credentials.json",
    "service-account.json",
    "gcp-credentials.json",
    "firebase-adminsdk*.json",

    # API keys files
    "api-keys.json",
    "api-keys.yaml",
    ".api-keys",
]

# Paths that are always blocked (exact match)
BLOCKED_PATHS = [
    "/etc/passwd",
    "/etc/shadow",
    "/etc/sudoers",
    "~/.bash_history",
    "~/.zsh_history",
]

# Paths to ALLOW even if they might match patterns
ALLOWED_PATHS = [
    ".claude/settings.json",
    ".claude/agents/",
    ".claude/skills/",
    ".claude/hooks/",
    ".claude/commands/",
    ".claude/templates/",
    ".claude/teams/",
]


def normalize_path(path: str) -> str:
    """Normalize path for comparison"""
    path = os.path.expanduser(path)
    if path.startswith("./"):
        path = path[2:]
    return path


def is_allowed(file_path: str) -> bool:
    """Check if file is in allowed list"""
    normalized = normalize_path(file_path)
    for allowed in ALLOWED_PATHS:
        allowed_normalized = normalize_path(allowed)
        if normalized.endswith(allowed_normalized) or allowed_normalized in normalized:
            return True
    return False


def is_protected(file_path: str) -> tuple[bool, str]:
    """Check if file matches any protected pattern"""
    normalized = normalize_path(file_path)
    
    # First check if explicitly allowed
    if is_allowed(file_path):
        return False, "Explicitly allowed"

    # Check exact blocked paths
    for blocked in BLOCKED_PATHS:
        blocked_normalized = normalize_path(blocked)
        if normalized == blocked_normalized or normalized.endswith(blocked_normalized):
            return True, f"Exact match: {blocked}"

    # Check glob patterns
    for pattern in PROTECTED_PATTERNS:
        pattern_normalized = normalize_path(pattern)

        # Direct pattern match on full path
        if fnmatch.fnmatch(normalized, pattern_normalized):
            return True, f"Pattern match: {pattern}"
        
        # Direct pattern match on full path with wildcard prefix
        if fnmatch.fnmatch(normalized, f"*/{pattern_normalized}"):
            return True, f"Pattern match: {pattern}"

        # Check if pattern matches basename only for simple patterns
        if "/" not in pattern and fnmatch.fnmatch(os.path.basename(normalized), pattern_normalized):
            return True, f"Basename pattern match: {pattern}"

    return False, ""


def main():
    try:
        input_data = sys.stdin.read()

        if not input_data.strip():
            sys.exit(0)

        data = json.loads(input_data)

        tool_input = data.get("tool_input", {})
        file_path = tool_input.get("file_path", "")

        if not file_path:
            sys.exit(0)

        is_blocked, reason = is_protected(file_path)

        if is_blocked:
            print(f"BLOCKED: Access to protected file denied", file=sys.stderr)
            print(f"File: {file_path}", file=sys.stderr)
            print(f"Reason: {reason}", file=sys.stderr)
            sys.exit(2)

        sys.exit(0)

    except json.JSONDecodeError as e:
        print(f"Warning: Could not parse JSON input: {e}", file=sys.stderr)
        sys.exit(0)
    except Exception as e:
        print(f"Error in file-protection hook: {e}", file=sys.stderr)
        sys.exit(0)


if __name__ == "__main__":
    main()
