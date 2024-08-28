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
  WHERE r.score < 60 
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
  SELECT exams.name, classes.name, COUNT(DISTINCT results.student_id) as total_students_took_exams
  FROM exams
    JOIN exams_classes ON exams_classes.exam_id = exams.id
    JOIN classes ON exams_classes.class_id = classes.id
    JOIN results ON exams.id = results.exam_id
  GROUP BY 
    exams.name, classes.name
  HAVING
    COUNT(DISTINCT results.student_id) > 2

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
  SELECT
      q.content AS question_content,
      COUNT(CASE WHEN a.is_correct = TRUE THEN 1 END) AS num_students_correct,
      COUNT(ha.answer_id) AS total_students_attempted
  FROM exams e
    JOIN exams_questions eq ON e.id = eq.exam_id
    JOIN questions q ON eq.question_id = q.id
    JOIN answers a ON q.id = a.question_id
    LEFT JOIN history_answers ha ON a.id = ha.answer_id
  WHERE e.id = 5438 
  GROUP BY q.id, q.content
  ORDER BY q.id;
  
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
  SELECT exams.name, classes.name, users.full_name as teacher_name
  FROM exams
    JOIN exams_classes ON exams_classes.exam_id = exams.id
    JOIN classes ON exams_classes.class_id = classes.id
    LEFT JOIN results ON results.exam_id = exams.id
  JOIN teachers ON exams.teacher_id = teachers.id
  JOIN users ON teachers.user_id = users.id
  WHERE
    exams.is_public = TRUE 
    AND exams_classes.start_time < date '1, 3, 1908' AND exams_classes.start_time > date '1, 3, 1908' - INTERVAL '30 day'
    AND results.id is NULL -- When left join, with records 
    
-- 14. List all students who have attempted more than 50% of the questions on any exam but failed to pass the exam (below the passing threshold). Display their full name, exam name, and their score.
  WITH exams_questions_count AS (
    SELECT exams.id as exam_id, exams.name as exam_name, COUNT(distinct exams_questions.question_id) as num_questions
    FROM exams
      JOIN exams_questions ON exams_questions.exam_id = exams.id
    GROUP BY 
      exams.id, exams.name
  ),students_count_attempt AS (
    SELECT 
      results.student_id as student_id,
      results.exam_id as exam_id,
      results.score as result_score,
      COUNT(DISTINCT history_answers.answer_id) AS attempted_questions
    FROM students 
      JOIN results ON results.student_id = students.id
      JOIN history_answers ON history_answers.result_id = results.id
      JOIN answers ON history_answers.answer_id = answers.id
      JOIN questions ON answers.question_id = questions.id
    GROUP BY
      results.student_id, results.exam_id, results.score
  )

  SELECT users.full_name, exams_questions_count.exam_name, students_count_attempt.result_score
  FROM students_count_attempt
    JOIN exams_questions_count ON exams_questions_count.exam_id = students_count_attempt.exam_id
    JOIN students ON students_count_attempt.student_id = students.id
    JOIN users ON students.user_id = users.id
  WHERE
    attempted_questions > 0.5 * num_questions
    
-- 15. Retrieve a list of questions that are frequently answered incorrectly by students. Display the question content, the total number of incorrect answers, and the total number of attempts. Only include questions with a failure rate above 60%.

  SELECT 
    questions.content AS question_content,
    COUNT(history_answers.answer_id) AS incorrect_answers,
    COUNT(history_answers.result_id) AS total_attempts,
    (COUNT(history_answers.answer_id) * 1.0 / COUNT(history_answers.result_id)) * 100 AS failure_rate
  FROM questions
    JOIN answers ON questions.id = answers.question_id
    JOIN history_answers ON answers.id = history_answers.answer_id
  WHERE answers.is_correct = FALSE
  GROUP BY 
    questions.id, questions.content
  HAVING 
      (COUNT(history_answers.answer_id) * 1.0 / COUNT(history_answers.result_id)) * 100 > 60;