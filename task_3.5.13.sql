    WITH first_correct_decision (step, student, min_sub_time) AS
         (SELECT step_id, student_name, MIN(submission_time)
            FROM student
                 INNER JOIN step_student
                 USING(student_id)
            WHERE result = 'correct'
         GROUP BY step_id, student_name
         ),
         first_wrong_decision (step, student, max_sub_time) AS
         ( SELECT step_id, student_name, MAX(submission_time)
             FROM student
                  INNER JOIN step_student
                  USING(student_id)
            WHERE result = 'wrong'
         GROUP BY step_id, student_name
         ),
         group1 (gr, step, student) AS
         ( SELECT 'I' AS Группа, step_id, student_name
             FROM student
                  INNER JOIN step_student
                  ON student.student_id = step_student.student_id

                  INNER JOIN first_correct_decision
                  ON step_student.step_id = first_correct_decision.step
                     AND student.student_name = first_correct_decision.student
                  
                  INNER JOIN first_wrong_decision 
                  ON step_student.step_id = first_wrong_decision.step
                     AND student.student_name = first_wrong_decision.student
            WHERE min_sub_time < max_sub_time 
         GROUP BY step_id, student_name
         ),
         group2 (gr, step, student) AS
         ( SELECT 'II' AS Группа, step_id, student_name
             FROM student
                  INNER JOIN step_student
                  USING(student_id)
            WHERE result = 'correct'
         GROUP BY step_id, student_name
           HAVING COUNT(result) > 1
         ),
         all_attempts_in_step (step, student, countstep) AS
         (SELECT step_id, student_name, COUNT(result)
            FROM student
                 INNER JOIN step_student
                 USING(student_id)
         GROUP BY step_id, student_name
         ),
         wrong_attempts_in_step (step, student, countwrongstep) AS
         ( SELECT step_id, student_name, COUNT(result)
             FROM student
                  INNER JOIN step_student
                  USING(student_id)
            WHERE result = 'wrong'
         GROUP BY step_id, student_name
         ),
         group3 (gr, step, student) AS
         (SELECT 'III' AS Группа, all_attempts_in_step.step, all_attempts_in_step.student
            FROM all_attempts_in_step
                 LEFT JOIN wrong_attempts_in_step 
                 ON all_attempts_in_step.step = wrong_attempts_in_step.step
                    AND all_attempts_in_step.student = wrong_attempts_in_step.student
           WHERE countwrongstep = countstep
         )
    
  SELECT gr AS Группа,
         student AS Студент,
         COUNT(step) AS Количество_шагов 
    FROM group1
GROUP BY student 
   
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