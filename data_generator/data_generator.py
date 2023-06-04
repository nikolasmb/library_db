import random
import math
import faker
from faker_education import SchoolProvider
from datetime import timedelta, date, datetime

fake = faker.Faker('en_US')
fake.add_provider(SchoolProvider)
data = ""


##Admin
COLUMNS = ["username", "password", "first_name", "last_name", "email", "date_of_birth"]
admin_number = 2
for i in range(admin_number):
    username = fake.unique.user_name()
    if len(username) > 30:
        username = username[:30]
    password = fake.password(special_chars='@#$%^&*()=+"')
    if len(password) > 30:
        password = password[:30]
    first_name = fake.first_name()
    last_name = fake.last_name()
    email = fake.unique.email()
    date_of_birth = fake.date_of_birth(minimum_age=25, maximum_age=70)
    data += f'INSERT INTO Admin ({",".join(COLUMNS)}) VALUES ("{username}", "{password}", "{first_name}", "{last_name}", "{email}", "{date_of_birth}");\n'

username = 'antigonik'
password = '12345'
first_name = 'Antigoni'
last_name = 'Karanika'
email = 'antigoni@gmail.com'
date_of_birth = '2002-03-01'
data += f'INSERT INTO Admin ({",".join(COLUMNS)}) VALUES ("{username}", "{password}", "{first_name}", "{last_name}", "{email}", "{date_of_birth}");\n'  
admin_number += 1  
        
##Operator
COLUMNS = ["username", "password", "first_name", "last_name", "email", "date_of_birth"]
operator_number = 19
for i in range(operator_number):
    username = fake.unique.user_name()
    if len(username) > 30:
        username = username[:30]
    password = fake.password(special_chars='@#$%^&*()=+"')
    if len(password) > 30:
        password = password[:30]
    first_name = fake.first_name()
    last_name = fake.last_name()
    email = fake.unique.email()
    date_of_birth = fake.date_of_birth(minimum_age=25, maximum_age=70)
    data += f'INSERT INTO Operator ({",".join(COLUMNS)}) VALUES ("{username}", "{password}", "{first_name}", "{last_name}", "{email}", "{date_of_birth}");\n'

username = 'nikolasb'
password = '12345'
first_name = 'Nikolas'
last_name = 'Bothos'
email = 'nikolas@gmail.com'
date_of_birth = '2002-09-04'
data += f'INSERT INTO Operator ({",".join(COLUMNS)}) VALUES ("{username}", "{password}", "{first_name}", "{last_name}", "{email}", "{date_of_birth}");\n'
operator_number += 1
   
          
##School
COLUMNS = ["school_name", "address_name", "address_number", "city", "postal_code", "phone_number", "email", "school_director", "operator_id"]
school_number = operator_number
for i in range(school_number):
    school_name = fake.school_name()
    address_name = fake.street_name()
    address_number = random.randint(1, 99)
    postal_code = fake.unique.zipcode()[:5]
    city = fake.city()
    email = fake.unique.email()
    phone_number = fake.unique.phone_number()
    school_director = fake.name()
    operator_id = i + 1 
    data += f'INSERT INTO School ({",".join(COLUMNS)}) VALUES ("{school_name}", "{address_name}", {address_number}, "{city}", "{postal_code}", "{phone_number}", "{email}", "{school_director}", {operator_id});\n'
    

##User-Student
COLUMNS = ["username", "password", "user_role", "first_name", "last_name", "email", "date_of_birth", "borrowing_number", "reservation_number", "school_id"]
student_data = []
student_number = 599
user_school_list = []
for i in range(student_number):
    username = fake.unique.user_name()
    if len(username) > 30:
        username = username[:30]
    password = fake.password(special_chars='@#$%^&*()=+"')
    if len(password) > 30:
        password = password[:30]
    first_name = fake.first_name()
    last_name = fake.last_name()
    email = fake.unique.email()
    date_of_birth = fake.date_of_birth(minimum_age=6, maximum_age=22)
    borrowing_number = 0
    reservation_number = 0
    school_id = random.randint(1, school_number)
    user_school_list.append(school_id)
    data += f'INSERT INTO User ({",".join(COLUMNS)}) VALUES ("{username}", "{password}", "student", "{first_name}", "{last_name}", "{email}", "{date_of_birth}", {borrowing_number}, {reservation_number}, {school_id});\n'
    
username = 'mixaliso'
password = '12345'
first_name = 'Mixalis'
last_name = 'Orfanos'
email = 'mixalis@gmail.com'
date_of_birth = '2002-07-13'
borrowing_number = 0
reservation_number = 0
school_id = random.randint(1, school_number)
user_school_list.append(school_id)
data += f'INSERT INTO User ({",".join(COLUMNS)}) VALUES ("{username}", "{password}", "student", "{first_name}", "{last_name}", "{email}", "{date_of_birth}", {borrowing_number}, {reservation_number}, {school_id});\n'


##User-Professor
COLUMNS = ["username", "password", "user_role", "first_name", "last_name", "email", "date_of_birth", "borrowing_number", "reservation_number", "school_id"]
professor_number = 199
for i in range(professor_number):
    username = fake.unique.user_name()
    if len(username) > 30:
        username = username[:30]
    password = fake.password(special_chars='@#$%^&*()=+"')
    if len(password) > 30:
        password = password[:30]
    first_name = fake.first_name()
    last_name = fake.last_name()
    email = fake.unique.email()
    date_of_birth = fake.date_of_birth(minimum_age=25, maximum_age=70)
    borrowing_number = 0
    reservation_number = 0
    school_id = random.randint(1, school_number)
    user_school_list.append(school_id)
    data += f'INSERT INTO User ({",".join(COLUMNS)}) VALUES ("{username}", "{password}", "professor", "{first_name}", "{last_name}", "{email}", "{date_of_birth}", {borrowing_number}, {reservation_number}, {school_id});\n'

username = 'xristosf'
password = '12345'
first_name = 'Xristos'
last_name = 'Filippas'
email = 'xristos@gmail.com'
date_of_birth = '2002-10-21'
borrowing_number = 0
reservation_number = 0
school_id = random.randint(1, school_number)
user_school_list.append(school_id)
data += f'INSERT INTO User ({",".join(COLUMNS)}) VALUES ("{username}", "{password}", "professor", "{first_name}", "{last_name}", "{email}", "{date_of_birth}", {borrowing_number}, {reservation_number}, {school_id});\n'


##Book
COLUMNS = ["ISBN", "title", "pages_number", "publisher", "summary", "image_url", "language"]
book_list = []
book_number = 500
for i in range(book_number):
    isbn_dummy = fake.unique.isbn13()
    isbn = isbn_dummy.replace('-', '')
    book_list.append(isbn)
    title = fake.sentence(nb_words=4)[:-1]
    pages_number = random.randint(100, 1000)
    publisher = fake.company()
    summary = fake.text()[:500]
    image_url = fake.image_url(width=None, height=None)
    language = random.choice(['Greek', 'English', 'French', 'German'])
    data += f'INSERT INTO Book ({",".join(COLUMNS)}) VALUES ("{isbn}", "{title}", "{pages_number}", "{publisher}", "{summary}", "{image_url}", "{language}");\n'
    

##Category
category_number = 23
categories = ["Adventure", "Art", "Contemporary", "Cookbook", "Distopian", "Fantasy", "Guide", "Health", "Historical Fiction", "History", "Horror", "Humor", "Memoir", "Motivational", "Mystery", "Paranormal", "Poetry", "Romance", "Science Fiction", "Self-help", "Thriller", "Travel", "Western"]
for category_name in categories:
    data += f'INSERT INTO Category (category_name) VALUES ("{category_name}");\n'


##Author
COLUMNS = ["first_name", "last_name"]
author_number = 150
for i in range(author_number):
    first_name = fake.first_name()
    last_name = fake.last_name()
    data += f'INSERT INTO Author ({",".join(COLUMNS)}) VALUES ("{first_name}", "{last_name}");\n'


##Keyword
keyword_number = 200
for i in range(keyword_number):
    keyword_name = fake.unique.word()
    data += f'INSERT INTO Keyword ({",".join(["keyword_name"])}) VALUES ("{keyword_name}");\n'
    
    
##Review
COLUMNS = ["rating", "review_text", "review_date", "ISBN", "user_id"]
user_number = student_number + professor_number
review_number = 50
review_users = random.sample(range(1,user_number), review_number)
for user_id in review_users:
    review_books_list = random.sample(book_list, random.randint(0,3))
    for isbn in review_books_list:
        rating = random.randint(1, 5)
        review_text = fake.text()[:300]
        review_date = fake.date_between(start_date='-3y', end_date='today')
        data += f'INSERT INTO Review ({",".join(COLUMNS)}) VALUES ("{rating}", "{review_text}", "{review_date}", "{isbn}", "{user_id}");\n'


##School_Book
COLUMNS = ["school_id","ISBN","available_copies"]
books_per_school_list = []
school_book_list = []
for school_id in range(1, school_number+1):
    school_books = random.sample(book_list, math.ceil(book_number*0.8))
    for isbn in school_books:
        books_per_school_list.append(isbn)
        available_copies = random.randint(0,20)
        data += f'INSERT INTO School_Book ({",".join(COLUMNS)}) VALUES ({school_id}, "{isbn}", {available_copies});\n'
    school_book_list.append(books_per_school_list)


##Book_Author
COLUMNS = ["ISBN","author_id"]
for isbn in book_list:
    book_author_list = random.sample(range(1, author_number+1), random.randint(1, 3))
    for author_id in book_author_list:
        data += f'INSERT INTO Book_Author ({",".join(COLUMNS)}) VALUES ("{isbn}", {author_id});\n'


##Book_Category
COLUMNS = ["ISBN","category_id"]
for isbn in book_list:
    book_category_list = random.sample(range(1, category_number+1), random.randint(1, 4))
    for category_id in book_category_list:
        data += f'INSERT INTO Book_Category ({",".join(COLUMNS)}) VALUES ("{isbn}", {category_id});\n'


##Book_Keyword
COLUMNS = ["ISBN","keyword_id"]
for isbn in book_list:
    book_keyword_list = random.sample(range(1, keyword_number+1), random.randint(1, 5))
    for keyword_id in book_keyword_list:
        data += f'INSERT INTO Book_Keyword ({",".join(COLUMNS)}) VALUES ("{isbn}", {keyword_id});\n'


##Operator_Registration
COLUMNS = ["username", "password", "first_name", "last_name", "email", "school_id"]
operator_registration_number = 3
for i in range(operator_registration_number):
    username = fake.unique.user_name()
    if len(username) > 30:
        username = username[:30]
    password = fake.password(special_chars='@#$%^&*()=+"')
    if len(password) > 30:
        password = password[:30]
    first_name = fake.first_name()
    last_name = fake.last_name()
    email = fake.unique.email()
    school_id = random.randint(1, school_number)
    data += f'INSERT INTO Operator_Registration ({",".join(COLUMNS)}) VALUES ("{username}", "{password}", "{first_name}", "{last_name}", "{email}", {school_id});\n'


##User-Student_Registration
COLUMNS = ["username", "password", "user_role", "first_name", "last_name", "email", "date_of_birth", "school_id"]
student_registration_number = 10
for i in range(student_registration_number):
    username = fake.unique.user_name()
    if len(username) > 30:
        username = username[:30]
    password = fake.password(special_chars='@#$%^&*()=+"')
    if len(password) > 30:
        password = password[:30]
    first_name = fake.first_name()
    last_name = fake.last_name()
    email = fake.unique.email()
    date_of_birth = fake.date_of_birth(minimum_age=6, maximum_age=22)
    school_id = random.randint(1, school_number)
    data += f'INSERT INTO User_Registration ({",".join(COLUMNS)}) VALUES ("{username}", "{password}", "student", "{first_name}", "{last_name}", "{email}", "{date_of_birth}", {school_id});\n'


##User-Professor_Registration
COLUMNS = ["username", "password", "user_role", "first_name", "last_name", "email", "date_of_birth", "school_id"]
professor_registration_number = 5
for i in range(professor_registration_number):
    username = fake.unique.user_name()
    if len(username) > 30:
        username = username[:30]
    password = fake.password(special_chars='@#$%^&*()=+"')
    if len(password) > 30:
        password = password[:30]
    first_name = fake.first_name()
    last_name = fake.last_name()
    email = fake.unique.email()
    date_of_birth = fake.date_of_birth(minimum_age=25, maximum_age=70)
    school_id = random.randint(1, school_number)
    data += f'INSERT INTO User_Registration ({",".join(COLUMNS)}) VALUES ("{username}", "{password}", "professor", "{first_name}", "{last_name}", "{email}", "{date_of_birth}", {school_id});\n'


##Pending_Review
COLUMNS = ["rating", "review_text", "review_date", "ISBN", "user_id"]
pending_review_number = 5
review_users = random.sample(range(1,user_number), pending_review_number)
for user_id in review_users:
    review_books_list = random.sample(book_list, random.randint(0,3))
    for isbn in review_books_list:
        rating = random.randint(1, 5)
        review_text = fake.text()[:300]
        review_date = fake.date_between(start_date='-3y', end_date='today')
        data += f'INSERT INTO Pending_Review ({",".join(COLUMNS)}) VALUES ("{rating}", "{review_text}", "{review_date}", "{isbn}", "{user_id}");\n'


##Borrowing
COLUMNS = ["borrowing_date", "due_date", "return_date", "user_id", "ISBN", "is_accepted"]
borrowing_number = 500
borrowing_users = random.sample(range(1,user_number), borrowing_number)
for user_id in borrowing_users:
    school_id = user_school_list[user_id-1]
    borrowing_books_list = random.sample(school_book_list[school_id-1], random.randint(0,10))
    for isbn in borrowing_books_list:
        borrowing_date = fake.date_between(start_date='-3y', end_date='-10d')
        due_date = borrowing_date + timedelta(days=7)
        return_date = borrowing_date + timedelta(days=random.randint(1, 10))
        data += f'INSERT INTO Borrowing ({",".join(COLUMNS)}) VALUES ("{borrowing_date}", "{due_date}", "{return_date}", {user_id}, "{isbn}", TRUE);\n'



today = datetime.now().date()
start_date1 = today - timedelta(days=7)
end_date1 = today
start_date2 = today - timedelta(days=10)
end_date2 = today - timedelta(days=8)
probabilities_date = [0.8, 0.2]
accepted_ranges = ['TRUE', 'FALSE']
probabilities_accepted = [0.9, 0.1]
borrowing_number = 200
borrowing_users = random.sample(range(1,user_number), borrowing_number)
for user_id in borrowing_users:
    school_id = user_school_list[user_id-1]
    if(user_id > student_number):
        max_books = 1
    else:
        max_books = 2
    books_borrowed = random.randint(1,max_books)
    borrowing_books_list = random.sample(school_book_list[school_id-1], books_borrowed)
    for isbn in borrowing_books_list:
        date_range1 = fake.date_between(start_date=start_date1, end_date=end_date1)
        date_range2 = fake.date_between(start_date=start_date2, end_date=end_date2)
        date_ranges = [date_range1, date_range2]
        borrowing_date = random.choices(date_ranges, probabilities_date)[0]
        due_date = borrowing_date + timedelta(days=7)
        is_accepted = random.choices(accepted_ranges, probabilities_accepted)[0]
        data += f'INSERT INTO Borrowing ({",".join(COLUMNS)}) VALUES ("{borrowing_date}", "{due_date}", NULL, {user_id}, "{isbn}", {is_accepted});\n'
        data += f'UPDATE User SET borrowing_number = {books_borrowed} WHERE user_id = {user_id};\n'


##Reservation
COLUMNS = ["reservation_date", "user_id", "ISBN"]
reservation_number = 50
reservation_users = random.sample(range(1,user_number+1), reservation_number)
for user_id in reservation_users:
    school_id = user_school_list[user_id-1]
    if(user_id > student_number):
        max_books = 1
    else:
        max_books = 2
    books_reserved = random.randint(1,max_books)
    reservation_books_list = random.sample(school_book_list[school_id-1], books_reserved)
    for isbn in reservation_books_list:
        reservation_date = fake.date_between(start_date='-6d', end_date='today')
        data += f'INSERT INTO Reservation ({",".join(COLUMNS)}) VALUES ("{reservation_date}", "{user_id}", "{isbn}");\n'
        data += f'UPDATE User SET reservation_number = {books_reserved} WHERE user_id = {user_id};\n'




f = open(r"C:\Users\nikol\Desktop\University\6th_semester\database_systems\semester_project\library_db\data_generator\data.txt", "w", encoding="utf-8")
f.write(data)    
#print(data)