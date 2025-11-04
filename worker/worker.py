import os
import time
import redis
import psycopg2
import json

r = redis.Redis(host=os.environ.get("REDIS_HOST", "redis"), db=0)
conn = psycopg2.connect(
    host=os.environ.get("PGHOST", "database"),
    user=os.environ.get("PGUSER", "user"),
    password=os.environ.get("PGPASSWORD", "password"),
    dbname=os.environ.get("PGDATABASE", "webapp")
)

print("Worker started, waiting for votes...")

while True:
    try:
        _, vote = r.blpop("votes")  # Blocking pop
        vote = vote.decode("utf-8")
        print(f"Processing vote: {vote}")
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO votes (id, vote, created_at) VALUES (%s, %s, NOW())",
            (os.urandom(8).hex(), vote)
        )
        conn.commit()
        cur.close()
    except Exception as e:
        print("Error processing vote:", e)
        conn.rollback()
        time.sleep(1)
