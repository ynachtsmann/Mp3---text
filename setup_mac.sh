#!/bin/bash

# Ensure we are in the correct directory
cd "$(dirname "$0")"

# Farben für die Ausgabe
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starte Installation für 'Audio to Text Aya Sync'...${NC}"
echo "Arbeitsverzeichnis: $(pwd)"

# Check if requirements.txt exists here
if [ ! -f "requirements.txt" ]; then
    echo -e "\033[0;31mFEHLER: Datei 'requirements.txt' nicht gefunden!\033[0m"
    echo "Bitte stelle sicher, dass du den GANZEN Ordner heruntergeladen hast und nicht nur das Skript."
    exit 1
fi

# 1. Check Homebrew
if ! command -v brew &> /dev/null
then
    echo "Homebrew ist nicht installiert. Installiere Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew gefunden."
fi

# 2. Update Homebrew
echo "Update Homebrew..."
brew update

# 3. Install System Dependencies
echo -e "${GREEN}Installiere ffmpeg und espeak...${NC}"
brew install ffmpeg espeak

# 4. Check for Python 3
if ! command -v python3 &> /dev/null
then
    echo "Python 3 nicht gefunden. Installiere Python..."
    brew install python
fi

# 5. Create Virtual Environment
echo -e "${GREEN}Erstelle Python Umgebung (venv)...${NC}"
if [ -d "venv" ]; then
    echo "venv existiert bereits."
else
    python3 -m venv venv
fi

# 6. Activate venv and install packages
echo -e "${GREEN}Installiere Python Pakete...${NC}"
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install numpy first (important for aeneas)
pip install "numpy<2"

# --- FIX FOR MAC (Apple Silicon & Intel) ---
# Aeneas braucht Hilfe, um die 'espeak' Header zu finden.
BREW_PREFIX=$(brew --prefix)
export CFLAGS="-I$BREW_PREFIX/include"
export LDFLAGS="-L$BREW_PREFIX/lib"
echo "Setze Compiler-Pfade auf: $BREW_PREFIX"
# -------------------------------------------

# Install other requirements
# Versuche Installation. Wenn es fehlschlägt, zeige Hilfe.
if pip install -r requirements.txt; then
    echo -e "${GREEN}Python Pakete erfolgreich installiert.${NC}"
else
    echo -e "\033[0;31mFehler bei der Installation der Pakete. Versuche Fallback...\033[0m"
    echo "Versuche espeak manuell zu verlinken..."
    # Fallback attempt specifically for aeneas compilation issues
    # Using CFLAGS/LDFLAGS env vars which is the modern way, dropping deprecated global-options
    pip install aeneas
fi

# 7. Make Start Script Executable & Fix Gatekeeper
echo -e "${GREEN}Setze Rechte für Start-Skript...${NC}"
if [ -f "Starten.command" ]; then
    chmod +x Starten.command
    # Entferne "Quarantine" Attribut (verhindert "Malware" Warnung)
    echo "Entferne Apple Sicherheits-Warnung von den Skripten..."
    xattr -d com.apple.quarantine Starten.command 2>/dev/null || true
    xattr -d com.apple.quarantine app.py 2>/dev/null || true
else
    echo -e "\033[0;31mWARNUNG: 'Starten.command' wurde nicht gefunden. Bitte lade den Ordner erneut herunter.\033[0m"
fi

echo -e "${GREEN}Installation abgeschlossen!${NC}"
echo "Du kannst das Programm nun mit einem Doppelklick auf 'Starten.command' starten."
echo "Falls sich Xcode öffnet: Rechtsklick -> Öffnen mit -> Terminal."
