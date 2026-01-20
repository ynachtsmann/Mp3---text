#!/bin/bash

# Farben für die Ausgabe
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starte Installation für 'Audio to Text Aya Sync'...${NC}"

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
    echo -e "\033[0;31mFehler bei der Installation der Pakete.\033[0m"
    echo "Versuche espeak manuell zu verlinken..."
    # Fallback attempt specifically for aeneas compilation issues
    pip install aeneas --global-option=build_ext --global-option="-I$BREW_PREFIX/include" --global-option="-L$BREW_PREFIX/lib"
fi

# 7. Make Start Script Executable
echo -e "${GREEN}Setze Rechte für Start-Skript...${NC}"
chmod +x Starten.command

echo -e "${GREEN}Installation abgeschlossen!${NC}"
echo "Du kannst das Programm nun mit einem Doppelklick auf 'Starten.command' starten."
