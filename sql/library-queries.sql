--Queries

--4.1.1
drop procedure if exists loan_count_per_school; 
DELIMITER //
CREATE PROCEDURE loan_count_per_school(
  IN p_start_date DATE,
  IN p_end_date DATE
)
BEGIN
  SELECT School.school_id, School.school_name, COUNT(*) AS loan_count
  FROM School
  JOIN User ON User.school_id = School.school_id
  JOIN Borrowing ON Borrowing.user_id = User.user_id
  WHERE (p_start_date IS NULL OR Borrowing.borrowing_date >= p_start_date)
    AND (p_end_date IS NULL OR Borrowing.borrowing_date <= p_end_date)
  GROUP BY School.school_name;
END //

DELIMITER ;


--4.1.2
DELIMITER //
CREATE PROCEDURE find_authors_and_professors_per_category(
  IN p_category_name VARCHAR(60)
)
BEGIN
  DECLARE p_last_year DATE;
  SET p_last_year = DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

  SELECT DISTINCT 'Author' AS role, Author.first_name, Author.last_name, Author.author_id
  FROM Book_Category
  JOIN Book ON Book.ISBN = Book_Category.ISBN
  JOIN Book_Author ON Book_Author.ISBN = Book.ISBN
  JOIN Author ON Author.author_id = Book_Author.author_id
  WHERE Book_Category.category_id = (SELECT category_id FROM Category WHERE category_name = p_category_name)
  ORDER BY Author.last_name, Author.first_name;

  SELECT DISTINCT 'Professor' AS role, User.first_name, User.last_name, User.user_id
  FROM User
  JOIN Borrowing ON Borrowing.user_id = User.user_id
  JOIN Book ON Book.ISBN = Borrowing.ISBN
  JOIN Book_Category ON Book_Category.ISBN = Book.ISBN
  WHERE User.user_role = 'professor'
    AND Book_Category.category_id = (SELECT category_id FROM Category WHERE category_name = p_category_name)
    AND Borrowing.borrowing_date >= p_last_year
  ORDER BY User.last_name, User.first_name;
END //
DELIMITER ;


--4.1.3
DELIMITER //
CREATE PROCEDURE find_young_professors_with_most_books_borrowed()
BEGIN
    DECLARE p_max_books INT;

    SELECT MAX(borrow_count) INTO p_max_books
    FROM (
        SELECT COUNT(*) AS borrow_count
        FROM Borrowing
        JOIN User ON User.user_id = Borrowing.user_id
        WHERE User.user_role = 'professor' AND User.date_of_birth >= DATE_SUB(CURDATE(), INTERVAL 40 YEAR)
        GROUP BY Borrowing.user_id
    ) AS book_counts;

    SELECT User.first_name, User.last_name, User.user_id, User.date_of_birth, COUNT(*) AS borrowed_books
    FROM Borrowing
    JOIN User ON User.user_id = Borrowing.user_id
    WHERE User.user_role = 'professor' AND User.date_of_birth >= DATE_SUB(CURDATE(), INTERVAL 40 YEAR)
    GROUP BY Borrowing.user_id, User.first_name, User.last_name
    HAVING COUNT(*) = p_max_books;
END //
DELIMITER ;


--4.1.4
DELIMITER //
CREATE PROCEDURE find_authors_with_books_not_borrowed()
BEGIN
    SELECT DISTINCT Author.author_id, Author.first_name, Author.last_name
    FROM Author
    LEFT JOIN Book_Author ON Author.author_id = Book_Author.author_id
    LEFT JOIN Borrowing ON Book_Author.ISBN = Borrowing.ISBN
    WHERE Borrowing.borrowing_id IS NULL;
END //
DELIMITER ;


--4.1.5
DELIMITER //
CREATE PROCEDURE FindOperatorsWithSameLoanCount()
BEGIN
    SELECT o1.operator_id, o1.username, o2.operator_id, o2.username, COUNT() AS loan_count
    FROM Borrowing b1
    INNER JOIN Operator o1 ON b1.user_id = o1.operator_id
    INNER JOIN (
        SELECT user_id
        FROM Borrowing
        GROUP BY user_id
        HAVING COUNT() > 20
    ) AS borrowers
    ON b1.user_id = borrowers.user_id
    INNER JOIN Borrowing b2 ON b1.borrowing_date LIKE CONCAT('%', YEAR(b2.borrowing_date))
    INNER JOIN Operator o2 ON b2.user_id = o2.operator_id
    WHERE o1.operator_id <> o2.operator_id
    GROUP BY o1.operator_id, o1.username, o2.operator_id, o2.username
    HAVING COUNT(*) > 20
    ORDER BY loan_count DESC;
END //
DELIMITER ;


--4.1.6
DELIMITER //
CREATE PROCEDURE find_top_category_pairs()
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_category_pairs (
        category_pair VARCHAR(120),
        pair_count INT UNSIGNED
    );
    INSERT INTO temp_category_pairs
    SELECT CONCAT(bc1.category_id, '-', bc2.category_id) AS category_pair, COUNT(*) AS pair_count
    FROM Borrowing b
    INNER JOIN Book_Category bc1 ON b.ISBN = bc1.ISBN
    INNER JOIN Book_Category bc2 ON b.ISBN = bc2.ISBN AND bc1.category_id < bc2.category_id
    GROUP BY category_pair
    ORDER BY pair_count DESC
    LIMIT 3;
    
    SELECT tc.category_pair, c1.category_name, c2.category_name, tc.pair_count
    FROM temp_category_pairs tc
    INNER JOIN Category c1 ON SUBSTRING_INDEX(tc.category_pair, '-', 1) = c1.category_id
    INNER JOIN Category c2 ON SUBSTRING_INDEX(tc.category_pair, '-', -1) = c2.category_id;

    DROP TABLE IF EXISTS temp_category_pairs;
END //
DELIMITER ;


--4.1.7
DELIMITER //
CREATE PROCEDURE find_authors_with_less_books()
BEGIN
  DECLARE max_books INT UNSIGNED;
  DECLARE threshold INT UNSIGNED;

  SELECT COUNT(*) INTO max_books
  FROM Book_Author
  GROUP BY author_id
  ORDER BY COUNT(*) DESC
  LIMIT 1;

  SET threshold = max_books - 5;

  SELECT A.author_id, A.first_name, A.last_name, COUNT(*) AS num_books
  FROM Author A
  JOIN Book_Author BA ON A.author_id = BA.author_id
  GROUP BY A.author_id, A.first_name, A.last_name
  HAVING COUNT(*) = max_books;

  SELECT A.author_id, A.first_name, A.last_name, COUNT(*) AS num_books
  FROM Author A
  JOIN Book_Author BA ON A.author_id = BA.author_id
  GROUP BY A.author_id, A.first_name, A.last_name
  HAVING COUNT(*) <= threshold;
END //
DELIMITER ;


--4.2.1
DELIMITER //
CREATE PROCEDURE operator_find_books(
  IN titleCriteria VARCHAR(100),
  IN authorCriteria VARCHAR(100),
  IN categoryCriteria VARCHAR(100),
  IN copiesCriteria INT UNSIGNED,
  IN p_operator_id INT UNSIGNED
)
BEGIN
  DECLARE schoolId INT UNSIGNED;
  SELECT school_id INTO schoolId
  FROM School
  WHERE operator_id = p_operator_id;

  SELECT DISTINCT b.ISBN, b.title, 
    GROUP_CONCAT(
      DISTINCT IF(a.author_id = ba.author_id, CONCAT(a.first_name, ' ', a.last_name), NULL)
      ORDER BY a.author_id SEPARATOR ', '
    ) AS authors
  FROM Book AS b
  INNER JOIN Book_Author AS ba ON b.ISBN = ba.ISBN
  INNER JOIN Author AS a ON ba.author_id = a.author_id
  INNER JOIN Book_Category AS bc ON b.ISBN = bc.ISBN
  INNER JOIN Category AS c ON bc.category_id = c.category_id
  INNER JOIN School_Book AS sb ON b.ISBN = sb.ISBN
  WHERE (sb.school_id = schoolId OR schoolId IS NULL)
    AND (b.title = titleCriteria OR titleCriteria IS NULL)
    AND (b.ISBN IN (
        SELECT DISTINCT ba.ISBN
        FROM Book_Author AS ba
        INNER JOIN Author AS a ON ba.author_id = a.author_id
        WHERE CONCAT(a.first_name, ' ', a.last_name) = authorCriteria
      ) OR authorCriteria IS NULL)
    AND (c.category_name = categoryCriteria OR categoryCriteria IS NULL)
    AND (sb.available_copies = copiesCriteria OR copiesCriteria IS NULL)
  GROUP BY b.ISBN, b.title
  ORDER BY b.title;
END //
DELIMITER ;


--4.2.2
DROP PROCEDURE IF EXISTS borrower;
DELIMITER //
CREATE PROCEDURE borrower(
  IN firstNameCriteria VARCHAR(50),
  IN lastNameCriteria VARCHAR(50),
  IN delayDaysCriteria INT UNSIGNED,
  IN p_operator_id INT UNSIGNED
)
BEGIN  
  DECLARE schoolIdCriteria INT UNSIGNED;
  SELECT school_id INTO schoolIdCriteria
  FROM School
  WHERE operator_id = p_operator_id;

  SELECT u.first_name, u.last_name, DATEDIFF(NOW(), b.due_date) AS delay_days, u.school_id
  FROM User AS u
  INNER JOIN Borrowing AS b ON u.user_id = b.user_id
  WHERE u.user_id IN (
    SELECT DISTINCT b.user_id
    FROM Borrowing AS b
    WHERE b.return_date IS NULL
      AND DATEDIFF(NOW(), b.due_date) > 0
  )
    AND (u.first_name = firstNameCriteria OR firstNameCriteria IS NULL)
    AND (u.last_name = lastNameCriteria OR lastNameCriteria IS NULL)
    AND (DATEDIFF(NOW(), b.due_date) > delayDaysCriteria OR delayDaysCriteria IS NULL)
    AND (u.school_id = schoolIdCriteria OR schoolIdCriteria IS NULL);
END //
DELIMITER ;


--4.2.3
DELIMITER //
CREATE PROCEDURE FindAverageRatings(
  IN userIdCriteria INT,
  IN categoryCriteria VARCHAR(60),
  IN p_operator_id INT UNSIGNED
)

BEGIN
  DECLARE schoolIdCriteria INT UNSIGNED;
  SELECT school_id INTO schoolIdCriteria
  FROM School
  WHERE operator_id = p_operator_id;

  SELECT b.user_id, u.first_name, u.last_name, c.category_name, AVG(r.rating) AS average_rating
  FROM Borrowing AS b
  INNER JOIN User AS u ON b.user_id = u.user_id
  INNER JOIN Review AS r ON u.user_id = r.user_id
  INNER JOIN Book AS bk ON r.ISBN = bk.ISBN
  INNER JOIN Book_Category AS bc ON bk.ISBN = bc.ISBN
  INNER JOIN Category AS c ON bc.category_id = c.category_id
  WHERE (b.user_id = userIdCriteria OR userIdCriteria IS NULL)
    AND (c.category_name = categoryCriteria OR categoryCriteria IS NULL)
    AND (u.school_id = schoolIdCriteria OR schoolIdCriteria IS NULL)
  GROUP BY u.first_name, u.last_name, c.category_name;
END //
DELIMITER ;


--4.3.1
DELIMITER //
CREATE PROCEDURE book_list(
    IN p_school_id INT,
    IN p_title VARCHAR(60),
    IN p_category_name VARCHAR(60),
    IN p_author_name VARCHAR(100)
)
BEGIN
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
    WHERE (sb.school_id = p_school_id OR p_school_id IS NULL)
      AND (b.title LIKE CONCAT('%', IFNULL(p_title, ''), '%') OR p_title IS NULL)
      AND (b.ISBN IN (
          SELECT DISTINCT bc2.ISBN
          FROM Book_Category bc2
          JOIN Category c2 ON bc2.category_id = c2.category_id
          WHERE c2.category_name = IFNULL(p_category_name, c2.category_name)
        ) OR p_category_name IS NULL)
      AND (b.ISBN IN (
          SELECT DISTINCT ba2.ISBN
          FROM Book_Author ba2
          JOIN Author a2 ON ba2.author_id = a2.author_id
          WHERE CONCAT(a2.first_name, ' ', a2.last_name) = IFNULL(p_author_name, CONCAT(a2.first_name, ' ', a2.last_name))
        ) OR p_author_name IS NULL)
    GROUP BY sb.school_id, b.ISBN;
END //
DELIMITER ;


--4.3.2
DELIMITER //
CREATE PROCEDURE book_list(
    IN p_start_date DATE,
    IN p_end_date VARCHAR(60),
    IN p_category_name VARCHAR(60),
    IN p_author_name VARCHAR(100)
)
BEGIN
  SELECT School.school_name, COUNT(*) AS loan_count
  FROM School
  JOIN User ON User.school_id = School.school_id
  JOIN Borrowing ON Borrowing.user_id = User.user_id
  WHERE (p_start_date IS NULL OR Borrowing.borrowing_date >= p_start_date)
    AND (p_end_date IS NULL OR Borrowing.borrowing_date <= p_end_date)
  GROUP BY School.school_name;
END //
DELIMITER ;

