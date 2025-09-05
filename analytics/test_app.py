from flask import Flask

app = Flask(__name__)

@app.route("/health_check")
def health_check():
    return "ok"

if __name__ == "__main__":
    print("Starting Flask on 127.0.0.1:5153")
    app.run(host="127.0.0.1", port=5153, debug=True)