import logging
from apscheduler.schedulers.background import BackgroundScheduler
from datetime import datetime, timedelta
from flask import jsonify
from sqlalchemy import and_, text
from random import randint
from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy

from analytics.config import SQLALCHEMY_DATABASE_URI

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = SQLALCHEMY_DATABASE_URI
db = SQLAlchemy(app)
app.logger.setLevel(logging.DEBUG)

from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
from analytics.config import SQLALCHEMY_DATABASE_URI

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = SQLALCHEMY_DATABASE_URI
db = SQLAlchemy(app)


import os
port_number = int(os.environ.get("APP_PORT", 5153))


@app.route("/health_check")
def health_check():
    return "ok"


@app.route("/readiness_check")
def readiness_check():
    try:
        db.session.execute(text("SELECT 1")).scalar()
        return "ok", 200
    except Exception as e:
        app.logger.error(f"Readiness probe failed: {e}")
        return "failed", 500


def get_daily_visits():
    with app.app_context():
        result = db.session.execute(text("""
        SELECT Date(created_at) AS date,
            Count(*)         AS visits
        FROM   tokens
        WHERE  used_at IS NOT NULL
        GROUP  BY Date(created_at)
        """))

        response = {}
        for row in result:
            response[str(row[0])] = row[1]

        app.logger.info(response)

    return response


@app.route("/api/reports/daily_usage", methods=["GET"])
def daily_visits():
    try:
        return jsonify(get_daily_visits())
    except Exception as e:
        app.logger.error(f"Error in daily_visits: {e}", exc_info=True)
        return {"error": str(e)}, 500




@app.route("/api/reports/user_visits", methods=["GET"])
def all_user_visits():
    result = db.session.execute(text("""
    SELECT t.user_id,
        t.visits,
        users.joined_at
    FROM   (SELECT tokens.user_id,
                Count(*) AS visits
            FROM   tokens
            GROUP  BY user_id) AS t
        LEFT JOIN users
                ON t.user_id = users.id;
    """))

    response = {}
    for row in result:
        response[row[0]] = {
            "visits": row[1],
            "joined_at": str(row[2])
        }
    
    return jsonify(response)


scheduler = BackgroundScheduler()
job = scheduler.add_job(get_daily_visits, 'interval', seconds=30)
scheduler.start()


@app.route("/routes")
def list_routes():
    routes = [str(rule) for rule in app.url_map.iter_rules()]
    return jsonify(routes)

@app.route("/db_test")
def db_test():
    try:
        result = db.session.execute(text("SELECT 1")).scalar()
        return jsonify({"db_status": "ok", "result": result})
    except Exception as e:
        app.logger.error(f"DB connection failed: {e}", exc_info=True)
        return jsonify({"db_status": "failed", "error": str(e)}), 500

@app.route("/hello")
def hello():
    return "Hello, world!"


if __name__ == "__main__":

    logging.basicConfig(level=logging.INFO)
    print(f"Starting Flask on 0.0.0.0:{port_number} via Waitress")

    print("Registered routes:")
    for rule in app.url_map.iter_rules():
        print(rule)

    import waitress
    waitress.serve(app, host="0.0.0.0", port=port_number)
