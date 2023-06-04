from flask import Flask, get_flashed_messages, render_template, request, flash, redirect, url_for, abort, session
from library_db import app, db
from flask_mysqldb import MySQL
from datetime import datetime, date
import MySQLdb


#home page
@app.route("/")
def index():
    current_route = request.path
    if (not 'user_type' in session) or (session['user_type'] == None):
        return render_template("landing.html", pageTitle = 'Welcome!', current_route=current_route)
    else:
        title = 'Welcome, ' + session['username'] + '!'
        if(session['user_type'] == 'user'):
            return render_template("home_user.html", pageTitle = title, current_route=current_route)
        elif(session['user_type'] == 'operator'):
            return render_template("home_operator.html", pageTitle = title, current_route=current_route)
        else:
            return render_template("home_admin.html", pageTitle = title, current_route=current_route)


#logout page
@app.route("/logout")
def logout():
    session['user_type'] = None
    session['id'] = None
    session['username'] = None
    session['school_id'] = None
    session['logged_in'] = False
    flash("Logged Out Succesfully", "success")
    return redirect(url_for('index'))
    

#login page
@app.route('/login', methods=['GET', 'POST'])
def login():
    
    if request.method == 'POST':
        
        username = request.form.get('username')
        password = request.form.get('password')
    
        cur = db.connection.cursor()
        cur.execute("SELECT password, admin_id FROM Admin WHERE username = %s", [username])
        db_admin = cur.fetchone()
        cur.close()
        if not db_admin:
            cur = db.connection.cursor()
            cur.execute("SELECT password, operator_id FROM Operator WHERE username = %s", [username])
            db_operator = cur.fetchone()
            cur.close()
            if not db_operator:
                cur = db.connection.cursor()
                cur.execute("SELECT password, user_id, school_id FROM User WHERE username = %s", [username])
                db_user = cur.fetchone()
                cur.close()
                if not db_user:
                    flash("Username does not exist.", "error")
                else:
                    print(db_user)
                    if(password != db_user[0]):
                        flash("Wrong password.", "error")
                    else:
                        session['user_type'] = 'user'
                        session['id'] = db_user[1]
                        session['username'] = username
                        session['school_id'] = db_user[2]
                        session['logged_in'] = True
                        flash("Logged In successfully.", "success")                        
                        return redirect(url_for('index')) 
            else:
                print(db_operator)
                if(password != db_operator[0]):
                    flash("Wrong password.", "error")
                else:
                    cur = db.connection.cursor()
                    cur.execute("SELECT school_id FROM School WHERE operator_id = %s", [db_operator[1]])
                    op_school_id = cur.fetchone()
                    db_school_id = op_school_id[0]
                    cur.close()
                    if db_school_id is None:
                        db_school_id = 0
                    session['user_type'] = 'operator'
                    session['id'] = db_operator[1]
                    session['username'] = username
                    session['school_id'] = db_school_id
                    session['logged_in'] = True
                    flash("Logged In successfully.", "success")
                    return redirect(url_for('index')) 
        else:
            print(db_admin)
            if(password != db_admin[0]):
                flash("Wrong password.", "error")
            else:
                session['user_type'] = 'admin'
                session['id'] = db_admin[1]
                session['username'] = username
                session['school_id'] = 0
                session['logged_in'] = True
                flash("Logged In successfully.", "success")
                return redirect(url_for('index'))      
      
    return render_template("login.html", pageTitle = "Welcome!")


#profile page
@app.route('/profile', methods=['GET', 'POST'])
def profile():
    
    if(session['user_type'] == 'user'):
        user_id = session['id']
        username = session['username']
        school_id = session['school_id']
            
        query = f"""
        SELECT u.*, s.school_name
        FROM User u
        JOIN School s ON u.school_id = s.school_id
        WHERE u.user_id = {user_id} AND u.school_id = {school_id};
        """
        
        cur = db.connection.cursor()
        cur.execute(query)
        user = cur.fetchall()
        cur.close()
        user_role = user[0][3]
        first_name = user[0][4]
        last_name = user[0][5]
        email = user[0][6]
        date_of_birth = user[0][7]
        borrowing_number = user[0][8]
        reservation_number = user[0][9]
        school_name = user[0][11]
        
        show_container = False
        if request.method == 'POST':
            current_password = request.form.get('current-password')
            new_password = request.form.get('new-password')
            if current_password is not None and new_password is not None:
                if(current_password == ""):
                    flash("Please enter your current password.", "error")
                    show_container = True
                elif(current_password != user[0][2]):
                    flash("Current password incorrect.", "error")
                    show_container = True
                elif(new_password == ""):
                    flash("Please enter your new password.", "error")
                    show_container = True
                else:
                    query = f"UPDATE User SET password = '{new_password}' WHERE user_id = {user_id}"
                    cur = db.connection.cursor()
                    cur.execute(query)
                    db.connection.commit()
                    cur.close()
                    show_container = False
                    flash("Password changed successfully.", "success")
                
            if(user_role == 'professor'):
                new_first_name = request.form.get('first-name')
                new_last_name = request.form.get('last-name')
                new_date_of_birth = request.form.get('date-of-birth')
                
                if new_first_name is not None and new_first_name != "":
                    if (new_first_name == ""):
                        flash("First name cannot be empty.", "error")
                    elif (len(new_first_name) < 2):
                        flash("First name is too short.", "error")
                    else:
                        capitalized_new_first_name = new_first_name.capitalize()
                        query = f"UPDATE User SET first_name = '{capitalized_new_first_name}' WHERE user_id = {user_id}"
                        cur = db.connection.cursor()
                        cur.execute(query)
                        db.connection.commit()
                        cur.close()
                        return redirect(url_for('profile'))
                        
                elif new_last_name is not None and new_last_name != "":
                    if(new_last_name == ""):
                        flash("Last name cannot be empty.", "error")
                    elif (len(new_last_name) < 2):
                        flash("Last name is too short.", "error")
                    else:
                        capitalized_new_last_name = new_last_name.capitalize()
                        query = f"UPDATE User SET last_name = '{capitalized_new_last_name}' WHERE user_id = {user_id}"
                        cur = db.connection.cursor()
                        cur.execute(query)
                        db.connection.commit()
                        cur.close()
                        return redirect(url_for('profile'))
                
                elif new_date_of_birth is not None:
                        query = f"UPDATE User SET date_of_birth = '{new_date_of_birth}' WHERE user_id = {user_id}"
                        cur = db.connection.cursor()
                        cur.execute(query)
                        db.connection.commit()
                        cur.close()
                        return redirect(url_for('profile'))
                                
        if(user_role == 'student'):
            return render_template("profile_student.html", show_container=show_container, user_id=user_id, username=username, first_name=first_name, last_name=last_name, email=email, school_name=school_name, user_type=user_role, date_of_birth=date_of_birth, borrowing_number=borrowing_number, reservation_number=reservation_number)
        else:
            return render_template("profile_professor.html", show_container=show_container, user_id=user_id, username=username, first_name=first_name, last_name=last_name, email=email, school_name=school_name, user_type=user_role, date_of_birth=date_of_birth, borrowing_number=borrowing_number, reservation_number=reservation_number)
        
    if(session['user_type'] == 'operator'):
        operator_id = session['id']
        username = session['username']
        school_id = session['school_id']
        user_type = 'operator'
       
        if school_id == 0 or school_id is None:
            school_id = 0
            query = f"SELECT * FROM Operator WHERE operator_id = {operator_id}"
        else:
            query = f"""
            SELECT o.*, s.school_name
            FROM Operator o
            JOIN School s ON o.operator_id = s.operator_id
            WHERE o.operator_id = {operator_id} AND s.school_id = {school_id};

            """
        cur = db.connection.cursor()
        cur.execute(query)
        operator = cur.fetchall()
        cur.close()
        first_name = operator[0][3]
        last_name = operator[0][4]
        email = operator[0][5]
        date_of_birth = operator[0][6]
        if school_id != 0:
            school_name = operator[0][7]
        else:
            school_name = 'No School'
        
        show_container = False
        if request.method == 'POST':
            current_password = request.form.get('current-password')
            new_password = request.form.get('new-password')
            if current_password is not None and new_password is not None:
                if(current_password == ""):
                    flash("Please enter your current password.", "error")
                    show_container = True
                elif(current_password != operator[0][2]):
                    flash("Current password incorrect.", "error")
                    show_container = True
                elif(new_password == ""):
                    flash("Please enter your new password.", "error")
                    show_container = True
                else:
                    query = f"UPDATE Operator SET password = '{new_password}' WHERE operator_id = {operator_id}"
                    cur = db.connection.cursor()
                    cur.execute(query)
                    db.connection.commit()
                    cur.close()
                    show_container = False
                    flash("Password changed successfully.", "success")
                
            new_first_name = request.form.get('first-name')
            new_last_name = request.form.get('last-name')
            new_date_of_birth = request.form.get('date-of-birth')
                
            if new_first_name is not None and new_first_name != "":
                if (new_first_name == ""):
                    flash("First name cannot be empty.", "error")
                elif (len(new_first_name) < 2):
                    flash("First name is too short.", "error")
                else:
                    capitalized_new_first_name = new_first_name.capitalize()
                    query = f"UPDATE Operator SET first_name = '{capitalized_new_first_name}' WHERE operator_id = {operator_id}"
                    cur = db.connection.cursor()
                    cur.execute(query)
                    db.connection.commit()
                    cur.close()
                    return redirect(url_for('profile'))
                        
            elif new_last_name is not None and new_last_name != "":
                if(new_last_name == ""):
                    flash("Last name cannot be empty.", "error")
                elif (len(new_last_name) < 2):
                    flash("Last name is too short.", "error")
                else:
                    capitalized_new_last_name = new_last_name.capitalize()
                    query = f"UPDATE Operator SET last_name = '{capitalized_new_last_name}' WHERE operator_id = {operator_id}"
                    cur = db.connection.cursor()
                    cur.execute(query)
                    db.connection.commit()
                    cur.close()
                    return redirect(url_for('profile'))
                
            elif new_date_of_birth is not None:
                query = f"UPDATE Operator SET date_of_birth = '{new_date_of_birth}' WHERE operator_id = {operator_id}"
                cur = db.connection.cursor()
                cur.execute(query)
                db.connection.commit()
                cur.close()
                return redirect(url_for('profile'))
                                
        return render_template("profile_operator.html", show_container=show_container, operator_id=operator_id, username=username, first_name=first_name, last_name=last_name, email=email, school_name=school_name, user_type=user_type, date_of_birth=date_of_birth)

    else:   #admin
        admin_id = session['id']
        username = session['username']
        user_type = 'admin'

        query = f"SELECT * FROM Admin WHERE admin_id = {admin_id}"
        cur = db.connection.cursor()
        cur.execute(query)
        admin = cur.fetchall()
        cur.close()
        first_name = admin[0][3]
        last_name = admin[0][4]
        email = admin[0][5]
        date_of_birth = admin[0][6]
        
        show_container = False
        if request.method == 'POST':
            current_password = request.form.get('current-password')
            new_password = request.form.get('new-password')
            if current_password is not None and new_password is not None:
                if(current_password == ""):
                    flash("Please enter your current password.", "error")
                    show_container = True
                elif(current_password != admin[0][2]):
                    flash("Current password incorrect.", "error")
                    show_container = True
                elif(new_password == ""):
                    flash("Please enter your new password.", "error")
                    show_container = True
                else:
                    query = f"UPDATE Admin SET password = '{new_password}' WHERE admin_id = {admin_id}"
                    cur = db.connection.cursor()
                    cur.execute(query)
                    db.connection.commit()
                    cur.close()
                    show_container = False
                    flash("Password changed successfully.", "success")
                
            new_first_name = request.form.get('first-name')
            new_last_name = request.form.get('last-name')
            new_date_of_birth = request.form.get('date-of-birth')
                
            if new_first_name is not None and new_first_name != "":
                if (new_first_name == ""):
                    flash("First name cannot be empty.", "error")
                elif (len(new_first_name) < 2):
                    flash("First name is too short.", "error")
                else:
                    capitalized_new_first_name = new_first_name.capitalize()
                    query = f"UPDATE Admin SET first_name = '{capitalized_new_first_name}' WHERE admin_id = {admin_id}"
                    cur = db.connection.cursor()
                    cur.execute(query)
                    db.connection.commit()
                    cur.close()
                    return redirect(url_for('profile'))
                        
            elif new_last_name is not None and new_last_name != "":
                if(new_last_name == ""):
                    flash("Last name cannot be empty.", "error")
                elif (len(new_last_name) < 2):
                    flash("Last name is too short.", "error")
                else:
                    capitalized_new_last_name = new_last_name.capitalize()
                    query = f"UPDATE Admin SET last_name = '{capitalized_new_last_name}' WHERE admin_id = {admin_id}"
                    cur = db.connection.cursor()
                    cur.execute(query)
                    db.connection.commit()
                    cur.close()
                    return redirect(url_for('profile'))
                
            elif new_date_of_birth is not None:
                query = f"UPDATE Admin SET date_of_birth = '{new_date_of_birth}' WHERE admin_id = {admin_id}"
                cur = db.connection.cursor()
                cur.execute(query)
                db.connection.commit()
                cur.close()
                return redirect(url_for('profile'))
                                
        return render_template("profile_admin.html", show_container=show_container, admin_id=admin_id, username=username, first_name=first_name, last_name=last_name, email=email, user_type=user_type, date_of_birth=date_of_birth)


#user registration page
@app.route('/register-user', methods=['GET', 'POST'])
def sign_up_user():
    
    query = "SELECT school_id, school_name FROM School ORDER BY school_name"
    cur = db.connection.cursor()
    cur.execute(query)
    schools = cur.fetchall()
    cur.close()
     
    if request.method == 'POST':    
        try:
            username = request.form.get('username')
            password = request.form.get('password')
            first_name = request.form.get('first-name')
            last_name = request.form.get('last-name')
            role = request.form.get('role')
            email = request.form.get('email')
            date_of_birth = request.form.get('date-of-birth')
            school_id = request.form.get('school')
        
            query = f"""
            INSERT INTO User_Registration (username, password, first_name, last_name, user_role, email, date_of_birth, school_id)
            VALUES("{username}", "{password}", "{first_name}", "{last_name}", "{role}", "{email}", "{date_of_birth}", "{school_id}");
            """
            cur = db.connection.cursor()
            cur.execute(query)
            db.connection.commit()
            cur.close()
            flash("Registration successful. Please wait for your registration to be accepted.", "success")
            return redirect(url_for('index'))
        
        except Exception as e:
            flash(str(e), "error")
            return render_template("user_reg.html", schools=schools, username=username, password=password, first_name=first_name, last_name=last_name, email=email, error=True, pageTitle = "Welcome!")

    return render_template("user_reg.html", schools=schools, pageTitle = "Welcome!")


#operator registration page
@app.route('/register-operator', methods=['GET', 'POST'])
def sign_up_operator():
    
    query = "SELECT school_id, school_name FROM School ORDER BY school_name"
    cur = db.connection.cursor()
    cur.execute(query)
    schools = cur.fetchall()
    cur.close()
     
    if request.method == 'POST':    
        try:
            username = request.form.get('username')
            password = request.form.get('password')
            first_name = request.form.get('first-name')
            last_name = request.form.get('last-name')
            email = request.form.get('email')
            date_of_birth = request.form.get('date-of-birth')
            school_id = request.form.get('school')
        
            query = f"""
            INSERT INTO User_Registration (username, password, first_name, last_name, email, date_of_birth, school_id)
            VALUES("{username}", "{password}", "{first_name}", "{last_name}", "{email}", "{date_of_birth}", "{school_id}");
            """
            cur = db.connection.cursor()
            cur.execute(query)
            db.connection.commit()
            cur.close()
            flash("Registration successful. Please wait for your registration to be accepted.", "success")
            return redirect(url_for('index'))
        
        except Exception as e:
            flash(str(e), "error")
            return render_template("operator_reg.html", schools=schools, username=username, password=password, first_name=first_name, last_name=last_name, email=email, error=True, pageTitle = "Welcome!")

    return render_template("operator_reg.html", schools=schools, pageTitle = "Welcome!")


#book list page
@app.route('/books-list', methods=['GET', 'POST'])
def books_list():
    
    if(session['user_type'] == 'user') or (session['user_type'] == 'operator'):
        
        school_id = session['school_id']
        p_school_id = school_id
        p_title = None
        p_category_name = None
        p_author_name = None
        if request.method == 'POST':
            p_title = request.form.get('title')
            p_author_name = request.form.get('author')
            p_category_name = request.form.get('category')
            if(p_title==""):
                p_title = None
            if(p_category_name==""):
                p_category_name = None
            if(p_author_name==""):
                p_author_name = None

        query = """
        SELECT sb.school_id, b.ISBN, b.title, b.publisher,
            GROUP_CONCAT(DISTINCT c.category_name) AS categories,
            GROUP_CONCAT(DISTINCT CONCAT(a.first_name, ' ', a.last_name)) AS authors,
            GROUP_CONCAT(DISTINCT k.keyword_name) AS keywords,
            sb.available_copies
        FROM Book b
        JOIN Book_Category bc ON b.ISBN = bc.ISBN
        JOIN Category c ON bc.category_id = c.category_id
        JOIN Book_Author ba ON b.ISBN = ba.ISBN
        JOIN Author a ON ba.author_id = a.author_id
        JOIN Book_Keyword bk ON b.ISBN = bk.ISBN
        JOIN Keyword k ON bk.keyword_id = k.keyword_id
        JOIN School_Book sb ON b.ISBN = sb.ISBN
        WHERE (sb.school_id = %s)
        AND (b.title LIKE CONCAT('%%', IFNULL(%s, ''), '%%') OR %s IS NULL)
        AND (b.ISBN IN (
            SELECT DISTINCT bc2.ISBN
            FROM Book_Category bc2
            JOIN Category c2 ON bc2.category_id = c2.category_id
            WHERE c2.category_name = IFNULL(%s, c2.category_name)
            ) OR %s IS NULL)
        AND (b.ISBN IN (
            SELECT DISTINCT ba2.ISBN
            FROM Book_Author ba2
            JOIN Author a2 ON ba2.author_id = a2.author_id
            WHERE CONCAT(a2.first_name, ' ', a2.last_name) = IFNULL(%s, CONCAT(a2.first_name, ' ', a2.last_name))
            ) OR %s IS NULL)
        GROUP BY sb.school_id, b.ISBN
        ORDER BY b.title;
        """

        cur = db.connection.cursor()
        cur.execute(query, (p_school_id, p_title, p_title, p_category_name, p_category_name, p_author_name, p_author_name))
        books = cur.fetchall()
        cur.close()

        return render_template('books_list.html', books=books, book_route = url_for('book'))
    

#book page
@app.route('/books-list/book', methods=['GET', 'POST'])
def book():
    
    if(session['user_type'] == 'user'):
        
        isbn = request.args.get('isbn')
        p_ISBN = isbn if isbn else 'NULL'
        p_school_id = session['school_id']
        query = f"""
        SELECT sb.school_id, b.*,
            GROUP_CONCAT(DISTINCT c.category_name) AS categories,
            GROUP_CONCAT(DISTINCT CONCAT(a.first_name, ' ', a.last_name)) AS authors,
            GROUP_CONCAT(DISTINCT k.keyword_name) AS keywords,
            sb.available_copies
        FROM Book b
        JOIN Book_Category bc ON b.ISBN = bc.ISBN
        JOIN Category c ON bc.category_id = c.category_id
        JOIN Book_Author ba ON b.ISBN = ba.ISBN
        JOIN Author a ON ba.author_id = a.author_id
        JOIN Book_Keyword bk ON b.ISBN = bk.ISBN
        JOIN Keyword k ON bk.keyword_id = k.keyword_id
        JOIN School_Book sb ON b.ISBN = sb.ISBN
        WHERE (sb.school_id = {p_school_id} OR {p_school_id} IS NULL)
        AND (b.ISBN = {p_ISBN} OR {p_ISBN} IS NULL)
        GROUP BY b.ISBN;
        """
        cur = db.connection.cursor()
        cur.execute(query)
        book = cur.fetchall()
        cur.close()

        return render_template('book.html', book=book)

    if(session['user_type'] == 'operator'):
        
        isbn = request.args.get('isbn')
        p_ISBN = isbn if isbn else 'NULL'
        p_school_id = session['school_id']
        query = f"""
        SELECT sb.school_id, b.*,
            GROUP_CONCAT(DISTINCT c.category_name) AS categories,
            GROUP_CONCAT(DISTINCT CONCAT(a.first_name, ' ', a.last_name)) AS authors,
            GROUP_CONCAT(DISTINCT k.keyword_name) AS keywords,
            sb.available_copies
        FROM Book b
        JOIN Book_Category bc ON b.ISBN = bc.ISBN
        JOIN Category c ON bc.category_id = c.category_id
        JOIN Book_Author ba ON b.ISBN = ba.ISBN
        JOIN Author a ON ba.author_id = a.author_id
        JOIN Book_Keyword bk ON b.ISBN = bk.ISBN
        JOIN Keyword k ON bk.keyword_id = k.keyword_id
        JOIN School_Book sb ON b.ISBN = sb.ISBN
        WHERE (sb.school_id = {p_school_id} OR {p_school_id} IS NULL)
        AND (b.ISBN = {p_ISBN} OR {p_ISBN} IS NULL)
        GROUP BY b.ISBN;
        """
        cur = db.connection.cursor()
        cur.execute(query)
        book = cur.fetchall()
        cur.close()
        
        if request.method == 'POST':
            title = request.form.get('title')
            publisher = request.form.get('publisher')
            number_of_pages = request.form.get('pages')
            language = request.form.get('language')
            image_url = request.form.get('image-url')
            summary = request.form.get('summary')
            available_copies = request.form.get('copies')
            try:
                if (title is not None) and (title != "") and (title)!=book[0][2]:
                    try:
                        query = f"UPDATE Book SET title = '{title}' WHERE ISBN = {p_ISBN}"
                        cur = db.connection.cursor()
                        cur.execute(query)
                        db.connection.commit()
                        cur.close()
                        flash("Title changed successfully.", "success")
                        return redirect(f'/books-list/book?isbn={p_ISBN}')
                    except Exception as e:
                        flash(str(e), "error")

                elif (publisher is not None) and (publisher != "") and (publisher)!=book[0][3]:
                    try:
                        query = f"UPDATE Book SET publisher = '{publisher}' WHERE ISBN = {p_ISBN}"
                        cur = db.connection.cursor()
                        cur.execute(query)
                        db.connection.commit()
                        cur.close()
                        flash("Publisher changed successfully.", "success")
                        return redirect(f'/books-list/book?isbn={p_ISBN}')
                    except Exception as e:
                        flash(str(e), "error")
                        
                elif (number_of_pages is not None) and (number_of_pages != "") and (number_of_pages)!=book[0][4]:
                    try:
                        query = f"UPDATE Book SET number_of_pages = '{number_of_pages}' WHERE ISBN = {p_ISBN}"
                        cur = db.connection.cursor()
                        cur.execute(query)
                        db.connection.commit()
                        cur.close()
                        flash("Number of pages changed successfully.", "success")
                        return redirect(f'/books-list/book?isbn={p_ISBN}')
                    except Exception as e:
                        flash(str(e), "error")                                             
                  
                elif (language is not None) and (language != "") and (language)!=book[0][7]:
                    try:
                        query = f"UPDATE Book SET language = '{language}' WHERE ISBN = {p_ISBN}"
                        cur = db.connection.cursor()
                        cur.execute(query)
                        db.connection.commit()
                        cur.close()
                        flash("Language changed successfully.", "success")
                        return redirect(f'/books-list/book?isbn={p_ISBN}')
                    except Exception as e:
                        flash(str(e), "error")
 
                elif (image_url is not None) and (image_url != "") and (image_url)!=book[0][6]:
                    try:
                        query = f"UPDATE Book SET image_url = '{image_url}' WHERE ISBN = {p_ISBN}"
                        cur = db.connection.cursor()
                        cur.execute(query)
                        db.connection.commit()
                        cur.close()
                        flash("Image URL changed successfully.", "success")
                        return redirect(f'/books-list/book?isbn={p_ISBN}')
                    except Exception as e:
                        flash(str(e), "error")
                        
                elif (summary is not None) and (summary != "") and (summary)!=book[0][5]:
                    try:
                        query = f"UPDATE Book SET summary = '{summary}' WHERE ISBN = {p_ISBN}"
                        cur = db.connection.cursor()
                        cur.execute(query)
                        db.connection.commit()
                        cur.close()
                        flash("Summary changed successfully.", "success")
                        return redirect(f'/books-list/book?isbn={p_ISBN}')
                    except Exception as e:
                        flash(str(e), "error")
                        
                elif (available_copies is not None) and (available_copies != "") and (available_copies)!=book[0][6]:
                    try:
                        query = f"UPDATE School_Book SET available_copies = '{available_copies}' WHERE ISBN = {p_ISBN} AND school_id = {p_school_id}"
                        cur = db.connection.cursor()
                        cur.execute(query)
                        db.connection.commit()
                        cur.close()
                        flash("Available copies changed successfully.", "success")
                        return redirect(f'/books-list/book?isbn={p_ISBN}')
                    except Exception as e:
                        flash(str(e), "error")
                                                                      
            except Exception as e:
                flash(str(e), "error") 
                                                                 
        return render_template('book_operator.html', book=book)

#request a book
@app.route('/books-list/book/request', methods=['GET', 'POST'])
def request_book():
    
    if(session['user_type'] == 'user'):
        
        isbn = request.args.get('isbn')
        available_copies = request.args.get('available_copies')
        available_copies_int = int(available_copies)
        user_id = session['id']
        print(isbn)
        print(available_copies_int)
        print(type(available_copies_int))
        if available_copies_int > 0:
            try:
                cur = db.connection.cursor()
                cur.callproc('create_borrowing', (user_id, isbn))
                db.connection.commit()
                cur.close()
                flash("Request to borrow successful. Please wait for your request to be approved.", "success")
            except Exception as e:
                error_message = str(e)
                flash(error_message, "error")
        else:
            try:
                cur = db.connection.cursor()
                cur.callproc('create_reservation', (user_id, isbn))
                db.connection.commit()
                cur.close()
                flash("Reservation successful.", "success")
            except Exception as e:
                error_message = str(e)
                flash(error_message, "error")
           
    return redirect(f'/books-list/book?isbn={isbn}&available_copies={available_copies_int}')



@app.route('/borrowed-now', methods=['GET', 'POST'])
def borrowed_now():
    if session['user_type'] == 'user':
        user_id = session['id']
        query = f"""
        SELECT Book.title, Book.ISBN, Borrowing.borrowing_date, Borrowing.due_date, Borrowing.borrowing_id, Borrowing.is_accepted
        FROM Book
        INNER JOIN Borrowing ON Borrowing.ISBN = Book.ISBN
        WHERE Borrowing.user_id = {user_id}
          AND Borrowing.return_date IS NULL;
        """
        cur = db.connection.cursor()
        cur.execute(query)
        books_borrowed = cur.fetchall()
        cur.close()
        
        query = f"""
        SELECT Book.title, Book.ISBN, Reservation.reservation_date, Reservation.reservation_id
        FROM Book
        INNER JOIN Reservation ON Reservation.ISBN = Book.ISBN
          WHERE Reservation.user_id = {user_id};
        """
        cur = db.connection.cursor()
        cur.execute(query)
        books_reserved = cur.fetchall()
        cur.close()

        
        return render_template('borrowed_now.html', books_borrowed=books_borrowed, books_reserved=books_reserved)


#return a book
@app.route('/borrowed-now/return', methods=['GET', 'POST'])
def return_book():
    
    if(session['user_type'] == 'user'):
        
        borrowing_id = request.args.get('isbn')
        user_id = session['id']
        try:
            cur = db.connection.cursor()
            cur.callproc('return_book', (user_id, borrowing_id))
            db.connection.commit()
            cur.close()
            flash("Book returned succesfully", "success")
            return redirect('/')
        except Exception as e:
            error_message = str(e)
            flash(error_message, "error")
           
    return redirect('/borrowed-now')


#cancel reservation
@app.route('/borrowed-now/cancel', methods=['GET', 'POST'])
def cancel_reservation():
    
    if(session['user_type'] == 'user'):
        
        reservation_id = request.args.get('reservation_id')
        user_id = session['id']
        try:
            cur = db.connection.cursor()
            cur.callproc('cancel_reservation', (user_id, reservation_id))
            db.connection.commit()
            cur.close()
            flash("Reservation cancelled succesfully", "success")
        except Exception as e:
            error_message = str(e)
            flash(error_message, "error")
           
    return redirect('/borrowed-now')


#delete book
@app.route('/books-list/book/delete', methods=['GET', 'POST'])
def delete_book():
    if(session['user_type'] == 'operator'):
        
        isbn = request.args.get('isbn')
        school_id = session['school_id']
        try:
            query = f"DELETE FROM School_Book WHERE ISBN = '{isbn}' and school_id = {school_id}"
            cur = db.connection.cursor()
            cur.execute(query)
            db.connection.commit()
            cur.close()
            flash("User deleted succesfully", "success")
        except Exception as e:
            error_message = str(e)
            flash(error_message, "error")
           
    return redirect('/books-list')
    
    
#user list
@app.route('/users-list', methods=['GET', 'POST'])
def users_list():
    if(session['user_type'] == 'operator'):
        
        school_id = session['school_id']

        query = f"""
        SELECT u.user_id, u.username, u.first_name, u.last_name
        FROM User u
        WHERE u.school_id = {school_id};
        """

        cur = db.connection.cursor()
        cur.execute(query)
        users = cur.fetchall()
        cur.close()

        return render_template('users_list.html', users=users)


#query 4.3.2
@app.route('/query-4-3-2', methods=['GET', 'POST'])
def query432():
    if session['user_type'] == 'user':
        user_id = session['id']
        query = f"""
        SELECT School.school_name, COUNT(*) AS loan_count
        FROM School
        JOIN User ON User.school_id = School.school_id
        JOIN Borrowing ON Borrowing.user_id = User.user_id
        WHERE (p_start_date IS NULL OR Borrowing.borrowing_date >= p_start_date)
            AND (p_end_date IS NULL OR Borrowing.borrowing_date <= p_end_date)
        GROUP BY School.school_name;
        """
        cur = db.connection.cursor()
        cur.execute(query)
        books = cur.fetchall()
        cur.close()
        
        return render_template('query432.html', books=books)
    
    
#manage users:
@app.route('/users-list/manage-users', methods=['GET', 'POST'])
def manage_users():
    
    if(session['user_type'] == 'operator'):
        user_id = request.args.get('user_id')
        school_id = session['school_id']
            
        query = f"""
        SELECT u.*, s.school_name
        FROM User u
        JOIN School s ON u.school_id = s.school_id
        WHERE u.user_id = {user_id} AND u.school_id = {school_id};
        """
        
        cur = db.connection.cursor()
        cur.execute(query)
        user = cur.fetchall()
        cur.close()
        username = user[0][1]
        user_role = user[0][3]
        first_name = user[0][4]
        last_name = user[0][5]
        email = user[0][6]
        date_of_birth = user[0][7]
        borrowing_number = user[0][8]
        reservation_number = user[0][9]
        school_name = user[0][11]
        
        show_container = False
        if request.method == 'POST':
            current_password = request.form.get('current-password')
            new_password = request.form.get('new-password')
            if current_password is not None and new_password is not None:
                if(current_password == ""):
                    flash("Please enter your current password.", "error")
                    show_container = True
                elif(current_password != user[0][2]):
                    flash("Current password incorrect.", "error")
                    show_container = True
                elif(new_password == ""):
                    flash("Please enter your new password.", "error")
                    show_container = True
                else:
                    query = f"UPDATE User SET password = '{new_password}' WHERE user_id = {user_id}"
                    cur = db.connection.cursor()
                    cur.execute(query)
                    db.connection.commit()
                    cur.close()
                    show_container = False
                    flash("Password changed successfully.", "success")
                
            new_first_name = request.form.get('first-name')
            new_last_name = request.form.get('last-name')
            new_date_of_birth = request.form.get('date-of-birth')
                
            if new_first_name is not None and new_first_name != "":
                if (new_first_name == ""):
                    flash("First name cannot be empty.", "error")
                elif (len(new_first_name) < 2):
                    flash("First name is too short.", "error")
                else:
                    capitalized_new_first_name = new_first_name.capitalize()
                    query = f"UPDATE User SET first_name = '{capitalized_new_first_name}' WHERE user_id = {user_id}"
                    cur = db.connection.cursor()
                    cur.execute(query)
                    db.connection.commit()
                    cur.close()
                    return redirect(f'/users-list/manage-users?user_id={ user[0][0] }')
                        
            elif new_last_name is not None and new_last_name != "":
                if(new_last_name == ""):
                    flash("Last name cannot be empty.", "error")
                elif (len(new_last_name) < 2):
                    flash("Last name is too short.", "error")
                else:
                    capitalized_new_last_name = new_last_name.capitalize()
                    query = f"UPDATE User SET last_name = '{capitalized_new_last_name}' WHERE user_id = {user_id}"
                    cur = db.connection.cursor()
                    cur.execute(query)
                    db.connection.commit()
                    cur.close()
                    return redirect(f'/users-list/manage-users?user_id={ user[0][0] }')
                
            elif new_date_of_birth is not None:
                query = f"UPDATE User SET date_of_birth = '{new_date_of_birth}' WHERE user_id = {user_id}"
                cur = db.connection.cursor()
                cur.execute(query)
                db.connection.commit()
                cur.close()
                return redirect(f'/users-list/manage-users?user_id={ user[0][0] }')
                                
        return render_template("manage_users.html", show_container=show_container, user_id=user_id, username=username, first_name=first_name, last_name=last_name, email=email, school_name=school_name, user_type=user_role, date_of_birth=date_of_birth, borrowing_number=borrowing_number, reservation_number=reservation_number)
        

#delete book
@app.route('/users-list/manage-users/delete', methods=['GET', 'POST'])
def delete_user():
    if(session['user_type'] == 'operator'):
        
        user_id = request.args.get('user_id')
        try:
            query = f"DELETE FROM User WHERE user_id = '{user_id}"
            cur = db.connection.cursor()
            cur.execute(query)
            db.connection.commit()
            cur.close()
            flash("User deleted succesfully", "success")
        except Exception as e:
            error_message = str(e)
            flash(error_message, "error")
           
    return redirect('/users-list')
        
        
##query 4.1.1
@app.route('/query411', methods=['GET', 'POST'])
def query411():
    if(session['user_type'] == 'admin'):
        

        p_start_date = 'NULL'
        p_end_date = 'NULL'
        if request.method == 'POST':
            p_start_date = request.form.get('start-date')
            p_end_date = request.form.get('end-date')
            if(p_start_date==""):
                p_start_date = 'NULL'
            if(p_end_date==""):
                p_end_date = 'NULL'


        query = f"""
        SELECT School.school_id, School.school_name, COUNT(*) AS loan_count
        FROM School
        JOIN User ON User.school_id = School.school_id
        JOIN Borrowing ON Borrowing.user_id = User.user_id
        WHERE ({p_start_date} IS NULL OR Borrowing.borrowing_date >= {p_start_date})
            AND ({p_end_date} IS NULL OR Borrowing.borrowing_date <= {p_end_date})
        GROUP BY School.school_name;
        """

        cur = db.connection.cursor()
        cur.execute(query)
        schools = cur.fetchall()
        cur.close()

        return render_template('query411.html', schools=schools)   
    
    
         
        