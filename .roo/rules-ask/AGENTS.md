# Project Documentation Rules (Non-Obvious Only)
- The `AuthGate` in [`lib/auth_gate.dart`](lib/auth_gate.dart) is a central orchestrator for the multi-step user onboarding and authentication flow, not just a simple router.
- Data persistence is layered: `SharedPreferences` for flags, Firebase for auth/cloud, and Drift for local relational data.
- Custom asset paths like `images/backgrounds/` and `images/launcher/` are used.
- The `analysis_options.yaml` explicitly disables `avoid_print` and `prefer_single_quotes` lint rules.