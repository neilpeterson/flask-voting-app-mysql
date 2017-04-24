from flask import Flask, request, render_template
from flask.ext.mysqldb import MySQL
import random
import sys

app = Flask(__name__)

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = ''
app.config['MYSQL_DB'] = 'azurevote'
mysql = MySQL(app)

@app.route('/', methods=['GET', 'POST'])
def index():

    cats = 0
    dogs = 0

    if request.method == 'GET':

        # Get current values
        cur = mysql.connection.cursor()
        cur.execute('''Select votevalue, count(votevalue) as count From azurevote.azurevote
        group by votevalue''')
        results = cur.fetchall()

        for i in results:
            if i[0] == 'cats':
                cats = i[1]
            elif i[0] == 'dogs':
                dogs = i[1]              

        # Return index with values
        return render_template("index.html", cats=cats, dogs=dogs)

    elif request.method == 'POST':

        if request.form['vote'] == 'reset':
            cur = mysql.connection.cursor()
            cur.execute('''Delete FROM azurevote''')
            mysql.connection.commit()

            # Return inndex with new count
            return render_template("index.html", cats=cats, dogs=dogs)
        else:
            # Insert vote result into DB
            vote = request.form['vote']
            cur = mysql.connection.cursor()
            cur.execute('''INSERT INTO azurevote (voteid, votevalue) VALUES (%s, %s)''', (random.randint(5,3000), vote))
            mysql.connection.commit()

            # Get current values
            cur.execute('''Select votevalue, count(votevalue) as count From azurevote.azurevote
            group by votevalue''')
            results = cur.fetchall()

            for i in results:
                if i[0] == 'cats':
                    cats = i[1]
                elif i[0] == 'dogs':
                    dogs = i[1]
                
            # Return inndex with new count
            return render_template("index.html", cats=cats, dogs=dogs)

@app.route('/results')
def results():
    cur = mysql.connection.cursor()
    cur.execute('''Select * FROM azurevote''')
    rv = cur.fetchall()
    return str(rv)

if __name__ == "__main__":
    app.run(debug=True)