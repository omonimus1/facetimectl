# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## 0.1.0 - 2026-02-08

### Added
- Initial release of facetimectl
- `call` command to initiate FaceTime video/audio calls
- `contacts` command to list and search contacts
- `status` command to check authorization and call status
- `end` command to terminate active calls
- `authorize` command to request Contacts permissions
- Support for calling by phone number, email, or contact name
- JSON, plain text, and quiet output formats
- macOS Contacts integration via CNContactStore
- FaceTime URL scheme integration for call initiation
- AppleScript support for call status monitoring
- Automatic permission handling for Contacts access
- Info.plist with required usage descriptions
