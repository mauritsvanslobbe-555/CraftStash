# CraftStash - Stappenplan: Van code naar App Store

---

## FASE 1: Code naar GitHub pushen

### Stap 1.1 — Maak een nieuwe repository op GitHub
1. Ga naar **github.com** en log in
2. Klik rechtsboven op het **+** icoon → **New repository**
3. Vul in:
   - **Repository name:** `CraftStash`
   - **Description:** `iOS app om knutselideeën te bewaren vanuit social media`
   - **Visibility:** Private (aangeraden, je code is dan niet openbaar)
   - **GEEN** README, .gitignore of license aanvinken (die hebben we al)
4. Klik op **Create repository**
5. Je ziet nu een pagina met instructies — die gaan we in de volgende stap gebruiken

### Stap 1.2 — Code uploaden naar GitHub
Open een terminal (of Git Bash op Windows) en voer deze commando's **één voor één** uit:

```bash
cd "C:\Users\mauri\OneDrive\Bureaublad\Claude App\CraftStash"

git init

git add .

git commit -m "Initial commit: CraftStash iOS app met Share Extension"

git branch -M main

git remote add origin https://github.com/JOUW-GEBRUIKERSNAAM/CraftStash.git

git push -u origin main
```

⚠️ **Belangrijk:** Vervang `JOUW-GEBRUIKERSNAAM` door je echte GitHub gebruikersnaam!

Als je om inloggegevens wordt gevraagd:
- **Username:** je GitHub gebruikersnaam
- **Password:** je moet een **Personal Access Token** gebruiken (niet je wachtwoord!)
  - Ga naar GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
  - Klik **Generate new token (classic)**
  - Geef het een naam, vink **repo** aan, klik **Generate token**
  - Kopieer de token en plak deze als wachtwoord

### Stap 1.3 — Controleer of het gelukt is
1. Ga naar `github.com/JOUW-GEBRUIKERSNAAM/CraftStash`
2. Je zou al je bestanden moeten zien (CraftStash map, codemagic.yaml, project.yml, etc.)

---

## FASE 2: Codemagic instellen

### Stap 2.1 — Repository koppelen
1. Ga naar **codemagic.io** en log in
2. Klik op **Add application** (of **+ New application**)
3. Kies **GitHub** als provider
4. Als je Codemagic voor het eerst koppelt aan GitHub:
   - Klik **Connect GitHub**
   - Geef Codemagic toestemming om je repositories te lezen
5. Selecteer de **CraftStash** repository
6. Kies **iOS App** als project type
7. Klik op **Finish: Add application**

### Stap 2.2 — Eerste testbuild (zonder signing)
Dit is de snelste manier om te checken of alles compileert:

1. In Codemagic, open je **CraftStash** project
2. Klik op **Start new build**
3. Selecteer **workflow:** `ios-test` (CraftStash iOS Test)
4. Selecteer **branch:** `main`
5. Klik **Start new build**

De build zal:
- XcodeGen installeren
- Het Xcode project genereren
- De app bouwen voor de iOS Simulator (zonder signing)

⏱️ Dit duurt ongeveer 5-10 minuten. Als de build **groen** wordt, werkt je code!

---

## FASE 3: Apple Developer & Code Signing instellen

### Stap 3.1 — App ID aanmaken in Apple Developer
1. Ga naar **developer.apple.com** → **Account** → **Certificates, Identifiers & Profiles**
2. Klik links op **Identifiers** → klik op het **+** icoon
3. Kies **App IDs** → **Continue**
4. Kies **App** → **Continue**
5. Vul in:
   - **Description:** `CraftStash`
   - **Bundle ID:** kies **Explicit** en vul in: `com.craftstash.app`
6. Scroll naar beneden bij **Capabilities** en vink aan:
   - **App Groups**
7. Klik **Continue** → **Register**

### Stap 3.2 — App Group aanmaken
1. Ga terug naar **Identifiers**
2. Klik op het **+** icoon
3. Kies **App Groups** → **Continue**
4. Vul in:
   - **Description:** `CraftStash Shared`
   - **Identifier:** `group.com.craftstash.shared`
5. Klik **Continue** → **Register**

### Stap 3.3 — App Group koppelen aan App ID
1. Ga naar **Identifiers** → klik op **com.craftstash.app**
2. Scroll naar **App Groups** → klik **Configure**
3. Vink **group.com.craftstash.shared** aan
4. Klik **Continue** → **Save**

### Stap 3.4 — Share Extension App ID aanmaken
1. Ga naar **Identifiers** → klik op het **+** icoon
2. Kies **App IDs** → **App** → **Continue**
3. Vul in:
   - **Description:** `CraftStash Share Extension`
   - **Bundle ID:** Explicit → `com.craftstash.app.share-extension`
4. Vink **App Groups** aan bij Capabilities
5. Klik **Continue** → **Register**
6. Open de net aangemaakte identifier → **App Groups** → **Configure**
7. Vink **group.com.craftstash.shared** aan → **Continue** → **Save**

### Stap 3.5 — Code Signing in Codemagic instellen
1. Ga naar **Codemagic** → open je **CraftStash** project
2. Ga naar **Settings** (tandwiel icoon)
3. Scroll naar **Code signing - iOS**
4. Kies **Automatic** code signing
5. Vul in:
   - **Apple ID:** je Apple Developer email
   - **App-specific password:** (maak er een aan op appleid.apple.com → Sign-In and Security → App-Specific Passwords)
   - **Team ID:** je team ID (vind je op developer.apple.com → Membership)
6. Of gebruik **Manual** signing:
   - Upload je **.p8 key** (die heb je al: `AuthKey_JZGL7RK96Y.p8`)
   - **Key ID:** `JZGL7RK96Y`
   - **Issuer ID:** vind je in App Store Connect → Users and Access → Integrations → App Store Connect API

---

## FASE 4: Echte build met signing

### Stap 4.1 — Build starten
1. In Codemagic, klik op **Start new build**
2. Selecteer **workflow:** `ios-build` (CraftStash iOS Build)
3. Selecteer **branch:** `main`
4. Klik **Start new build**

Als alles goed gaat krijg je een **.ipa** bestand dat je kunt installeren!

---

## FASE 5: Testen op een echte iPhone

### Optie A: Via Codemagic (makkelijkst)
1. Na een succesvolle build, download de **.ipa** vanuit Codemagic
2. Codemagic kan deze automatisch naar **TestFlight** uploaden als je dat instelt

### Optie B: Via TestFlight
1. Ga naar **App Store Connect** (appstoreconnect.apple.com)
2. Klik op **My Apps** → **+** → **New App**
3. Vul in:
   - **Name:** CraftStash
   - **Primary Language:** Dutch
   - **Bundle ID:** com.craftstash.app
   - **SKU:** craftstash-001
4. Klik **Create**
5. In Codemagic, voeg bij **Publishing** → **App Store Connect** toe:
   - Dit zorgt dat elke succesvolle build automatisch naar TestFlight gaat
6. Open **TestFlight** op je iPhone en installeer de app!

---

## FASE 6: App Store publicatie

### Stap 6.1 — App Store listing voorbereiden
In **App Store Connect** → je app → **App Information**:
1. **Screenshots** — maak screenshots van de app op iPhone (minimaal 3)
2. **Description** — beschrijving van de app
3. **Keywords** — bijv: knutselen, kinderen, creatief, DIY, bewaren
4. **Category** — Lifestyle of Entertainment
5. **Age Rating** — vul de vragenlijst in (waarschijnlijk 4+)
6. **Privacy Policy URL** — je hebt een privacy policy nodig (kan een simpele webpagina zijn)

### Stap 6.2 — App icon
Je hebt een 1024x1024 app icon nodig. Ideeën:
- Een schaar met een hart
- Knutselmateriaal in een doosje
- Kleurrijke creatieve uitstraling

### Stap 6.3 — Submit voor review
1. Zorg dat je build in TestFlight staat en getest is
2. Ga naar **App Store Connect** → je app → **Prepare for Submission**
3. Selecteer de build
4. Vul alle vereiste velden in
5. Klik **Submit for Review**

⏱️ Apple review duurt meestal 1-3 dagen.

---

## Samenvatting van de volgorde

| # | Wat | Waar | Duur |
|---|-----|------|------|
| 1 | Repo aanmaken + code pushen | GitHub | 5 min |
| 2 | Repo koppelen + testbuild | Codemagic | 10 min |
| 3 | App IDs + App Group aanmaken | Apple Developer | 10 min |
| 4 | Code signing instellen | Codemagic | 10 min |
| 5 | Echte build draaien | Codemagic | 10 min |
| 6 | TestFlight testen | App Store Connect | 15 min |
| 7 | App Store submit | App Store Connect | 1-3 dagen review |

---

## Hulp nodig?

- **Build faalt?** Check de logs in Codemagic voor de foutmelding
- **Signing problemen?** Controleer of je Bundle IDs exact overeenkomen
- **App Group werkt niet?** Zorg dat beide App IDs (app + extension) dezelfde App Group hebben
