from flask import Flask,request,jsonify
from flask_sqlalchemy import SQLAlchemy
import os, time

DB_IP=os.getenv('db_ip', '10.0.0.11')
DB_USERNAME=os.getenv('db_username', 'db_user')
DB_NAME=os.getenv('db_name', 'halanapp')
DB_USERPASS=os.getenv('db_userpass', 'db_pass')
DB_PORT=os.getenv('db_port', 5432)

app=Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://{username}:{passwd}@{host_ip}:{db_port}/{db_name}'.format(
    username=DB_USERNAME, passwd=DB_USERPASS, host_ip=DB_IP, db_name=DB_NAME, db_port=DB_PORT
)
# app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:////tmp/test.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS']=False
db=SQLAlchemy(app)

class IP(db.Model):
    id = db.Column(db.Integer , primary_key=True)
    ip_address = db.Column(db.String, nullable=False)

while True:
    try:
        db.create_all()
        break
    except:
        print('failed to connect to db \ntrying again in 5s')
        print('connection string:{}'.format(app.config['SQLALCHEMY_DATABASE_URI']))
        time.sleep(5)

@app.route('/')
def index():
    for i in request.args:
        try:
            i=float(i)
            return 'n*n = {}'.format(i*i)
        except:
            pass
    return 'Halan ROCKS'

@app.route('/ip')
def store_ip():
    try:
        ip= IP(ip_address=request.remote_addr)
        db.session.add(ip)
        db.session.commit()
        return 'your ip address is: {}'.format(request.remote_addr)
    except Exception as e:
        db.session.rollback()
        return str(e)

@app.route('/allips')
def get_ips():
    return jsonify({
        'ips':[ip.ip_address for ip in IP.query.all()]
    })

if __name__ == "__main__":
    app.run(port=5000, debug=True, host='0.0.0.0')