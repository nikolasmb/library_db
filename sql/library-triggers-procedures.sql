--CREATE TRIGGERS / PROCEDURES


--Unique username for users
DELIMITER //
CREATE TRIGGER trg_check_unique_user_username
BEFORE INSERT ON User
FOR EACH ROW
BEGIN
  IF EXISTS 
    (SELECT * FROM User WHERE username = NEW.username)
  OR EXISTS 
    (SELECT * FROM Operator WHERE username = NEW.username)
  OR EXISTS 
    (SELECT * FROM Admin WHERE username = NEW.username)
  THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username already exists';
  END IF;
END //
DELIMITER ;


--Unique username for user registartion
DELIMITER //
CREATE TRIGGER trg_check_unique_user_registration_username
BEFORE INSERT ON User_Registration
FOR EACH ROW
BEGIN
  IF EXISTS 
    (SELECT * FROM User WHERE username = NEW.username)
  OR EXISTS 
    (SELECT * FROM Operator WHERE username = NEW.username)
  OR EXISTS 
    (SELECT * FROM Admin WHERE username = NEW.username)
  OR EXISTS
    (SELECT * FROM User_Registration WHERE username = NEW.username)
  OR EXISTS
    (SELECT * FROM Operator_Registration WHERE username = NEW.username)
  THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username already exists';
  END IF;
END //
DELIMITER ;


--Unique username for operators
DELIMITER //
CREATE TRIGGER trg_check_unique_operator_username
BEFORE INSERT ON Operator
FOR EACH ROW
BEGIN
  IF EXISTS 
    (SELECT * FROM User WHERE username = NEW.username)
  OR EXISTS 
    (SELECT * FROM Operator WHERE username = NEW.username)
  OR EXISTS 
    (SELECT * FROM Admin WHERE username = NEW.username)
  THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username already exists';
  END IF;
END //
DELIMITER ;


--Unique username for operator registration
DELIMITER //
CREATE TRIGGER trg_check_unique_operator_registration_username
BEFORE INSERT ON Operator_Registration
FOR EACH ROW
BEGIN
  IF EXISTS 
    (SELECT * FROM User WHERE username = NEW.username)
  OR EXISTS 
    (SELECT * FROM Operator WHERE username = NEW.username)
  OR EXISTS 
    (SELECT * FROM Admin WHERE username = NEW.username)
  OR EXISTS
    (SELECT * FROM User_Registration WHERE username = NEW.username)
  OR EXISTS
    (SELECT * FROM Operator_Registration WHERE username = NEW.username)
  THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username already exists';
  END IF;
END //
DELIMITER ;


--Unique username for admins
DELIMITER //
CREATE TRIGGER trg_check_unique_admin_username
BEFORE INSERT ON Admin
FOR EACH ROW
BEGIN
  IF EXISTS 
    (SELECT * FROM User WHERE username = NEW.username)
  OR EXISTS 
    (SELECT * FROM Operator WHERE username = NEW.username)
  OR EXISTS 
    (SELECT * FROM Admin WHERE username = NEW.username)
  THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username already exists';
  END IF;
END //
DELIMITER ;


--Unique email for users
DELIMITER //
CREATE TRIGGER trg_check_unique_user_email
BEFORE INSERT ON User
FOR EACH ROW
BEGIN
  IF EXISTS 
    (SELECT * FROM User WHERE email = NEW.email)
  OR EXISTS 
    (SELECT * FROM Operator WHERE email = NEW.email)
  OR EXISTS 
    (SELECT * FROM Admin WHERE email = NEW.email)
  THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already exists';
  END IF;
END //
DELIMITER ;


--Unique email for user registartion
DELIMITER //
CREATE TRIGGER trg_check_unique_user_registration_email
BEFORE INSERT ON User_Registration
FOR EACH ROW
BEGIN
  IF EXISTS 
    (SELECT * FROM User WHERE email = NEW.email)
  OR EXISTS 
    (SELECT * FROM Operator WHERE email = NEW.email)
  OR EXISTS 
    (SELECT * FROM Admin WHERE email = NEW.email)
  OR EXISTS
    (SELECT * FROM User_Registration WHERE email = NEW.email)
  OR EXISTS
    (SELECT * FROM Operator_Registration WHERE email = NEW.email)
  THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already exists';
  END IF;
END //
DELIMITER ;


--Unique email for operators
DELIMITER //
CREATE TRIGGER trg_check_unique_operator_email
BEFORE INSERT ON Operator
FOR EACH ROW
BEGIN
  IF EXISTS 
    (SELECT * FROM User WHERE email = NEW.email)
  OR EXISTS 
    (SELECT * FROM Operator WHERE email = NEW.email)
  OR EXISTS 
    (SELECT * FROM Admin WHERE email = NEW.email)
  THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already exists';
  END IF;
END //
DELIMITER ;


--Unique email for operator registration
DELIMITER //
CREATE TRIGGER trg_check_unique_operator_registration_email
BEFORE INSERT ON Operator_Registration
FOR EACH ROW
BEGIN
  IF EXISTS 
    (SELECT * FROM User WHERE email = NEW.email)
  OR EXISTS 
    (SELECT * FROM Operator WHERE email = NEW.email)
  OR EXISTS 
    (SELECT * FROM Admin WHERE email = NEW.email)
  OR EXISTS
    (SELECT * FROM User_Registration WHERE email = NEW.email)
  OR EXISTS
    (SELECT * FROM Operator_Registration WHERE email = NEW.email)
  THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already exists';
  END IF;
END //
DELIMITER ;


--Unique email for admins
DELIMITER //
CREATE TRIGGER trg_check_unique_admin_email
BEFORE INSERT ON Admin
FOR EACH ROW
BEGIN
  IF EXISTS 
    (SELECT * FROM User WHERE email = NEW.email)
  OR EXISTS 
    (SELECT * FROM Operator WHERE email = NEW.email)
  OR EXISTS 
    (SELECT * FROM Admin WHERE email = NEW.email)
  THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already exists';
  END IF;
END //
DELIMITER ;


--Check if any id number is missing from the admin table before insertion
DELIMITER //
CREATE TRIGGER trg_fill_missing_admin_id
BEFORE INSERT ON Admin
FOR EACH ROW
BEGIN
  DECLARE last_id INT;
  DECLARE missing_id INT;
  
  SELECT MAX(admin_id) INTO last_id FROM Admin;
  SET missing_id = 1;
  while_loop: WHILE missing_id <= last_id DO
    IF NOT EXISTS (SELECT * FROM Admin WHERE admin_id = missing_id) THEN
      SET NEW.admin_id = missing_id;
      LEAVE while_loop;
    END IF;
    SET missing_id = missing_id + 1;
  END WHILE;
END //
DELIMITER ;


--Check if any id number is missing from the operator table before insertion
DELIMITER //
CREATE TRIGGER trg_fill_missing_operator_id
BEFORE INSERT ON Operator
FOR EACH ROW
BEGIN
  DECLARE last_id INT;
  DECLARE missing_id INT;
  
  SELECT MAX(operator_id) INTO last_id FROM Operator;
  SET missing_id = 1;
  while_loop: WHILE missing_id <= last_id DO
    IF NOT EXISTS (SELECT * FROM Operator WHERE operator_id = missing_id) THEN
      SET NEW.operator_id = missing_id;
      LEAVE while_loop;
    END IF;
    SET missing_id = missing_id + 1;
  END WHILE;
END //
DELIMITER ;


--Check if any id number is missing from the school table before insertion
DELIMITER //
CREATE TRIGGER trg_fill_missing_school_id
BEFORE INSERT ON School
FOR EACH ROW
BEGIN
  DECLARE last_id INT;
  DECLARE missing_id INT;
  
  SELECT MAX(school_id) INTO last_id FROM School;
  SET missing_id = 1;
  while_loop: WHILE missing_id <= last_id DO
    IF NOT EXISTS (SELECT * FROM School WHERE school_id = missing_id) THEN
      SET NEW.school_id = missing_id;
      LEAVE while_loop;
    END IF;
    SET missing_id = missing_id + 1;
  END WHILE;
END //
DELIMITER ;


--Check if any id number is missing from the user table before insertion
DELIMITER //
CREATE TRIGGER trg_fill_missing_user_id
BEFORE INSERT ON User
FOR EACH ROW
BEGIN
  DECLARE last_id INT;
  DECLARE missing_id INT;
  
  SELECT MAX(user_id) INTO last_id FROM User;
  SET missing_id = 1;
  while_loop: WHILE missing_id <= last_id DO
    IF NOT EXISTS (SELECT * FROM User WHERE user_id = missing_id) THEN
      SET NEW.user_id = missing_id;
      LEAVE while_loop;
    END IF;
    SET missing_id = missing_id + 1;
  END WHILE;
END //
DELIMITER ;


--Check if any id number is missing from the category table before insertion
DELIMITER //
CREATE TRIGGER trg_fill_missing_category_id
BEFORE INSERT ON Category
FOR EACH ROW
BEGIN
  DECLARE last_id INT;
  DECLARE missing_id INT;
  
  SELECT MAX(category_id) INTO last_id FROM Category;
  SET missing_id = 1;
  while_loop: WHILE missing_id <= last_id DO
    IF NOT EXISTS (SELECT * FROM Category WHERE category_id = missing_id) THEN
      SET NEW.category_id = missing_id;
      LEAVE while_loop;
    END IF;
    SET missing_id = missing_id + 1;
  END WHILE;
END //
DELIMITER ;


--Check if any id number is missing from the author table before insertion
DELIMITER //
CREATE TRIGGER trg_fill_missing_author_id
BEFORE INSERT ON Author
FOR EACH ROW
BEGIN
  DECLARE last_id INT;
  DECLARE missing_id INT;
  
  SELECT MAX(author_id) INTO last_id FROM Author;
  SET missing_id = 1;
  while_loop: WHILE missing_id <= last_id DO
    IF NOT EXISTS (SELECT * FROM Author WHERE author_id = missing_id) THEN
      SET NEW.author_id = missing_id;
      LEAVE while_loop;
    END IF;
    SET missing_id = missing_id + 1;
  END WHILE;
END //
DELIMITER ;


--Check if any id number is missing from the keyword table before insertion
DELIMITER //
CREATE TRIGGER trg_fill_missing_keyword_id
BEFORE INSERT ON Keyword
FOR EACH ROW
BEGIN
  DECLARE last_id INT;
  DECLARE missing_id INT;
  
  SELECT MAX(keyword_id) INTO last_id FROM Keyword;
  SET missing_id = 1;
  while_loop: WHILE missing_id <= last_id DO
    IF NOT EXISTS (SELECT * FROM Keyword WHERE keyword_id = missing_id) THEN
      SET NEW.keyword_id = missing_id;
      LEAVE while_loop;
    END IF;
    SET missing_id = missing_id + 1;
  END WHILE;
END //
DELIMITER ;


--Check if any id number is missing from the review table before insertion
DELIMITER //
CREATE TRIGGER trg_fill_missing_review_id
BEFORE INSERT ON Review
FOR EACH ROW
BEGIN
  DECLARE last_id INT;
  DECLARE missing_id INT;
  
  SELECT MAX(review_id) INTO last_id FROM Review;
  SET missing_id = 1;
  while_loop: WHILE missing_id <= last_id DO
    IF NOT EXISTS (SELECT * FROM Review WHERE review_id = missing_id) THEN
      SET NEW.review_id = missing_id;
      LEAVE while_loop;
    END IF;
    SET missing_id = missing_id + 1;
  END WHILE;
END //
DELIMITER ;


--Check if any id number is missing from the reservation table before insertion
DELIMITER //
CREATE TRIGGER trg_fill_missing_reservation_id
BEFORE INSERT ON Reservation
FOR EACH ROW
BEGIN
  DECLARE last_id INT;
  DECLARE missing_id INT;
  
  SELECT MAX(reservation_id) INTO last_id FROM Reservation;
  SET missing_id = 1;
  while_loop: WHILE missing_id <= last_id DO
    IF NOT EXISTS (SELECT * FROM Reservation WHERE reservation_id = missing_id) THEN
      SET NEW.reservation_id = missing_id;
      LEAVE while_loop;
    END IF;
    SET missing_id = missing_id + 1;
  END WHILE;
END //
DELIMITER ;


--Check if any id number is missing from the Borrowing table before insertion
DELIMITER //
CREATE TRIGGER trg_fill_missing_borrowing_id
BEFORE INSERT ON Borrowing
FOR EACH ROW
BEGIN
  DECLARE last_id INT;
  DECLARE missing_id INT;
  
  SELECT MAX(borrowing_id) INTO last_id FROM Borrowing;
  SET missing_id = 1;
  while_loop: WHILE missing_id <= last_id DO
    IF NOT EXISTS (SELECT * FROM Borrowing WHERE borrowing_id = missing_id) THEN
      SET NEW.borrowing_id = missing_id;
      LEAVE while_loop;
    END IF;
    SET missing_id = missing_id + 1;
  END WHILE;
END //
DELIMITER ;


--Check if any id number is missing from the opreator_registration table before insertion
DELIMITER //
CREATE TRIGGER trg_fill_missing_operator_registration_id
BEFORE INSERT ON Operator_Registration
FOR EACH ROW
BEGIN
  DECLARE last_id INT;
  DECLARE missing_id INT;
  
  SELECT MAX(operator_registration_id) INTO last_id FROM Operator_Registration;
  SET missing_id = 1;
  while_loop: WHILE missing_id <= last_id DO
    IF NOT EXISTS (SELECT * FROM Operator_Registration WHERE operator_registration_id = missing_id) THEN
      SET NEW.operator_registration_id = missing_id;
      LEAVE while_loop;
    END IF;
    SET missing_id = missing_id + 1;
  END WHILE;
END //
DELIMITER ;


--Check if any id number is missing from the user_registration table before insertion
DELIMITER //
CREATE TRIGGER trg_fill_missing_user_registration_id
BEFORE INSERT ON User_Registration
FOR EACH ROW
BEGIN
  DECLARE last_id INT;
  DECLARE missing_id INT;
  
  SELECT MAX(user_registration_id) INTO last_id FROM User_Registration;
  SET missing_id = 1;
  while_loop: WHILE missing_id <= last_id DO
    IF NOT EXISTS (SELECT * FROM User_Registration WHERE user_registration_id = missing_id) THEN
      SET NEW.user_registration_id = missing_id;
      LEAVE while_loop;
    END IF;
    SET missing_id = missing_id + 1;
  END WHILE;
END //
DELIMITER ;


--Check if any id number is missing from the pending_review table before insertion
DELIMITER //
CREATE TRIGGER trg_fill_missing_pending_review_id
BEFORE INSERT ON Pending_Review
FOR EACH ROW
BEGIN
  DECLARE last_id INT;
  DECLARE missing_id INT;
  
  SELECT MAX(pending_review_id) INTO last_id FROM Pending_Review;
  SET missing_id = 1;
  while_loop: WHILE missing_id <= last_id DO
    IF NOT EXISTS (SELECT * FROM Pending_Review WHERE pending_review_id = missing_id) THEN
      SET NEW.pending_review_id = missing_id;
      LEAVE while_loop;
    END IF;
    SET missing_id = missing_id + 1;
  END WHILE;
END //
DELIMITER ;


--Approve pending review
DELIMITER //
CREATE PROCEDURE approve_pending_review (
  IN p_pending_review_id INT UNSIGNED
)
BEGIN
  DECLARE review_count INT UNSIGNED;
  DECLARE p_rating INT UNSIGNED;
  DECLARE p_review_text TEXT(1500);
  DECLARE p_review_date DATE;
  DECLARE p_user_id INT UNSIGNED;
  DECLARE p_ISBN CHAR(13);
  
  SELECT COUNT(*) INTO review_count
  FROM Pending_Review
  WHERE pending_review_id = p_pending_review_id;

  IF review_count > 0 THEN
    SELECT rating, review_text, review_date, user_id, ISBN
    INTO p_rating, p_review_text, p_review_date, p_user_id, p_ISBN
    FROM Pending_Review
    WHERE pending_review_id = p_pending_review_id;

    INSERT INTO Review (rating, review_text, review_date, user_id, ISBN)
    VALUES (p_rating, p_review_text, p_review_date, p_user_id, p_ISBN);

    DELETE FROM Pending_Review WHERE pending_review_id = p_pending_review_id;
  ELSE
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This pending review does not exit';
  END IF;
END //
DELIMITER ;


--Approve user registration
DELIMITER //
CREATE PROCEDURE approve_user_registration ( 
  IN p_user_registration_id INT UNSIGNED 
)
BEGIN
  DECLARE registration_count INT;
  SELECT COUNT(*) INTO registration_count
  FROM User_Registration
  WHERE user_registration_id = p_user_registration_id;

  IF registration_count > 0 THEN
    INSERT INTO User (username, password, user_role, first_name, last_name, email, date_of_birth, school_id)
    SELECT username, password, user_role, first_name, last_name, email, date_of_birth, school_id
    FROM User_Registration
    WHERE user_registration_id = p_user_registration_id;

    DELETE FROM User_Registration WHERE user_registration_id = p_user_registration_id;
  ELSE
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There is no registration with this id';
  END IF;
END //
DELIMITER ;


--Approve operator registration
DELIMITER //
CREATE PROCEDURE approve_operator_registration (
  IN p_operator_registration_id INT UNSIGNED
)
BEGIN
  DECLARE registration_count INT;
  DECLARE new_operator_id INT;
  DECLARE new_school_id INT;

  SELECT COUNT(*) INTO registration_count
  FROM Operator_Registration
  WHERE operator_registration_id = p_operator_registration_id;

  IF registration_count > 0 THEN
    SELECT school_id INTO new_school_id
    FROM Operator_Registration
    WHERE operator_registration_id = p_operator_registration_id;

    IF EXISTS (SELECT operator_id FROM School WHERE school_id = new_school_id AND operator_id IS NOT NULL) THEN
      DELETE FROM Operator_Registration WHERE operator_registration_id = p_operator_registration_id;
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'School already has an operator. Registration rejected';
    ELSE
      INSERT INTO Operator (username, password, first_name, last_name, email, date_of_birth)
      SELECT username, password, first_name, last_name, email, date_of_birth
      FROM Operator_Registration
      WHERE operator_registration_id = p_operator_registration_id;

      SET new_operator_id = LAST_INSERT_ID();

      UPDATE School
      SET operator_id = new_operator_id
      WHERE school_id = new_school_id;
      DELETE FROM Operator_Registration WHERE operator_registration_id = p_operator_registration_id;
    END IF;
  ELSE
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There is no registration with this id';
  END IF;
END //
DELIMITER ;


--Check if school has operator before registration
DELIMITER //
CREATE TRIGGER trg_check_operator_id_before_registration
BEFORE INSERT ON Operator_Registration
FOR EACH ROW
BEGIN
  DECLARE school_operator_id INT;
  
  SELECT operator_id INTO school_operator_id
  FROM School
  WHERE school_id = NEW.school_id;
  
  IF school_operator_id IS NOT NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The school already has an operator assigned.';
  END IF;
END //
DELIMITER ;


--Remove operator from school
DELIMITER //
CREATE PROCEDURE remove_operator_from_school (
  IN p_school_id INT
)
BEGIN
  DECLARE existing_operator_id INT;

  SELECT operator_id INTO existing_operator_id
  FROM School
  WHERE school_id = p_school_id;

  IF existing_operator_id IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This school already has no operator.';
  ELSE
    UPDATE School
    SET operator_id = NULL
    WHERE school_id = p_school_id;
  END IF;
END //
DELIMITER ;


--Check borrowing limit for users
DELIMITER //
CREATE TRIGGER trg_check_borrowing_limit
BEFORE INSERT ON Borrowing
FOR EACH ROW
BEGIN
  DECLARE t_user_role VARCHAR(20);
  DECLARE t_borrowing_number INT UNSIGNED;

  SELECT user_role, borrowing_number INTO t_user_role, t_borrowing_number
  FROM User
  WHERE user_id = NEW.user_id;

  IF t_user_role = 'student' AND t_borrowing_number >= 2 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Students can only have up to 2 borrowings.';
  ELSEIF t_user_role = 'professor' AND t_borrowing_number >= 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Professors can only have up to 1 borrowing.';
  END IF;
END //
DELIMITER ;


--Check reservation limit for users
DELIMITER //
CREATE TRIGGER trg_check_reservation_limit
BEFORE INSERT ON Reservation
FOR EACH ROW
BEGIN
  DECLARE t_user_role VARCHAR(20);
  DECLARE t_reservation_number INT UNSIGNED;

  SELECT user_role, reservation_number INTO t_user_role, t_reservation_number
  FROM User
  WHERE user_id = NEW.user_id;

  IF t_user_role = 'student' AND t_reservation_number >= 2 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Students can only have up to 2 reservations.';
  ELSEIF t_user_role = 'professor' AND t_reservation_number >= 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Professors can only have up to 1 reservation.';
  END IF;
END //


--Check if book is available in school before making a borrowing
DELIMITER //
CREATE TRIGGER trg_check_book_available_borrowing
BEFORE INSERT ON Borrowing
FOR EACH ROW
BEGIN
  DECLARE book_count INT UNSIGNED;
  DECLARE copies INT UNSIGNED;
  DECLARE user_school_id INT UNSIGNED;

  SELECT school_id INTO user_school_id
  FROM User
  WHERE user_id = NEW.user_id;

  SELECT COUNT(*) INTO book_count
  FROM School_Book
  WHERE ISBN = NEW.ISBN AND school_id = user_school_id;

  IF book_count = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book does not exist in this school.';
  ELSE
    SELECT available_copies INTO copies
    FROM School_Book
    WHERE ISBN = NEW.ISBN AND school_id = user_school_id;
    IF copies = 0 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book has no available copies at the moment. You could make a reservation1.';
    END IF;
  END IF;
END //
DELIMITER ;


--Check if book is available in school before making a reservation
DELIMITER //
CREATE TRIGGER trg_check_book_available_reservation
BEFORE INSERT ON Reservation
FOR EACH ROW
BEGIN
  DECLARE book_count INT UNSIGNED;
  DECLARE copies INT UNSIGNED;
  DECLARE user_school_id INT UNSIGNED;

  SELECT school_id INTO user_school_id
  FROM User
  WHERE user_id = NEW.user_id;

  SELECT COUNT(*) INTO book_count
  FROM School_Book
  WHERE ISBN = NEW.ISBN AND school_id = user_school_id;

  IF book_count = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book does not exist in this school.';
  END IF;
END //
DELIMITER ;


--Decrease available copies after borrowing insertion
DELIMITER //
CREATE TRIGGER trg_decrease_available_copies
AFTER INSERT ON Borrowing
FOR EACH ROW
BEGIN
  IF (SELECT available_copies FROM School_Book WHERE school_id = (SELECT school_id FROM User WHERE user_id = NEW.user_id) AND ISBN = NEW.ISBN) > 0 THEN
    UPDATE School_Book
    SET available_copies = available_copies - 1
    WHERE school_id = (SELECT school_id FROM User WHERE user_id = NEW.user_id) AND ISBN = NEW.ISBN;
  ELSE
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No available copies for borrowing.';
  END IF;
END //
DELIMITER ;



--Cancel reservation by user
DELIMITER //
CREATE PROCEDURE cancel_reservation(
  IN p_user_id INT UNSIGNED,
  IN p_reservation_id INT UNSIGNED
)
BEGIN
  DECLARE reservation_count INT UNSIGNED;
  
  SELECT COUNT(*) INTO reservation_count
  FROM Reservation
  WHERE user_id = p_user_id;
  
  IF reservation_count = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You have no reservations.';
  ELSE
    DELETE FROM Reservation
    WHERE reservation_id = p_reservation_id AND user_id = p_user_id;
      
    IF ROW_COUNT() = 0 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid reservation ID.';
    END IF;

    UPDATE User
    SET reservation_number = reservation_number - 1
    WHERE user_id = p_user_id;
  END IF;
END //

DELIMITER ;


--Remove a reservation after 7 days
SET GLOBAL event_scheduler = ON;
CREATE EVENT evt_auto_cancel_reservation
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP + INTERVAL 1 DAY
DO
  DELETE FROM Reservation
  WHERE reservation_date <= CURRENT_DATE - INTERVAL 7 DAY;


--Approve a borrowing
DELIMITER //
CREATE PROCEDURE approvee_borrowing(
  IN p_user_id INT UNSIGNED, 
  IN p_borrowing_id INT UNSIGNED
)
BEGIN
    DECLARE is_accepted_val BOOLEAN;

    SELECT is_accepted INTO is_accepted_val FROM Borrowing WHERE borrowing_id = p_borrowing_id;
    
    IF is_accepted_val = FALSE THEN
        UPDATE Borrowing
        SET is_accepted = TRUE,
            borrowing_date = CURDATE(),
            due_date = DATE_ADD(CURDATE(), INTERVAL 7 DAY)
        WHERE borrowing_id = p_borrowing_id AND user_id = p_user_id;
    ELSE
        SELECT 'Error: Borrowing is already accepted.';
    END IF;
END //
DELIMITER ;

 

--Create a borrowing
DELIMITER //
CREATE PROCEDURE create_borrowing(
  IN p_user_id INT UNSIGNED,
  IN p_ISBN CHAR(13)
)
BEGIN

  INSERT INTO Borrowing (user_id, ISBN, borrowing_date, due_date)
  VALUES (p_user_id, p_ISBN, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY));

  UPDATE User
  SET borrowing_number = borrowing_number + 1
  WHERE user_id = p_user_id;
END //
DELIMITER ;


--Return book
DELIMITER //
CREATE PROCEDURE return_book(
  IN p_user_id INT UNSIGNED,
  IN p_ISBN CHAR(13)
)
BEGIN
  DECLARE return_date_val DATE;

  SELECT return_date INTO return_date_val
  FROM Borrowing
  WHERE user_id = p_user_id AND ISBN = p_ISBN;

  IF return_date_val IS NOT NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Book has already been returned.';
  ELSE
    UPDATE Borrowing
    SET return_date = CURDATE()
    WHERE user_id = p_user_id AND ISBN = p_ISBN;

    UPDATE User
    SET borrowing_number = borrowing_number - 1
    WHERE user_id = p_user_id;

    UPDATE School_Book
    SET available_copies = available_copies + 1
    WHERE ISBN = p_ISBN;

    SELECT 'Book returned successfully.' AS message;
  END IF;
END //
DELIMITER ;



--Create a reservation
DELIMITER //
CREATE PROCEDURE create_reservation(
  IN p_user_id INT UNSIGNED,
  IN p_ISBN CHAR(13)
)
BEGIN
  INSERT INTO Reservation (user_id, ISBN, reservation_date)
  VALUES (p_user_id, p_ISBN, CURDATE());

  UPDATE User
  SET reservation_number = reservation_number + 1
  WHERE user_id = p_user_id;
END //
DELIMITER ;


--Check if user has not returned any books after the due date before making a borrowing
DELIMITER //
CREATE TRIGGER trg_check_if_book_due_date_borrowing
BEFORE INSERT ON Borrowing
FOR EACH ROW
BEGIN
  DECLARE overdue_count INT UNSIGNED;

  SELECT COUNT(*) INTO overdue_count
  FROM Borrowing
  WHERE user_id = NEW.user_id AND return_date IS NULL AND due_date < CURDATE();

  IF overdue_count > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot make a borrowing. You have overdue books.';
  END IF;
END //



--Check if user has not returned any books after the due date before making a reservation
DELIMITER //
CREATE TRIGGER trg_check_if_book_due_date_reservation
BEFORE INSERT ON Reservation
FOR EACH ROW
BEGIN
  DECLARE overdue_count INT UNSIGNED;

  SELECT COUNT(*) INTO overdue_count
  FROM Borrowing
  WHERE user_id = NEW.user_id AND return_date IS NULL AND due_date < CURDATE();

  IF overdue_count > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot make a reservation. You have overdue books.';
  END IF;
END //


--Check if the user is already borrowing a book before making a borrowing of the same book
DELIMITER //
CREATE TRIGGER trg_check_if_book_borrowed1
BEFORE INSERT ON Borrowing
FOR EACH ROW
BEGIN
  DECLARE borrowing_count INT UNSIGNED;

  SELECT COUNT(*) INTO borrowing_count
  FROM Borrowing
  WHERE user_id = NEW.user_id AND ISBN = NEW.ISBN AND return_date IS NULL;

  IF borrowing_count > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot borrow this book. You are already borrowing this book.';
  END IF;
END //
DELIMITER ;



--Check if the user is already borrowing a book before making a reservation of the same book
DELIMITER //
CREATE TRIGGER trg_check_if_book_borrowed2
BEFORE INSERT ON Reservation
FOR EACH ROW
BEGIN
  DECLARE borrowing_count INT UNSIGNED;

  SELECT COUNT(*) INTO borrowing_count
  FROM Borrowing
  WHERE user_id = NEW.user_id AND ISBN = NEW.ISBN AND return_date IS NULL;

  IF borrowing_count > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot make a reservation. You are already borrowing this book.';
  END IF;
END //
DELIMITER ;


--Check if the user is already borrowing a book before making a reservation of the same book
DELIMITER //
CREATE TRIGGER trg_check_if_book_rerserved2
BEFORE INSERT ON Reservation
FOR EACH ROW
BEGIN
  DECLARE reservation_count INT UNSIGNED;

  SELECT COUNT(*) INTO reservation_count
  FROM Reservation
  WHERE user_id = NEW.user_id AND ISBN = NEW.ISBN;

  IF reservation_count > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot make a reservation. You are already reserving this book.';
  END IF;
END //
DELIMITER ;


--Covert a reservation into a borrowing
DELIMITER //
CREATE PROCEDURE convert_reservation_to_borrowing(
  IN p_user_id INT UNSIGNED,
  IN p_ISBN CHAR(13)
)
BEGIN
  DECLARE v_available_copies INT UNSIGNED;
  DECLARE v_school_id INT UNSIGNED;

  SELECT school_id INTO v_school_id
  FROM User
  WHERE user_id = p_user_id;

  SELECT available_copies INTO v_available_copies
  FROM School_Book
  WHERE school_id = v_school_id AND ISBN = p_ISBN;

  IF v_available_copies > 0 THEN
    INSERT INTO Borrowing (user_id, ISBN, borrowing_date, due_date)
    SELECT user_id, ISBN, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY)
    FROM Reservation
    WHERE user_id = p_user_id AND ISBN = p_ISBN;

    UPDATE School_Book
    SET available_copies = available_copies - 1
    WHERE school_id = v_school_id AND ISBN = p_ISBN;

    UPDATE User
    SET borrowing_number = borrowing_number + 1
    WHERE user_id = p_user_id;

    UPDATE User
    SET reservation_number = reservation_number - 1
    WHERE user_id = p_user_id;

    DELETE FROM Reservation
    WHERE user_id = p_user_id AND ISBN = p_ISBN;
  ELSE
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot convert reservation to borrowing. Book is not available.';
  END IF;
END //
DELIMITER ;


#if available copies goes from zero to more then check if there are reservation from this school and convert the oldest to borrowing if exists
DELIMITER //

CREATE TRIGGER convert_zero_copies_to_borrowing_trigger
AFTER UPDATE ON School_Book
FOR EACH ROW
BEGIN
    IF NEW.available_copies > 0 AND OLD.available_copies = 0 THEN
        SET @v_user_id = NULL;
        SET @v_reservation_count = NULL;

        SELECT COUNT(*) INTO @v_reservation_count
        FROM Reservation
        WHERE ISBN = NEW.ISBN AND user_id IN (
            SELECT user_id
            FROM User
            WHERE school_id = NEW.school_id
        );

        IF @v_reservation_count > 0 THEN
            SELECT user_id INTO @v_user_id
            FROM Reservation
            WHERE ISBN = NEW.ISBN AND user_id IN (
                SELECT user_id
                FROM User
                WHERE school_id = NEW.school_id
            )
            ORDER BY reservation_date ASC
            LIMIT 1;

            INSERT INTO Borrowing (user_id, ISBN, borrowing_date, due_date)
            VALUES (@v_user_id, NEW.ISBN, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY));

            UPDATE School_Book
            SET available_copies = available_copies - 1
            WHERE school_id = NEW.school_id AND ISBN = NEW.ISBN;

            UPDATE User
            SET borrowing_number = borrowing_number + 1
            WHERE user_id = @v_user_id;

            UPDATE User
            SET reservation_number = reservation_number - 1
            WHERE user_id = @v_user_id;

            DELETE FROM Reservation
            WHERE user_id = @v_user_id AND ISBN = NEW.ISBN;
        END IF;
    END IF;
END //

DELIMITER ;


--Select a book
DROP PROCEDURE IF EXISTS select_book;
DELIMITER //
CREATE PROCEDURE select_book(
    IN p_school_id INT,
    IN p_ISBN VARCHAR(13)
)
BEGIN
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
    WHERE (sb.school_id = p_school_id OR p_school_id IS NULL)
      AND (b.ISBN = p_ISBN OR p_ISBN IS NULL)
    GROUP BY b.ISBN;
END //
DELIMITER ;