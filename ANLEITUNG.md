# Anleitung für den Audio-Text Synchronisierer

Hallo! Hier ist die Schritt-für-Schritt-Anleitung, um das Programm auf deinem Mac zum Laufen zu bringen.

## Vorbereitung (Nur beim ersten Mal)

1. **Terminal öffnen**:
   - Drücke `Command + Leertaste` (Spotlight Suche).
   - Tippe `Terminal` ein und drücke Enter.

2. **In den Ordner navigieren**:
   - Tippe `cd ` (mit einem Leerzeichen am Ende) in das Terminal.
   - Ziehe nun den Ordner, in dem sich diese Dateien befinden, direkt in das Terminal-Fenster. Der Pfad wird automatisch eingefügt.
   - Drücke Enter.

3. **Installation starten**:
   - Kopiere folgenden Befehl und füge ihn ins Terminal ein:
     ```bash
     bash setup_mac.sh
     ```
   - Drücke Enter.
   - **Wichtig**: Das Skript fragt eventuell nach deinem Passwort (für die Installation von Homebrew/Tools). Tippe es ein (man sieht dabei keine Zeichen) und drücke Enter.
   - Warte, bis "Installation abgeschlossen!" erscheint.

---

## HILFE: Warnung "Nicht verifizierter Entwickler" / "Malware"

Falls beim Starten eine Meldung kommt wie **"kann nicht geöffnet werden, da der Entwickler nicht verifiziert ist"** (das ist normal, da ich kein Apple-Zertifikat habe):

1. Mache einen **Rechtsklick** auf die Datei (`Starten.command` oder `setup_mac.sh`).
2. Wähle im Menü **"Öffnen"**.
3. Es erscheint wieder ein Fenster, aber diesmal gibt es einen **"Öffnen"**-Button. Klicke darauf.
4. Das musst du nur **einmal** machen.

---

## Programm starten

Wenn die Installation einmal durchgelaufen ist, ist es ganz einfach:

1. Suche im Ordner die Datei **`Starten.command`**.
2. Mache einfach einen **Doppelklick** darauf.
3. Es öffnet sich automatisch ein schwarzes Fenster (Terminal) und kurz danach dein Browser mit dem Programm.

---

## Benutzung

1. **Dateien vorbereiten**:
   - Du brauchst deine MP3-Datei.
   - Du brauchst eine Textdatei (`.txt`).
   - **WICHTIG**: In der Textdatei muss jede Zeile genau einer Aya (einem Vers) entsprechen. Keine leeren Zeilen dazwischen lassen, wenn möglich.

2. **Hochladen**:
   - Ziehe die MP3-Datei in das Feld "Wähle die MP3-Datei".
   - Ziehe die Text-Datei in das Feld "Wähle die Text-Datei".

3. **Starten**:
   - Überprüfe kurz die Vorschau, ob die Anzahl der Zeilen stimmt.
   - Klicke auf "Synchronisation starten".

4. **Herunterladen**:
   - Wenn alles fertig ist, erscheint ein Button "JSON herunterladen". Klicke darauf.

Viel Erfolg!
