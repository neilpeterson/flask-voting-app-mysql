from flask import Flask, request, render_template
from flask.ext.mysqldb import MySQL
import random
import sys

app = Flask(__name__)

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Monkeyskip76'
app.config['MYSQL_DB'] = 'azurevote'
mysql = MySQL(app)

@app.route('/')
def index():
    return render_template("index.html")

@app.route('/insert', methods=['POST'])
def insert():
    vote = request.form['vote']
    cur = mysql.connection.cursor()
    cur.execute('''INSERT INTO azurevote (voteid, votevalue) VALUES (%s, %s)''', (random.randint(5,3000), vote))
    mysql.connection.commit()
    return render_template("index.html")

@app.route('/results')
def results():
    cur = mysql.connection.cursor()
    cur.execute('''Select * FROM azurevote''')
    rv = cur.fetchall()
    print(type(rv), file=sys.stderr)
    return str(rv)

if __name__ == "__main__":
    app.run(debug=True)