from flask import Flask, request, render_template
from flaskext.mysql import MySQL
import random
import socket
import sys

app = Flask(__name__)

# Load configurations
app.config.from_pyfile('config_file.cfg')
button1 =       app.config['VOTE1VALUE']  
button2 =       app.config['VOTE2VALUE']
title =         app.config['TITLE']

# MySQL configurations
app.config['MYSQL_DATABASE_USER']
app.config['MYSQL_DATABASE_PASSWORD']
app.config['MYSQL_DATABASE_DB']
app.config['MYSQL_DATABASE_HOST']

# MySQL Object
mysql = MySQL()
mysql.init_app(app)

# Change title to host name to demo NLB
if app.config['SHOWHOST'] == "true":
    title = socket.gethostname()

@app.route('/', methods=['GET', 'POST'])
def index():

    # Vote tracking
    vote1 = 0
    vote2 = 0

    # MySQL connection
    connection = mysql.connect()
    cursor = connection.cursor()

    if request.method == 'GET':   
        cursor.execute('''Select votevalue, count(votevalue) as count From azurevote.azurevote
        group by votevalue''')
        results = cursor.fetchall()

        # Parse results
        for i in results:
            if i[0] == app.config['VOTE1VALUE']:
                vote1 = i[1]
            elif i[0] == app.config['VOTE2VALUE']:
                vote2 = i[1]              

        # Return index with values
        return render_template("index.html", value1=vote1, value2=vote2, button1=button1, button2=button2, title=title)

    elif request.method == 'POST':

        if request.form['vote'] == 'reset':
            
            # Empty table and return results
            cursor.execute('''Delete FROM azurevote''')
            connection.commit()
            return render_template("index.html", value1=vote1, value2=vote2, button1=button1, button2=button2, title=title)
        else:

            # Insert vote result into DB
            vote = request.form['vote']
            cursor.execute('''INSERT INTO azurevote (votevalue) VALUES (%s)''', (vote))
            connection.commit()
            
            # Get current values
            cursor.execute('''Select votevalue, count(votevalue) as count From azurevote.azurevote
            group by votevalue''')
            results = cursor.fetchall()

            # Parse results
            for i in results:
                if i[0] == app.config['VOTE1VALUE']:
                    vote1 = i[1]
                elif i[0] == app.config['VOTE2VALUE']:
                    vote2 = i[1]         
                
            # Return results
            return render_template("index.html", value1=vote1, value2=vote2, button1=button1, button2=button2, title=title)

@app.route('/results')
def results():
    connection = mysql.connect()
    cursor = connection.cursor()
    cursor.execute('''Select * FROM azurevote''')
    rv = cursor.fetchall()
    return str(rv)

if __name__ == "__main__":
    app.run()