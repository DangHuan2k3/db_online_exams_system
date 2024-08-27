-- 1. Retrieve a list of all students who have taken at least one exam. For each student, display their full name, email, and the total number of exams taken.
  SELECT users.full_name, users.email, COUNT(results.id)
  FROM students
    JOIN users ON  students.user_id = user.id
    JOIN results ON results.student_id = students.id
  GROUP BY users.full_name, users.email
  HAVING COUNT(results.id) > 1
-- 2. Find the top 5 highest-scoring students in an exam (9851). Display the student's full name, exam name, and their score. Sort the results by exam name and score in descending order.
  SELECT u.full_name, e.name, r.score
  FROM students AS s
    JOIN results AS r ON r.student_id = s.id 
    JOIN users AS u ON s.user_id = u.id
    JOIN exams AS e ON e.id = r.exam_id
  WHERE r.exam_id = '9851'
  ORDER BY score DESC
  LIMIT 5

-- 3. List all exams for a given class, including the exam name, teacher's full name, and the scheduled start and end date for that exam. Only show exams that are public.
  SELECT c, e.name, u.full_name, ec.start_time, ec.end_time
  FROM classes AS c
    JOIN exams_classes AS ec ON ec.class_id = c.id
    JOIN exams AS e ON ec.exam_id = e.id
    JOIN teachers AS t ON e.teacher_id = t.id
    JOIN users AS u ON t.user_id = u.id
  WHERE c.id = '92' AND e.is_public = True
-- 4. Query the average score for each exam. Display the exam name, the teacher's full name, and the average score of students who participated in the exam.
  SELECT e.id AS exam_id, e.name AS exam_name, u.full_name AS teacher_name, COALESCE(AVG(r.score), 0) AS average_score
  FROM exams AS e
    LEFT JOIN results AS r ON r.exam_id = e.id
    JOIN teachers AS t ON e.teacher_id = t.id
    JOIN users AS u ON t.user_id = u.id
  GROUP BY e.id,  e.name, u.full_name
  ORDER BY e.id
-- 5. Retrieve a list of students who have taken exams but have not passed (e.g., with a score below a passing threshold). Display the student's full name, the exam name, and their score.
  SELECT
    u.full_name AS student_name,
    e.name AS exam_name,
    r.score
  FROM students s
    JOIN users AS u ON s.user_id = u.id
    JOIN results AS r ON s.id = r.student_id
    JOIN exams AS e ON r.exam_id = e.id
  WHERE r.score < 60 -- Assuming 60 is the passing threshold
  ORDER BY u.full_name, e.name;
-- 6. Find the top 3 most popular classes based on the number of students enrolled. Display the class name and the total number of students.
  SELECT 
    c.name,
    count(c.id)
  FROM classes AS c
    JOIN students_classes AS sc ON sc.class_id = c.id
    JOIN students AS s ON sc.student_id = s.id
  GROUP BY c.id 
  ORDER BY count(c.id) DESC
  LIMIT 5

-- 7. Retrieve a list of exams along with their associated classes and the total number of students who took the exam. Only display exams that have more than 20 participants.
  
-- 8. List all students who have taken an exam multiple times but achieved different scores. Display the student's full name, the exam name, and their scores for each attempt.
  SELECT u.full_name, e.name, r.score
  FROM students as s
    JOIN users as u ON s.user_id = u.id
    JOIN results as r ON r.student_id = s.id
    JOIN exams as e ON e.id = r.exam_id
  WHERE s.id IN (
    SELECT r.student_id
    FROM results as r
      JOIN exams as e ON r.exam_id = e.id
    GROUP BY r.student_id, r.exam_id
    HAVING count(r.student_id) > 1
    AND max(r.score) <> min(r.score)
  )

-- 9. Retrieve a list of all exams created by a specific teacher. Display the exam name, the number of questions in the exam, and the total number of students who have taken the exam.
  SELECT e.id, count(eq.question_id), count(DISTINCT r.student_id)
  FROM exams as e
    LEFT JOIN exams_questions as eq ON e.id = eq.exam_id
    LEFT JOIN results as r ON e.id = r.exam_id
  WHERE e.teacher_id = 47398
  GROUP BY e.id

-- 10. Find all students who have completed an exam but did not answer any questions correctly. Display the student's full name, exam name, and the total number of questions they got wrong. 
  SELECT u.full_name, e.name
  FROM students AS s
    JOIN users AS u ON s.user_id = u.id
    JOIN results AS r ON s.id = r.student_id
    JOIN exams AS e ON r.exam_id = e.id
    JOIN history_answers AS ha ON r.id = ha.result_id
    JOIN answers AS a ON ha.answer_id = a.id
  WHERE r.id in (
    SELECT r2.id
    FROM results AS r2
      JOIN history_answers AS ha2 ON r2.id = ha2.result_id
      JOIN answers a2 ON ha2.answer_id = a2.id
    WHERE a2.is_correct = TRUE
    GROUP BY r2.id
    HAVING COUNT(a2.id) = 0
  )
  GROUP BY u.full_name, e.name
  ORDER BY u.full_name, e.name

-- 11. List all questions for a given exam, including the question content, the number of students who answered the question correctly, and the total number of students who attempted the question.

-- 12. Retrieve a list of all classes that have exams scheduled within the next 30 days. For each class, display the class name, the exam name, the scheduled date, and the teacher's full name.
  SELECT classes.name, exams.name, exams_classes.start_time, users.full_name
  FROM classes
    JOIN exams_classes ON classes.id = exams_classes.class_id
    JOIN exams ON exams.id = exams_classes.exam_id
    JOIN teachers ON exams.teacher_id = teachers.id
    JOIN users ON users.id = teachers.user_id
  WHERE exams_classes.start_time > date '1, 2, 1908' and exams_classes.start_time < date '1, 2, 1908' + INTERVAL '30 day'
  ORDER BY exams_classes.start_time
-- 13. Find all exams that have been available for more than 3 months but have not yet been taken by any students. Display the exam name, the class name, and the teacher's full name.

-- 14. List all students who have attempted more than 50% of the questions on any exam but failed to pass the exam (below the passing threshold). Display their full name, exam name, and their score.

-- 15. Retrieve a list of questions that are frequently answered incorrectly by students. Display the question content, the total number of incorrect answers, and the total number of attempts. Only include questions with a failure rate above 60%.