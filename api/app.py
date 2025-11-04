from flask import Flask, request
from flask_cors import CORS
import os
import socket
import random
import json
import logging
import redis
import psycopg2
import sys

# Disable default Flask request logs
log = logging.getLogger('werkzeug')
log.setLevel(logging.ERROR)

# Environment Variables
option_a = os.getenv('OPTION_A', "Cats")
option_b = os.getenv('OPTION_B', "Dogs")

db_hostname = os.getenv('DB_HOST', 'postgres')
db_database = os.getenv('DB_NAME', 'webapp')
db_user = os.getenv('DB_USER', 'user')
db_password = os.getenv('DB_PASSWORD', 'password')

redis_host = os.getenv('REDIS_HOST', 'redis')
redis_port = int(os.getenv('REDIS_PORT', 6379))

hostname = socket.gethostname()

# Initialize Flask + Redis
app = Flask(__name__)
CORS(app)

r = redis.Redis(host=redis_host, port=redis_port, db=0)

print("🚀 Starting API service...")

# ------------------------
# Health Check
# ------------------------
@app.route("/health", methods=['GET'])
def health():
    return app.response_class(status=200)

# ------------------------
# Simple Hello Endpoint
# ------------------------
@app.route("/api", methods=['GET'])
def hello():
    return app.response_class(
        response="Hello, I am the API service",
        status=200
    )

# ------------------------
# Fetch Votes (from DB)
# ------------------------
@app.route("/api/vote", methods=['GET'])
def get_votes():
    print("Fetching votes from Postgres...")
    sys.stdout.flush()

    try:
        conn = psycopg2.connect(
            host=db_hostname,
            user=db_user,
            password=db_password,
            dbname=db_database
        )
        cur = conn.cursor()
        cur.execute("SELECT vote, COUNT(id) AS count FROM votes GROUP BY vote")
        res = cur.fetchall()
        cur.close()
        conn.close()

        # Convert query results to JSON
        data = {row[0]: row[1] for row in res}
        return app.response_class(
            response=json.dumps(data),
            status=200,
            mimetype='application/json'
        )

    except Exception as e:
        print("❌ Error fetching votes:", e)
        sys.stdout.flush()
        return app.response_class(
            response=json.dumps({"error": str(e)}),
            status=500,
            mimetype='application/json'
        )

# ------------------------
# Submit Vote (to Redis)
# ------------------------
@app.route("/api/vote", methods=['POST'])
def post_vote():
    voter_id = hex(random.getrandbits(64))[2:-1]

    if request.method == 'POST':
        try:
            vote = request.form['vote']
        except KeyError:
            return app.response_class(
                response=json.dumps({"error": "Missing vote parameter"}),
                status=400,
                mimetype='application/json'
            )

        data = {"voter_id": voter_id, "vote": vote}

        print(f"🗳️ Received vote '{vote}' from voter '{voter_id}'")
        sys.stdout.flush()

        try:
            # Push to Redis queue
            r.rpush("votes", json.dumps(data))
            return app.response_class(
                response=json.dumps(data),
                status=200,
                mimetype='application/json'
            )
        except Exception as e:
            print("❌ Failed to push vote to Redis:", e)
            sys.stdout.flush()
            return app.response_class(
                response=json.dumps({"error": str(e)}),
                status=500,
                mimetype='application/json'
            )
    else:
        return app.response_class(status=405)

# ------------------------
# Main Entry
# ------------------------
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080, debug=True, threaded=True)
