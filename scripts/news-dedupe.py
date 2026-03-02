#!/usr/bin/env python3
"""
X.com Monitor Deduplication Helper
Tracks posted URLs to prevent duplicates
"""

import json
import os
import sys
from datetime import datetime

DATA_DIR = os.path.expanduser("~/clawd/data/x-monitor")
POSTED_FILE = os.path.join(DATA_DIR, "posted.json")
METADATA_FILE = os.path.join(DATA_DIR, "metadata.json")

def init_storage():
    """Initialize storage files if they don't exist"""
    os.makedirs(DATA_DIR, exist_ok=True)
    if not os.path.exists(POSTED_FILE):
        with open(POSTED_FILE, 'w') as f:
            json.dump([], f)
    if not os.path.exists(METADATA_FILE):
        with open(METADATA_FILE, 'w') as f:
            json.dump({"count": 0, "last_run": None}, f)

def load_posted():
    """Load list of already-posted URLs"""
    try:
        with open(POSTED_FILE) as f:
            return json.load(f)
    except:
        return []

def save_posted(urls):
    """Save updated list of posted URLs (keep last 200)"""
    # Keep only last 200 URLs to prevent file bloat
    urls = urls[-200:]
    with open(POSTED_FILE, 'w') as f:
        json.dump(urls, f, indent=2)

def is_duplicate(url):
    """Check if URL was already posted"""
    posted = load_posted()
    # Normalize URL (remove trailing slashes, etc)
    normalized = url.rstrip('/').lower()
    for posted_url in posted:
        if posted_url.rstrip('/').lower() == normalized:
            return True
    return False

def mark_posted(url):
    """Mark URL as posted"""
    posted = load_posted()
    if url not in posted:
        posted.append(url)
        save_posted(posted)
        return True
    return False

def get_stats():
    """Get deduplication stats"""
    posted = load_posted()
    return {
        "total_tracked": len(posted),
        "file_path": POSTED_FILE
    }

if __name__ == "__main__":
    init_storage()
    
    if len(sys.argv) < 2:
        print("Usage: x-dedupe.py <command> [url]")
        print("Commands: check <url>, mark <url>, stats")
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == "check" and len(sys.argv) >= 3:
        url = sys.argv[2]
        if is_duplicate(url):
            print(f"DUPLICATE: {url}")
            sys.exit(0)
        else:
            print(f"NEW: {url}")
            sys.exit(1)
    
    elif command == "mark" and len(sys.argv) >= 3:
        url = sys.argv[2]
        if mark_posted(url):
            print(f"MARKED: {url}")
        else:
            print(f"ALREADY_EXISTS: {url}")
    
    elif command == "stats":
        stats = get_stats()
        print(f"Tracked URLs: {stats['total_tracked']}")
        print(f"Storage: {stats['file_path']}")
    
    else:
        print(f"Unknown command: {command}")