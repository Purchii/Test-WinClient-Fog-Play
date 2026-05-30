# Privacy and logging checks

Check that logs/artifacts do not contain:

- access tokens;
- refresh tokens;
- passwords;
- full session tokens;
- real user identifiers;
- production secrets;
- sensitive backend URLs if classified as secret;
- unmasked SDP/TURN/ICE credentials if present in diagnostics.
