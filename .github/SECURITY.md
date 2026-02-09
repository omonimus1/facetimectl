# Security Policy

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security of facetimectl seriously. If you believe you have found a security vulnerability, please report it to us responsibly.

### Please DO NOT:

- Open a public GitHub issue for security vulnerabilities
- Disclose the vulnerability publicly before it has been addressed

### Instead, please:

1. **Email** the maintainer privately (check the GitHub profile for contact info)
2. **Include** detailed information about the vulnerability:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)
3. **Allow** reasonable time for us to respond and address the issue

### What to Expect:

- **Acknowledgment**: We will acknowledge receipt of your report within 48 hours
- **Communication**: We will keep you informed about the progress of addressing the issue
- **Credit**: We will credit you in the security advisory (unless you prefer to remain anonymous)
- **Timeline**: We aim to address critical vulnerabilities within 7 days

## Security Best Practices

### For Users:

1. **Keep Updated**: Always use the latest version of facetimectl
   ```bash
   brew update
   brew upgrade facetimectl
   ```

2. **Verify Installation**: Only install from official sources
   ```bash
   brew tap omonimus1/facetimectl
   brew install facetimectl
   ```

3. **Permissions**: facetimectl requires Contacts access. Review permissions in System Settings > Privacy & Security > Contacts

4. **Source Code**: facetimectl is open source. Review the code if you have concerns

### For Contributors:

1. **No Secrets**: Never commit sensitive information (API keys, tokens, passwords)
2. **Dependencies**: Keep dependencies up to date (managed by Dependabot)
3. **Code Review**: All changes go through code review
4. **Testing**: Write tests for security-critical code

## Known Security Considerations

### Contacts Access
- facetimectl requires access to macOS Contacts to function
- This permission is requested through the standard macOS permission dialog
- Users can revoke access at any time in System Settings
- No contact data is transmitted or stored outside the local system

### FaceTime Integration
- facetimectl uses the standard macOS FaceTime URL scheme (`facetime://`)
- No credentials or authentication tokens are handled by facetimectl
- All FaceTime authentication is handled by macOS

### AppleScript
- facetimectl uses AppleScript to check call status
- Scripts are embedded in the application, not loaded externally
- No arbitrary script execution from user input

## Security Updates

Security updates will be released as soon as possible and announced:

1. GitHub Security Advisories
2. Release notes in CHANGELOG.md
3. GitHub Releases page

Users will be encouraged to update immediately via:
```bash
brew update && brew upgrade facetimectl
```

## macOS Security Features

facetimectl is built with macOS security in mind:

- **Sandboxing**: Compatible with macOS security restrictions
- **Code Signing**: Future releases will include code signing
- **Notarization**: Future releases will be notarized by Apple
- **TCC (Transparency, Consent, and Control)**: Properly requests Contacts access

## Additional Resources

- [Apple Platform Security Guide](https://support.apple.com/guide/security/welcome/web)
- [Swift Security Best Practices](https://swift.org/documentation/security/)
- [macOS Privacy Features](https://www.apple.com/privacy/)

## Contact

For security concerns, please reach out through:
- GitHub: [@omonimus1](https://github.com/omonimus1)
- Security issues: Use private reporting (not public issues)

Thank you for helping keep facetimectl and its users safe!
