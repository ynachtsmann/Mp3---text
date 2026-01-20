#!/bin/bash

# Ensure we are in the correct directory
cd "$(dirname "$0")"

# Farben für die Ausgabe
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starte Installation für 'Audio to Text Aya Sync'...${NC}"
echo "Arbeitsverzeichnis: $(pwd)"

# === SOFORT-FIX: ENTFERNE MALWARE-WARNUNG VORAB ===
if [ -f "Starten.command" ]; then
    echo "Entferne Apple Sicherheits-Warnung von 'Starten.command'..."
    xattr -d com.apple.quarantine Starten.command 2>/dev/null || true
fi
# ==================================================

# Helper function for error handling
check_error() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}FEHLER: $1${NC}"
        echo "Die Installation wurde abgebrochen."
        echo "Bitte mache einen Screenshot von diesem Fenster und sende ihn mir."
        read -p "Drücke ENTER um das Fenster zu schließen..."
        exit 1
    fi
}

# Check if requirements.txt exists here
if [ ! -f "requirements.txt" ]; then
    echo -e "${RED}FEHLER: Datei 'requirements.txt' nicht gefunden!${NC}"
    echo "Bitte stelle sicher, dass du den GANZEN Ordner heruntergeladen hast und nicht nur das Skript."
    read -p "Drücke ENTER..."
    exit 1
fi

# 1. Check Homebrew
if ! command -v brew &> /dev/null
then
    echo "Homebrew ist nicht installiert. Installiere Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    check_error "Homebrew Installation fehlgeschlagen."
else
    echo "Homebrew gefunden."
fi

# 2. Update Homebrew
echo "Update Homebrew..."
brew update

# 3. Install System Dependencies
echo -e "${GREEN}Installiere ffmpeg und espeak...${NC}"
brew install ffmpeg espeak
check_error "Installation von ffmpeg/espeak fehlgeschlagen."

# 4. Check for Python 3
if ! command -v python3 &> /dev/null
then
    echo "Python 3 nicht gefunden. Installiere Python..."
    brew install python
    check_error "Python Installation fehlgeschlagen."
fi

# 5. Create Virtual Environment
echo -e "${GREEN}Erstelle Python Umgebung (venv)...${NC}"
if [ ! -d "venv" ]; then
    python3 -m venv venv
    check_error "Konnte venv nicht erstellen."
fi

# 6. Activate venv and install packages
echo -e "${GREEN}Aktiviere Umgebung und installiere Pakete...${NC}"
source venv/bin/activate

# Upgrade pip and install build tools
echo "Installiere Build-Tools (pip, wheel, setuptools)..."
pip install --upgrade pip wheel setuptools
check_error "Installation der Build-Tools fehlgeschlagen."

# --- FIX FOR MAC (Apple Silicon & Intel) ---
# Aeneas braucht Hilfe, um die 'espeak' Header zu finden.
BREW_PREFIX=$(brew --prefix)
export CFLAGS="-I$BREW_PREFIX/include"
export LDFLAGS="-L$BREW_PREFIX/lib"
echo "Setze Compiler-Pfade auf: $BREW_PREFIX"
# -------------------------------------------

echo "Installiere Basis-Pakete (Streamlit, Numpy)..."
pip install -r requirements.txt
check_error "Installation der Basis-Pakete fehlgeschlagen."

echo -e "${GREEN}Installiere Aeneas (Audio-Engine)...${NC}"
# FIX 1: Umgebungsvariable AENEAS_WITH_CEW=False (deaktiviert problematische C-Erweiterung)
export AENEAS_WITH_CEW=False
# FIX 2: --no-build-isolation (nutzt installiertes Numpy)
pip install aeneas --no-build-isolation
check_error "Installation von Aeneas fehlgeschlagen."

# 7. Make Start Script Executable
echo -e "${GREEN}Setze Rechte für Start-Skript...${NC}"
if [ -f "Starten.command" ]; then
    chmod +x Starten.command
    # Noch einmal am Ende, falls die Datei neu erstellt wurde (hier nicht der Fall, aber sicher ist sicher)
    xattr -d com.apple.quarantine Starten.command 2>/dev/null || true
    xattr -d com.apple.quarantine app.py 2>/dev/null || true
else
    echo -e "${RED}WARNUNG: 'Starten.command' wurde nicht gefunden. Bitte lade den Ordner erneut herunter.${NC}"
fi

echo -e "${GREEN}Installation erfolgreich abgeschlossen!${NC}"
echo "--------------------------------------------------------"
echo "Du kannst das Programm nun mit einem Doppelklick auf 'Starten.command' starten."
echo "Falls sich Xcode öffnet: Rechtsklick -> Öffnen mit -> Terminal."
