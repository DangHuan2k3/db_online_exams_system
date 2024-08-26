CREATE TABLE "users" (
	"id" SERIAL NOT NULL UNIQUE,
	"email" VARCHAR NOT NULL,
	"password" TEXT NOT NULL,
	"birthdate" DATE NOT NULL,
	"gender" SMALLINT NOT NULL,
	"role" SMALLINT NOT NULL DEFAULT 0,
	"phone_number" VARCHAR NOT NULL,
	PRIMARY KEY("id")
);


CREATE TABLE "teachers" (
	"id" SERIAL NOT NULL UNIQUE,
	"user_id" SERIAL NOT NULL,
	PRIMARY KEY("id")
);


CREATE TABLE "students" (
	"id" SERIAL NOT NULL UNIQUE,
	"user_id" SERIAL NOT NULL,
	"parent_number" VARCHAR NOT NULL,
	PRIMARY KEY("id")
);


CREATE TABLE "online_classes" (
	"id" SERIAL NOT NULL UNIQUE,
	"teacher_id" SERIAL NOT NULL,
	"name" VARCHAR NOT NULL,
	PRIMARY KEY("id")
);


CREATE TABLE "exams" (
	"id" SERIAL NOT NULL UNIQUE,
	"name" VARCHAR NOT NULL,
	-- Belong to minutes
	"time" INTEGER DEFAULT 0,
	"description" TEXT NOT NULL,
	"correct_answer_needed" INTEGER DEFAULT 10,
	"is_public" BOOLEAN DEFAULT TRUE,
	PRIMARY KEY("id")
);
COMMENT ON COLUMN exams.time IS 'Belong to minutes';


CREATE TABLE "questions" (
	"id" SERIAL NOT NULL UNIQUE,
	"teacher_id" SERIAL,
	-- There are some types of questions. 
	"type" SMALLINT NOT NULL,
	"content" TEXT NOT NULL,
	"num_options" SMALLINT DEFAULT 2,
	"option_1" VARCHAR NOT NULL,
	"option_2" VARCHAR NOT NULL,
	"option_3" VARCHAR,
	"option_4" VARCHAR,
	"correct_option" SMALLINT NOT NULL DEFAULT 1,
	PRIMARY KEY("id")
);
COMMENT ON COLUMN questions.type IS 'There are some types of questions. ';


CREATE TABLE "results" (
	"id" SERIAL NOT NULL UNIQUE,
	"student_id" SERIAL NOT NULL,
	"exam_id" SERIAL NOT NULL,
	"grade" DECIMAL NOT NULL,
	"is_pass" BOOLEAN NOT NULL,
	"time_start" DATE NOT NULL,
	"time_taken" INTEGER NOT NULL,
	PRIMARY KEY("id")
);


CREATE TABLE "history_answers" (
	"id" SERIAL NOT NULL UNIQUE,
	"question_id" INTEGER NOT NULL,
	"is_correct" BOOLEAN NOT NULL DEFAULT FALSE,
	"result_id" SERIAL NOT NULL,
	-- Không trả lời câu hỏi
	"selected_option" INTEGER DEFAULT NULL,
	PRIMARY KEY("id")
);
COMMENT ON COLUMN history_answers.selected_option IS 'Không trả lời câu hỏi';


CREATE TABLE "students_online_classes" (
	"student_id" SERIAL NOT NULL,
	"online_class_id" SERIAL NOT NULL,
	PRIMARY KEY("student_id", "online_class_id")
);


CREATE TABLE "exams_questions" (
	"question_id" SERIAL NOT NULL,
	"exam_id" SERIAL NOT NULL,
	PRIMARY KEY("question_id", "exam_id")
);


CREATE TABLE "exams_online_classes" (
	"online_class_id" SERIAL NOT NULL,
	"exam_id" SERIAL NOT NULL,
	"start_at" DATE NOT NULL,
	"end_at" DATE NOT NULL,
	PRIMARY KEY("online_class_id", "exam_id")
);


ALTER TABLE "online_classes"
ADD FOREIGN KEY("teacher_id") REFERENCES "teachers"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "teachers"
ADD FOREIGN KEY("user_id") REFERENCES "users"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "students"
ADD FOREIGN KEY("user_id") REFERENCES "users"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "results"
ADD FOREIGN KEY("student_id") REFERENCES "students"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "results"
ADD FOREIGN KEY("exam_id") REFERENCES "exams"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "students_online_classes"
ADD FOREIGN KEY("student_id") REFERENCES "students"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "students_online_classes"
ADD FOREIGN KEY("online_class_id") REFERENCES "online_classes"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "exams_questions"
ADD FOREIGN KEY("question_id") REFERENCES "questions"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "exams_questions"
ADD FOREIGN KEY("exam_id") REFERENCES "exams"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "exams_online_classes"
ADD FOREIGN KEY("online_class_id") REFERENCES "online_classes"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "exams_online_classes"
ADD FOREIGN KEY("exam_id") REFERENCES "exams"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "history_answers"
ADD FOREIGN KEY("result_id") REFERENCES "results"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "history_answers"
ADD FOREIGN KEY("question_id") REFERENCES "questions"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE "questions"
ADD FOREIGN KEY("teacher_id") REFERENCES "teachers"("id")
ON UPDATE NO ACTION ON DELETE NO ACTION;