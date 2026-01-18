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

# Install other requirements
pip install -r requirements.txt

# 7. Create Start Script
echo -e "${GREEN}Erstelle Start-Skript...${NC}"
cat <<EOF > start_app.sh
#!/bin/bash
cd "\$(dirname "\$0")"
source venv/bin/activate
streamlit run app.py
EOF

chmod +x start_app.sh

echo -e "${GREEN}Installation abgeschlossen!${NC}"
echo "Du kannst das Programm nun mit einem Doppelklick auf 'start_app.sh' starten."
