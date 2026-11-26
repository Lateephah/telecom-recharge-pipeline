import psycopg2
import random
from datetime import datetime, timedelta

# 1. Connect to DB
conn = psycopg2.connect(
    host="localhost",
    database="telecom_recharge_db", 
    user="postgres",
    password="post1059"
)
cur = conn.cursor()

# 2. Get REAL phone numbers from recharge_transactions
cur.execute("SELECT DISTINCT phone_number, network_provider FROM recharge_transactions")
customers = cur.fetchall()
print(f"Found {len(customers)} real customers")

# 3. Clear old fake CDR data
cur.execute("TRUNCATE TABLE cdr_records RESTART IDENTITY")

# 4. Generate 1000 real CDR records
call_types = ["Voice", "Voice", "Voice", "SMS", "Data"]  # mostly Voice
statuses = ["Completed", "Completed", "Completed", "Failed", "Busy"]

for i in range(100000):
    caller, network = random.choice(customers)
    # Receiver is a different real customer
    receiver, _ = random.choice(customers)
    while receiver == caller:
        receiver, _ = random.choice(customers)

    call_type = random.choice(call_types)
    
    if call_type == "Voice":
        duration = random.randint(30, 1200)  # 30 sec to 20 min
        cost = round(duration * 0.5, 2)  # 0.50 naira per second
    elif call_type == "SMS":
        duration = 0
        cost = 4.00
    else:  # Data
        duration = random.randint(60, 3600)
        cost = round(random.uniform(50, 500), 2)

    call_start = datetime.now() - timedelta(days=random.randint(0, 30), hours=random.randint(0, 23))
    status = random.choice(statuses)

    cur.execute("""
        INSERT INTO cdr_records (caller_number, receiver_number, network_provider, call_type, call_duration_seconds, call_start_time, call_cost, call_status)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    """, (caller, receiver, network, call_type, duration, call_start, cost, status))

conn.commit()
print("Done! Generated 1000 CDR records from real customers")
cur.close()
conn.close()