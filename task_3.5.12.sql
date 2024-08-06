   SET @average_time = (SELECT CEIL(AVG(submission_time - attempt_time)) 
                          FROM step_student 
                               INNER JOIN student 
                               USING(student_id)
                         WHERE student_name = 'student_59' 
                               AND submission_time - attempt_time < 3600);
  
  WITH get_student (student, step, attempt_number, result, attempt_time) AS
       (SELECT student_name, 
               CONCAT(module_id, '.', lesson_position, '.', step_position),
               ROW_NUMBER() OVER (PARTITION BY module_id, lesson_position, step_position ORDER BY submission_time),
               result,
               submission_time - attempt_time
          FROM step_student 
               INNER JOIN step USING(step_id)
               INNER JOIN lesson USING(lesson_id)
               INNER JOIN student USING(student_id)
         WHERE student_name = 'student_59'
       ),
       get_student1 (student, step, attempt_number, result, attempt_time) AS
       (SELECT student, step, attempt_number, result, 
               IF(attempt_time > 3600, @average_time, attempt_time)
          FROM get_student
       ),
       get_total_time_attempts (step, total_time) AS
       ( SELECT step, SUM(attempt_time)
           FROM get_student1
       GROUP BY step
       )
      
SELECT student AS Студент, 
       step AS Шаг, 
       attempt_number AS Номер_попытки, 
       result AS Результат, 
       SEC_TO_TIME(attempt_time) AS Время_попытки, 
       ROUND(attempt_time / total_time * 100, 2) AS Относительное_время
  FROM get_student1 
       INNER JOIN get_total_time_attempts 
       USING(step)