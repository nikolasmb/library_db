from flask import Flask
from flask_mysqldb import MySQL

    
app = Flask(__name__)
    
app.config["MYSQL_USER"] = 'root'
app.config["MYSQL_PASSWORD"] = ''
app.config["MYSQL_DB"] = 'Library'
app.config["MYSQL_HOST"] = 'localhost'
app.config["SECRET_KEY"] = '1234' 
app.config["WTF_CSRF_SECRET_KEY"] = '' 

db = MySQL(app)

from library_db import routes

    