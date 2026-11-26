import faker
import psycopg2
import random

fake = faker.Faker('en_NG')  # This makes names Nigerian

def get_connection():
    conn = psycopg2.connect(
    host="localhost",
    database="telecom_recharge_db",
    user="postgres",
    password="post1059"
)
    return conn


def generate_nigerian_phone(network):
    # Real Nigerian prefixes per network
    prefixes = {
        'MTN': ['0803', '0806', '0810', '0813', '0814', '0816', '0903', '0906'],
        'Airtel': ['0802', '0808', '0812', '0902', '0907', '0912'],
        'Glo': ['0805', '0807', '0811', '0815', '0905', '0915'],
        '9mobile': ['0809', '0817', '0818', '0909', '0908']
    }
    prefix = random.choice(prefixes[network])
    # 7 more digits to make it 11 digits total, e.g. 0803 + 1234567
    rest = ''.join([str(random.randint(0, 9)) for _ in range(7)])
    return prefix + rest

conn = get_connection()
cursor = conn.cursor()
print("Connected successfully, generating Nigerian data...")


for i in range(100000):
    network_provider = random.choice(['MTN', 'Airtel', 'Glo', '9mobile'])
    phone = generate_nigerian_phone(network_provider)
    name = fake.name()
    email = fake.email()
    amount = random.choice([100, 200, 500, 1000, 2000, 5000])
    status = random.choice(['Success', 'Success', 'Success', 'Success', 'Success', 'Success', 'Success', 'Success', 'Failed', 'Pending'])
    recharge_date = fake.date_time_between(start_date='-1y', end_date='now')

    cursor.execute(
        "INSERT INTO recharge_transactions (name, email, phone_number, network_provider, recharge_amount, status, recharge_date) VALUES (%s, %s, %s, %s, %s, %s, %s)",
        (name, email, phone, network_provider, amount, status, recharge_date)
    )

    if i % 10000 == 0:
        print(f"Done {i}...")

conn.commit()
print("Done! 100000 Nigerian records generated.")
cursor.close()
conn.close()