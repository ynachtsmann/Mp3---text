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
streamlit run app.py
echo ""
echo "Das Programm wurde beendet."
read -p "Drücke ENTER um das Fenster zu schließen..."
