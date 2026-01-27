import streamlit as st
import os
import tempfile
import json
import shutil
import sys

# Try to import aeneas, if not available (development env), we might mock it later or handle error
aeneas_error = None
try:
    from aeneas.executetask import ExecuteTask
    from aeneas.task import Task
    from aeneas.language import Language
except ImportError as e:
    # This block allows the app to load in dev environment without aeneas installed
    # The actual execution would fail unless mocked, but UI works.
    aeneas_error = e

def process_files(audio_file, text_file):
    """
    Process the uploaded files using Aeneas to generate timestamps.
    Returns a list of dictionaries representing the JSON structure.
    """

    # Create a temporary directory to store files
    with tempfile.TemporaryDirectory() as temp_dir:
        # Save audio file
        audio_path = os.path.join(temp_dir, "input.mp3")
        with open(audio_path, "wb") as f:
            f.write(audio_file.read())

        # Save text file
        text_path = os.path.join(temp_dir, "input.txt")
        # Ensure we read text as string
        text_content = text_file.read().decode("utf-8")

        # Filter empty lines and normalize text
        lines = [line.strip() for line in text_content.splitlines() if line.strip()]
        clean_text = "\n".join(lines)

        with open(text_path, "w", encoding="utf-8") as f:
            f.write(clean_text)

        # Configure Aeneas Task
        # We need to construct the configuration string
        # is_text_type=plain means it reads line by line
        config_string = u"task_language=de|is_text_type=plain|os_task_file_format=json"

        try:
            task = Task(config_string=config_string)
            task.audio_file_path_absolute = audio_path
            task.text_file_path_absolute = text_path
            task.sync_map_file_path_absolute = os.path.join(temp_dir, "output.json")

            ExecuteTask(task).execute()
        except NameError:
             # Fallback for development/sandbox where ExecuteTask is not imported
             if aeneas_error:
                 st.error(f"Die Aeneas Bibliothek konnte nicht geladen werden.")
                 st.error(f"Details: {aeneas_error}")
                 st.info("Bitte führe 'setup_mac.sh' erneut aus und sende den Output, falls Fehler auftreten.")
             else:
                 st.error("Aeneas library is not installed in this environment.")
             return []
        except Exception as e:
            st.error(f"Fehler bei der Synchronisation: {e}")
            return []

        # Parse the output
        # Aeneas output structure (sync map)
        json_output = []

        # We can iterate over fragments directly from the task object
        current_index = 1
        for fragment in task.sync_map_leaves():
            # fragment.begin and fragment.end are strings/floats
            # fragment.text is the text

            # Filter out empty text segments (often head/tail silence)
            if not fragment.text or not fragment.text.strip():
                continue

            entry = {
                "index": current_index,
                "start": float(fragment.begin),
                "end": float(fragment.end),
                "text": fragment.text
            }
            json_output.append(entry)
            current_index += 1

        return json_output

# Title and introduction
st.set_page_config(page_title="Audio zu Text Synchronisierer", layout="centered")
st.title("Audio & Text Synchronisierer (Aya zu Aya)")
st.write("Lade deine MP3-Datei und die zugehörige Textdatei hoch. Das Programm erstellt eine JSON-Datei mit Zeitstempeln.")

# Sidebar instructions
st.sidebar.header("Anleitung")
st.sidebar.markdown("""
1. Lade die **MP3-Datei** hoch.
2. Lade die **Text-Datei** hoch.
   - **Wichtig:** Jede Zeile in der Textdatei muss genau einer Aya entsprechen.
3. Klicke auf "Synchronisation starten".
4. Lade die fertige JSON-Datei herunter.
""")

# File uploaders
uploaded_audio = st.file_uploader("Wähle die MP3-Datei", type=["mp3"])
uploaded_text = st.file_uploader("Wähle die Text-Datei (.txt)", type=["txt"])

if uploaded_audio and uploaded_text:
    st.info("Dateien bereit.")

    # Preview Text lines
    # We need to peek at the file without consuming it completely or reset pointer
    # But Streamlit UploadedFile is seekable.
    string_data = uploaded_text.getvalue().decode("utf-8")
    lines = [l for l in string_data.splitlines() if l.strip()]
    st.write(f"Erkannte Zeilen (Ayas): **{len(lines)}**")

    with st.expander("Vorschau der ersten 5 Zeilen"):
        for l in lines[:5]:
            st.text(l)

    if st.button("Synchronisation starten"):
        with st.spinner("Arbeite... Dies kann einen Moment dauern..."):
            # Reset file pointers before passing to function
            uploaded_audio.seek(0)
            uploaded_text.seek(0)

            result_json = process_files(uploaded_audio, uploaded_text)

            if result_json:
                st.success("Fertig! Du kannst die Datei jetzt herunterladen.")

                # Convert to formatted JSON string
                json_str = json.dumps(result_json, indent=4, ensure_ascii=False)

                st.download_button(
                    label="JSON herunterladen",
                    data=json_str,
                    file_name="aya_timestamps.json",
                    mime="application/json"
                )
