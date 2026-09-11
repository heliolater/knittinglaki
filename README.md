# Knittinglaki

Rundenzähler fürs Stricken und Häkeln.

Lege Projekte an (Socken, Schal, …) und zähle Runden mit `+` / `−` / `Reset`.
Jedes Projekt startet mit einem Zähler; weitere lassen sich beliebig ergänzen.
Zähler haben keinen Titel – sie werden über ihre Position unterschieden. Alles
wird **lokal** und persistent gespeichert – kein Account, kein Server.

## Stack

| Bereich | Wahl |
|---|---|
| Framework | Flutter (Ziele: web, android, ios) |
| State | Riverpod (`flutter_riverpod`) |
| Persistenz | Drift (SQLite; Web via `sqlite3.wasm` + Worker → IndexedDB/OPFS) |
| Routing | `go_router` |
| Bildschirm wach | `wakelock_plus` |
| Auslieferung v1 | Web-App / PWA, gehostet auf Cloudflare Pages |
| App-/Bundle-ID | `com.kaltenbeck.knittinglaki` |
| Design | Claude-Design-Projekt „Knittinglaki Zähler-UI" (Turn 1 verbindlich) – Tokens in `lib/core/app_colors.dart`, Schrift DM Sans (`assets/fonts/`) |

Native Android/iOS-Builds sind aus derselben Codebasis möglich; das
Home-Screen-Widget kommt mit der nativen Android-Phase.

## Entwicklung

```bash
flutter pub get
dart run build_runner build      # erzeugt lib/data/database.g.dart
flutter run -d chrome            # Web / PWA
flutter run -d <android-device>  # Android (Haptik + Wakelock spürbar)
```

Nach Änderungen an `lib/data/tables.dart` oder `database.dart` erneut
`dart run build_runner build` ausführen.

### Tests & Analyse

```bash
flutter analyze
flutter test
```

## Web-Assets für Drift

`web/sqlite3.wasm` und `web/drift_worker.js` stammen aus dem
[drift-Release](https://github.com/simolus3/drift/releases) und müssen zur
`drift`-Version in `pubspec.yaml` passen. Bei einem Drift-Upgrade beide Dateien
aus dem passenden Release neu herunterladen.

## Deployment (Cloudflare Pages)

Automatisch bei Push auf `main` über
`.github/workflows/deploy.yml` (baut Web-Release, deployt via Wrangler).

Einmalige Einrichtung:

1. Cloudflare-Pages-Projekt anlegen (Dashboard → Workers & Pages → Create →
   Pages → *Direct Upload*), Projektname **`knittinglaki`**.
2. Cloudflare API-Token erstellen (Berechtigung *Account · Cloudflare Pages ·
   Edit*) und Account-ID kopieren.
3. In den GitHub-Repo-Secrets hinterlegen:
   - `CLOUDFLARE_API_TOKEN`
   - `CLOUDFLARE_ACCOUNT_ID`

Manuell deployen:

```bash
flutter build web --release
npx wrangler pages deploy build/web --project-name=knittinglaki
```

## Nicht in v1

- Home-Screen-Widget mit `+` / `−` (nur nativ möglich → spätere Android-Phase)
- iOS-Native-Build (braucht Mac + Apple Developer Program, 99 $/Jahr)
- Reset-Bestätigung / Undo, Zähler-Zielwert
- Accounts, Cloud-Sync, Analytics
