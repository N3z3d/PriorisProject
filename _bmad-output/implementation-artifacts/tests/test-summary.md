# Story 6.1 Test Summary

Date: 2026-04-14
Scope: closeout `6.1` public pilot

## Automated validation

- `flutter gen-l10n`
- `flutter analyze --no-pub lib/core/config/app_config.dart lib/presentation/app/prioris_app.dart lib/presentation/pages/auth/components/login_header.dart lib/presentation/pages/home_page.dart lib/presentation/pages/home/widgets/desktop_sidebar.dart lib/presentation/pages/home/widgets/premium_bottom_nav.dart lib/presentation/pages/home/widgets/premium_nav_item.dart lib/presentation/pages/lists/widgets/lists_no_data_state.dart lib/presentation/widgets/pilot/pilot_instance_notice.dart test/core/config/app_config_test.dart test/presentation/pages/auth/components/login_header_test.dart test/presentation/pages/home_page_test.dart`
- `flutter test --no-pub test/core/config/app_config_test.dart test/presentation/pages/auth/components/login_header_test.dart test/presentation/pages/home_page_test.dart`
- `flutter build web --no-pub --release --base-href=/PriorisProject/ --dart-define=PRIORIS_APP_VERSION=pilot-pages-local`

## Result

- Analyze: green
- Tests: green (`8` tests passed)
- Build web GitHub Pages target: green

## Public pilot evidence

- Public URL verified reachable on 2026-04-13: `https://n3z3d.github.io/PriorisProject/`
- Desktop capture: `pilot_pages_desktop.png`
- Mobile capture: `pilot_pages_mobile.png`
- Console capture: `pilot_pages_console.txt`

## Residual step

- The updated code still requires a manual rerun of the GitHub workflow `Deploy Pilot Web to GitHub Pages` to publish this exact build on the public URL.
