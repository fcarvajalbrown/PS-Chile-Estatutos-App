# Estatutos PS Chile — app de curso y lectura

App Android (Flutter) para estudiar los **Estatutos Nacionales del Partido
Socialista de Chile**: un modo **Leer** (por Título y Artículo) y un modo
**Curso** tipo quiz. Paleta del Partido Socialista (rojo / negro / blanco) y un
retrato vectorial original de Salvador Allende.

El contenido de lectura es **textual**, extraído del sitio oficial
https://www.pschile.cl/estatutos/ (versión actualizada 2026-05-19) y guardado en
`source/`. El quiz está construido sobre ese mismo texto, con referencia al
artículo que respalda cada respuesta.

## Estructura

```
source/        texto oficial (HTML + texto limpio)  -> verificar contra pschile.cl
tools/         parse_estatutos.ps1: genera el asset de contenido desde el texto
app/           proyecto Flutter
```

## Requisitos

- Android Studio + Android SDK (ya instalados en esta máquina).
- **Flutter SDK** (falta instalarlo).

### 1. Instalar Flutter SDK (Windows)

1. Descarga el SDK desde https://docs.flutter.dev/get-started/install/windows
   (o `git clone https://github.com/flutter/flutter.git -b stable`).
2. Descomprímelo en, por ejemplo, `C:\src\flutter`.
3. Agrega `C:\src\flutter\bin` al PATH del usuario.
4. Verifica e instala dependencias:
   ```powershell
   flutter doctor
   flutter doctor --android-licenses   # aceptar licencias del SDK
   ```
   Si `flutter doctor` no encuentra el SDK de Android, apúntalo:
   ```powershell
   flutter config --android-sdk "$env:LOCALAPPDATA\Android\Sdk"
   ```

### 2. Generar el scaffolding nativo (android/)

Este repo trae `lib/`, `assets/` y `pubspec.yaml`, pero **no** las carpetas
nativas (`android/`, etc.), que genera Flutter. Como `flutter create` puede
sobrescribir `pubspec.yaml`, el script `tools/scaffold.ps1` crea el esqueleto en
una carpeta temporal y copia solo lo que falta, sin tocar tu código:

```powershell
powershell -ExecutionPolicy Bypass -File tools\scaffold.ps1
```

(Alternativa manual: `flutter create --platforms=android --org cl.pschile .`
dentro de `app\`, y vuelve a aplicar las dependencias de `pubspec.yaml` si se
sobrescriben.)

### 3. Ejecutar

```powershell
cd app
flutter pub get
flutter run            # con un emulador o un teléfono conectado por USB
# o para un APK instalable:
flutter build apk --release
```

El APK queda en `app\build\app\outputs\flutter-apk\app-release.apk`.

## iOS (compilar en un Mac)

El repo incluye `app/ios/` (scaffolding nativo generado con
`tools/scaffold_ios.ps1`). Bundle ID: `cl.pschile.psEstatutos`; nombre visible
"Estatutos PS". Los archivos específicos de máquina (`Flutter/Generated.xcconfig`,
`Flutter/ephemeral/`, `GeneratedPluginRegistrant.*`, `Pods/`) están en
`.gitignore` y se regeneran solos. En el Mac:

```bash
cd app
flutter pub get
cd ios && pod install && cd ..
open ios/Runner.xcworkspace   # en Signing & Capabilities, elige tu Team/Apple ID
flutter run                   # con un simulador o un iPhone conectado
```

Las dependencias del proyecto (`shared_preferences`, `flutter_svg`,
`cupertino_icons`) ya soportan iOS; no hay código nativo propio que portar.
Para regenerar el scaffolding desde cero: `tools\scaffold_ios.ps1`.

## Regenerar el contenido de lectura

Si corriges el texto en `source/estatutos_clean.txt`:

```powershell
powershell -ExecutionPolicy Bypass -File tools\parse_estatutos.ps1
```

## Notas

- App 100% offline: todo el contenido viaja dentro del APK.
- El retrato de Allende es una ilustración vectorial original (sin foto con
  derechos de autor), dibujada en código en `lib/widgets/allende_portrait.dart`.
