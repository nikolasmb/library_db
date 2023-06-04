--CREATE TABLES


CREATE DATABASE IF NOT EXISTS Library;
USE Library;


CREATE TABLE IF NOT EXISTS Admin
(
  admin_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(30) NOT NULL UNIQUE,
  password VARCHAR(30) NOT NULL,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(60) NOT NULL,
  date_of_birth DATE NOT NULL,
  PRIMARY KEY (admin_id)
);


CREATE TABLE IF NOT EXISTS Operator
(
  operator_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(30) NOT NULL UNIQUE,
  password VARCHAR(30) NOT NULL,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(60) NOT NULL,
  date_of_birth DATE NOT NULL,
  PRIMARY KEY (operator_id)
);


CREATE TABLE IF NOT EXISTS School
(
  school_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  school_name VARCHAR(100) NOT NULL UNIQUE,
  address_name VARCHAR(50) NOT NULL,
  address_number INT UNSIGNED NOT NULL,
  city VARCHAR(50) NOT NULL,
  postal_code CHAR(5) NOT NULL,
  phone_number VARCHAR(30) NOT NULL,
  email VARCHAR(60) NOT NULL UNIQUE,
  school_director VARCHAR(100) NOT NULL,
  operator_id INT UNSIGNED UNIQUE,
  PRIMARY KEY (school_id),
  CONSTRAINT fk_school_operator_id FOREIGN KEY (operator_id) REFERENCES Operator(operator_id) ON DELETE RESTRICT ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS User
(
  user_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(30) NOT NULL UNIQUE,
  password VARCHAR(30) NOT NULL,
  user_role ENUM('student', 'professor') NOT NULL,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(60) NOT NULL,
  date_of_birth DATE NOT NULL,
  borrowing_number INT UNSIGNED NOT NULL DEFAULT 0,
  reservation_number INT UNSIGNED NOT NULL DEFAULT 0,
  school_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (user_id),
  CONSTRAINT fk_user_school_id FOREIGN KEY (school_id) REFERENCES School(school_id) ON DELETE RESTRICT ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS Book
(
  ISBN CHAR(13) NOT NULL,
  title VARCHAR(60) NOT NULL,
  publisher VARCHAR(50) NOT NULL,
  pages_number INT UNSIGNED NOT NULL,
  summary TEXT(3000) NOT NULL,
  image_url VARCHAR(1000) NOT NULL,
  language VARCHAR(50) NOT NULL,
  PRIMARY KEY (ISBN),
  CONSTRAINT chk_ISBN CHECK (ISBN REGEXP '^[0-9]{13}$')
);


CREATE TABLE IF NOT EXISTS Category
(
  category_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  category_name VARCHAR(60) NOT NULL UNIQUE,
  PRIMARY KEY (category_id)
);


CREATE TABLE IF NOT EXISTS Author
(
  author_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  PRIMARY KEY (author_id)
);


CREATE TABLE IF NOT EXISTS Keyword
(
  keyword_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  keyword_name VARCHAR(50) NOT NULL UNIQUE,
  PRIMARY KEY (keyword_id)
);


CREATE TABLE IF NOT EXISTS Review
(
  review_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  rating INT UNSIGNED NOT NULL,
  review_text TEXT(1500) NOT NULL,
  review_date DATE NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  ISBN CHAR(13) NOT NULL,
  PRIMARY KEY (review_id),
  CONSTRAINT fk_review_user_id FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_review_ISBN FOREIGN KEY (ISBN) REFERENCES Book(ISBN) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Reservation
(
  reservation_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  reservation_date DATE NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  ISBN CHAR(13) NOT NULL,
  PRIMARY KEY (reservation_id),
  CONSTRAINT fk_reservation_user_id FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_reservation_ISBN FOREIGN KEY (ISBN) REFERENCES Book(ISBN) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Borrowing
(
  borrowing_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  borrowing_date DATE NOT NULL,
  due_date DATE NOT NULL,
  return_date DATE DEFAULT NULL,
  user_id INT UNSIGNED NOT NULL,
  ISBN CHAR(13) NOT NULL,
  is_accepted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (borrowing_id),
  CONSTRAINT fk_borrowing_user_id FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_borrowing_ISBN FOREIGN KEY (ISBN) REFERENCES Book(ISBN) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS School_Book
(
  school_id INT UNSIGNED NOT NULL,
  ISBN CHAR(13) NOT NULL,
  available_copies INT UNSIGNED NOT NULL,
  PRIMARY KEY (school_id, ISBN),
  CONSTRAINT fk_book_school_id FOREIGN KEY (school_id) REFERENCES School(school_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_school_ISBN FOREIGN KEY (ISBN) REFERENCES Book(ISBN) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Book_Author
(
  ISBN CHAR(13) NOT NULL,
  author_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (ISBN, author_id),
  CONSTRAINT fk_author_ISBN FOREIGN KEY (ISBN) REFERENCES Book(ISBN) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_book_author_id FOREIGN KEY (author_id) REFERENCES Author(author_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Book_Category
(
  ISBN CHAR(13) NOT NULL,
  category_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (ISBN, category_id),
  CONSTRAINT fk_category_ISBN FOREIGN KEY (ISBN) REFERENCES Book(ISBN) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_book_category_id FOREIGN KEY (category_id) REFERENCES Category(category_id) ON DELETE RESTRICT ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS Book_Keyword
(
  ISBN CHAR(13) NOT NULL,
  keyword_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (ISBN, keyword_id),
  CONSTRAINT fk_keyword_ISBN FOREIGN KEY (ISBN) REFERENCES Book(ISBN) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_book_keyword_id FOREIGN KEY (keyword_id) REFERENCES Keyword(keyword_id) ON DELETE RESTRICT ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS Operator_Registration
(
  operator_registration_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(30) NOT NULL UNIQUE,
  password VARCHAR(30) NOT NULL,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(60) NOT NULL,
  date_of_birth DATE NOT NULL,
  school_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (operator_registration_id),
  CONSTRAINT fk_operator_reg_school_id FOREIGN KEY (school_id) REFERENCES School(school_id) ON DELETE RESTRICT ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS User_Registration
(
  user_registration_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(30) NOT NULL UNIQUE,
  password VARCHAR(30) NOT NULL,
  user_role ENUM('student', 'professor') NOT NULL,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(60) NOT NULL,
  date_of_birth DATE NOT NULL,
  school_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (user_registration_id),
  CONSTRAINT fk_user_reg_school_id FOREIGN KEY (school_id) REFERENCES School(school_id) ON DELETE RESTRICT ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS Pending_Review
(
  pending_review_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  rating INT UNSIGNED NOT NULL,
  review_text TEXT(1500) NOT NULL,
  review_date DATE NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  ISBN CHAR(13) NOT NULL,
  PRIMARY KEY (pending_review_id),
  CONSTRAINT fk_pending_review_user_id FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pending_review_ISBN FOREIGN KEY (ISBN) REFERENCES Book(ISBN) ON DELETE RESTRICT ON UPDATE CASCADE
);


--CREATE INDEXES

CREATE INDEX idx_title ON Book (title); 
CREATE INDEX idx_first_name_author ON Author (first_name);
CREATE INDEX idx_last_name_author ON Author (last_name);
CREATE INDEX idx_category_name ON Category (category_name);