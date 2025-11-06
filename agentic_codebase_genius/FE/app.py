import streamlit as st
import requests
import os
import time
import json
from pathlib import Path
from dotenv import load_dotenv

# ----------------------------------------------------------------------
# 1. Load env (OPENAI_API_KEY is needed only for the backend)
# ----------------------------------------------------------------------
load_dotenv()

# ----------------------------------------------------------------------
# 2. Config
# ----------------------------------------------------------------------
JAC_SERVER = os.getenv("JAC_SERVER", "http://localhost:8000")
WALKER_ENDPOINT = f"{JAC_SERVER}/walker_spawn"
DOWNLOAD_ENDPOINT = f"{JAC_SERVER}/download_file"   # optional, we will use file system

st.set_page_config(page_title="Codebase Genius", layout="wide")
st.title("Codebase Genius – AI-Powered Documentation")

# ----------------------------------------------------------------------
# 3. UI – URL input + button
# ----------------------------------------------------------------------
with st.form(key="repo_form"):
    repo_url = st.text_input(
        "Public GitHub repository URL",
        placeholder="https://github.com/psf/requests"
    )
    submit = st.form_submit_button("Generate Documentation")

# ----------------------------------------------------------------------
# 4. Helper: call Jac walker
# ----------------------------------------------------------------------
def spawn_supervisor(url: str):
    payload = {
        "name": "supervisor",
        "ctx": {"repo_url": url}
    }
    resp = requests.post(WALKER_ENDPOINT, json=payload, timeout=600)
    return resp.json()

# ----------------------------------------------------------------------
# 5. Main logic
# ----------------------------------------------------------------------
if submit:
    if not repo_url.startswith("http"):
        st.error("Please enter a valid URL")
    else:
        with st.spinner("Starting the agent pipeline…"):
            try:
                result = spawn_supervisor(repo_url)
            except Exception as e:
                st.error(f"Backend error: {e}")
                st.stop()

        # --------------------------------------------------------------
        # 5a. Show raw walker response (debug)
        # --------------------------------------------------------------
        st.subheader("Supervisor report")
        st.json(result, expanded=False)

        # --------------------------------------------------------------
        # 5b. Extract path to generated markdown
        # --------------------------------------------------------------
        if result.get("status") == "Documentation generated":
            doc_path = result.get("path")
            if not doc_path:
                st.error("Supervisor did not return a file path.")
                st.stop()
        else:
            st.error("Pipeline failed – see report above.")
            st.stop()

        # --------------------------------------------------------------
        # 5c. Wait for file to appear (backend writes async)
        # --------------------------------------------------------------
        local_path = Path(doc_path)
        placeholder = st.empty()
        with placeholder.container():
            for _ in range(30):          # max 30 s
                if local_path.exists():
                    break
                time.sleep(1)
                st.write("Waiting for file to be written…")

        if not local_path.exists():
            st.error("Timed-out waiting for docs.md")
            st.stop()

        # --------------------------------------------------------------
        # 5d. Render markdown (PlantUML works if you add a renderer)
        # --------------------------------------------------------------
        markdown = local_path.read_text(encoding="utf-8")
        st.subheader("Generated Documentation")
        st.markdown(markdown, unsafe_allow_html=True)

        # --------------------------------------------------------------
        # 5e. Download button
        # --------------------------------------------------------------
        st.download_button(
            label="Download docs.md",
            data=markdown,
            file_name=local_path.name,
            mime="text/markdown"
        )

        # --------------------------------------------------------------
        # 5f. Optional: Show PlantUML diagrams nicely
        # --------------------------------------------------------------
        if "```plantuml" in markdown:
            st.info("PlantUML diagrams detected – you can render them with any online viewer (e.g. plantuml.com).")