#!/usr/bin/env python3
"""
# Docker Installer for Debian Linux

## Description
Automated Docker installation script that:
- Checks for existing Docker installations
- Installs Docker using official repositories
- Handles service activation
- Provides robust error handling

## Features
✅ Pre-installation checks  
✅ Official Docker installation method  
✅ Automatic service activation  
✅ Non-root user configuration  
✅ Comprehensive error handling  
✅ Version/status verification  

## Requirements
- Debian-based Linux (Tested on Debian 11/12)
- Python 3.6+
- sudo privileges
- Internet access

## Usage
```bash
chmod +x install_docker.py
sudo ./install_docker.py
"""

import subprocess
import sys

def run_command(cmd, critical=False):
    try:
        result = subprocess.run(cmd, shell=True, check=True,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                              text=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        error_msg = e.stderr.strip()
        print(f"\n[WARNING] Command failed (non-critical): {cmd}")
        print(f"Details: {error_msg or 'No error message'}")
        if critical:
            print("\n[ERROR] Critical installation step failed")
            sys.exit(1)
        return None

def check_docker():
    """Returns (is_installed, is_active)"""
    version = run_command("docker --version 2>/dev/null")
    if not version:
        return (False, False)
    status = run_command("systemctl is-active docker 2>/dev/null")
    return (True, status == "active")

def install_docker():
    print("\n[INSTALL] Starting Docker installation (skipping repo errors)...")
    
    # Mark which commands are critical for installation
    installation_steps = [
        # Non-critical (can fail)
        ("sudo apt-get update", False),
        ("sudo apt-get install -y ca-certificates curl", True),
        ("sudo install -m 0755 -d /etc/apt/keyrings", True),
        ("sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc", True),
        ("sudo chmod a+r /etc/apt/keyrings/docker.asc", True),
        ('echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null', True),
        # Non-critical (can fail)
        ("sudo apt-get update", False),
        # Critical installation
        ("sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin", True),
        # Post-install
        ("sudo systemctl enable --now docker", True),
        ("sudo usermod -aG docker $USER", False),
        # Verification
        ("sudo docker run --rm hello-world", False)
    ]
    
    for cmd, is_critical in installation_steps:
        run_command(cmd, critical=is_critical)
    
    # Final verification
    if not run_command("docker --version"):
        print("\n[ERROR] Docker installation verification failed")
        sys.exit(1)

def main():
    print("\n=== Docker Installer ===")
    
    is_installed, is_active = check_docker()
    
    if is_installed:
        print(f"\n[INFO] Docker found: {run_command('docker --version')}")
        print(f"[STATUS] Service is: {'active' if is_active else 'inactive'}")
        if not is_active and input("\nActivate Docker service? (y/n): ").lower() == 'y':
            run_command("sudo systemctl enable --now docker", critical=True)
        return
    
    print("\n[INFO] Docker not found - starting installation...")
    install_docker()
    print("\n[SUCCESS] Docker installed successfully!")
    print(f"Version: {run_command('docker --version')}")
    print(f"Status: {run_command('systemctl is-active docker')}")
    print("Note: You may need to logout/login or run 'newgrp docker'")

if __name__ == "__main__":
    main()
