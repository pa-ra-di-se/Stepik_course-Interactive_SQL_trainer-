    WITH student_and_step (step_id, student_name, submission_time, result) AS
         ( SELECT step_id, student_name, submission_time, 
                  IF(result = 'correct', 1, 0)
             FROM student
                  INNER JOIN step_student
                  ON student.student_id = step_student.student_id
         ),
         student_and_step1 (step_id, student_name, submission_time, result, feature) AS
         ( SELECT step_id, student_name, submission_time, result,
                  result - LAG(result, 1, result) 
                           OVER (PARTITION BY step_id, student_name ORDER BY submission_time)
             FROM student_and_step
         ),
         group1 (gr, student, step_count) AS
         ( SELECT 'I' AS Группа, student_name, COUNT(step_id)
             FROM student_and_step1
            WHERE feature = -1
         GROUP BY student_name
         ),
         group2 (gr, step, student) AS
         ( SELECT 'II' AS Группа, step_id, student_name
             FROM student_and_step
            WHERE result = 1
         GROUP BY step_id, student_name
           HAVING COUNT(result) > 1
         ),
         group3 (gr, step, student) AS
         ( SELECT 'III' AS Группа, step_id, student_name
             FROM student_and_step
         GROUP BY step_id, student_name
           HAVING SUM(result) = 0
         )
         
  SELECT gr AS Группа,
         student AS Студент,
         step_count AS Количество_шагов 
    FROM group1
   
   UNION 
  
  SELECT gr AS Группа,
         student AS Студент,
         COUNT(step) AS Количество_шагов 
    FROM group2
GROUP BY student

   UNION 
  
  SELECT gr AS Группа,
         student AS Студент,
         COUNT(step) AS Количество_шагов 
    FROM group3
GROUP BY student

ORDER BY Группа, Количество_шагов DESC, Студент