from flask import Flask, render_template
import os
import sys

app = Flask(__name__)

@app.route("/")
def home():
    env = os.getenv("APP_ENV", "local").capitalize()
    return render_template("index.html", env=env)

@app.route("/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    # Priority 1: APP_PORT environment variable
    port = int(os.getenv("APP_PORT", "0"))

    # Priority 2: --port argument
    if port == 0 and "--port" in sys.argv:
        try:
            port = int(sys.argv[sys.argv.index("--port") + 1])
        except Exception:
            port = 5000

    # Priority 3: fallback
    if port == 0:
        port = 5000

    app.run(host="0.0.0.0", port=port)
