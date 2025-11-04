from flask import Flask, jsonify
import psycopg2, os

app = Flask(__name__)

db_host = os.getenv('PGHOST', 'database')
db_name = os.getenv('PGDATABASE', 'webapp')
db_user = os.getenv('PGUSER', 'user')
db_password = os.getenv('PGPASSWORD', 'password')

@app.route("/")
def get_results():
    try:
        conn = psycopg2.connect(
            host=db_host,
            user=db_user,
            password=db_password,
            dbname=db_name
        )
        cur = conn.cursor()
        cur.execute("SELECT vote, COUNT(id) AS count FROM votes GROUP BY vote")
        res = cur.fetchall()
        cur.close()
        conn.close()
        return jsonify({r[0]: r[1] for r in res})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)