#!/bin/bash
cd "$(dirname "$0")"

# Check if venv exists
if [ ! -d "venv" ]; then
    echo "---------------------------------------------------------------"
    echo "ACHTUNG: Die Installation wurde noch nicht durchgeführt!"
    echo "---------------------------------------------------------------"
    echo "Bitte führe erst die Datei 'setup_mac.sh' aus."
    echo "Dazu öffne das Terminal, ziehe 'setup_mac.sh' hinein und drücke Enter"
    echo "(oder befolge die Anleitung)."
    echo ""
    read -p "Drücke ENTER um dieses Fenster zu schließen..."
    exit 1
fi

source venv/bin/activate

# Check if aeneas is importable
python3 -c "import aeneas" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "---------------------------------------------------------------"
    echo "FEHLER: 'aeneas' konnte nicht geladen werden!"
    echo "---------------------------------------------------------------"
    echo "Möglicherweise gab es einen Fehler bei der Installation."
    echo "Versuche, 'setup_mac.sh' erneut auszuführen."
    echo "Der genaue Fehler wird beim Import-Versuch angezeigt:"
    echo ""
    python3 -c "import aeneas"
    echo ""
    read -p "Drücke ENTER um das Fenster zu schließen..."
    exit 1
fi

# Check if streamlit is installed
if ! command -v streamlit &> /dev/null
then
    echo "---------------------------------------------------------------"
    echo "FEHLER: Das Programm ist nicht vollständig installiert!"
    echo "---------------------------------------------------------------"
    echo "Es scheint, als wäre die Installation (setup_mac.sh) fehlgeschlagen."
    echo "Bitte führe setup_mac.sh noch einmal aus und achte auf rote Fehler."
    echo ""
    read -p "Drücke ENTER um das Fenster zu schließen..."
    exit 1
fi

streamlit run app.py
echo ""
echo "Das Programm wurde beendet."
read -p "Drücke ENTER um das Fenster zu schließen..."
