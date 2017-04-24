from flask import Flask, request, render_template
#from flask.ext.mysqldb import MySQL
#from flask_mysql import MySQL
from flaskext.mysql import MySQL
import random
import sys

app = Flask(__name__)

mysql = MySQL()
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = ''
app.config['MYSQL_DATABASE_DB'] = 'azurevote'
mysql.init_app(app)
connection = mysql.connect()
cursor = connection.cursor()

@app.route('/', methods=['GET', 'POST'])
def index():

    cats = 0
    dogs = 0

    if request.method == 'GET':       
        cursor.execute('''Select votevalue, count(votevalue) as count From azurevote.azurevote
        group by votevalue''')
        results = cursor.fetchall()

        for i in results:
            if i[0] == 'cats':
                cats = i[1]
            elif i[0] == 'dogs':
                dogs = i[1]              

        # Return index with values
        return render_template("index.html", cats=cats, dogs=dogs)

    elif request.method == 'POST':

        if request.form['vote'] == 'reset':
            cursor.execute('''Delete FROM azurevote''')
            connection.commit()

            # Return inndex with new count
            return render_template("index.html", cats=cats, dogs=dogs)
        else:
            # Insert vote result into DB
            vote = request.form['vote']
            cursor.execute('''INSERT INTO azurevote (voteid, votevalue) VALUES (%s, %s)''', (random.randint(5,3000), vote))

            # Get current values
            cursor.execute('''Select votevalue, count(votevalue) as count From azurevote.azurevote
            group by votevalue''')
            results = cursor.fetchall()

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
    cursor.execute('''Select * FROM azurevote''')
    rv = cursor.fetchall()
    return str(rv)

if __name__ == "__main__":
    app.run(debug=True)