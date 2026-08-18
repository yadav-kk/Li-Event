-- Seed Data for Literacy India Event & Assessment Management Portal (Direct Custom Auth)

-- 1. Create Centres
insert into public.centres (id, centre_code, centre_name, district, state, address, status) values
('c1000000-0000-0000-0000-000000000001', 'DL-01', 'Delhi Main Centre', 'South West Delhi', 'Delhi', 'Palam Vihar, Delhi', 'active'),
('c1000000-0000-0000-0000-000000000002', 'UP-01', 'Noida Extension Centre', 'Gautam Buddha Nagar', 'Uttar Pradesh', 'Sector 62, Noida', 'active'),
('c1000000-0000-0000-0000-000000000003', 'HR-01', 'Gurugram Sector 45 Centre', 'Gurugram', 'Haryana', 'Sector 45, Gurugram', 'active');

-- 2. Create Users (Admin, Judge and Centre Incharge credentials stored directly in database)
insert into public.users (id, name, email, password, mobile, centre_id, status) values
('10000000-0000-0000-0000-000000000001', 'System Administrator', 'admin@test.com', 'password123', '9876543200', null, 'active'),
('10000000-0000-0000-0000-000000000002', 'Delhi Assessor', 'judge@test.com', 'password123', '9876543201', 'c1000000-0000-0000-0000-000000000001', 'active'),
('10000000-0000-0000-0000-000000000003', 'Noida In-Charge', 'noida@test.com', 'password123', '9876543202', 'c1000000-0000-0000-0000-000000000002', 'active');

-- 3. Map User Roles
insert into public.user_roles (user_id, role_id) values
('10000000-0000-0000-0000-000000000001', 'super_admin'),
('10000000-0000-0000-0000-000000000002', 'judge'),
('10000000-0000-0000-0000-000000000003', 'centre_incharge');

-- Update centres to associate incharge accounts
update public.centres set centre_incharge_id = '10000000-0000-0000-0000-000000000003' where id = 'c1000000-0000-0000-0000-000000000002';

-- 4. Create Schools (using valid hex prefix "a1000000")
insert into public.schools (id, school_name, school_code, centre_id, school_type, address, status) values
('a1000000-0000-0000-0000-000000000001', 'GyanTantra DL Primary', 'GT-DL-01', 'c1000000-0000-0000-0000-000000000001', 'GYANTANTRA', 'Palam Vihar', 'active'),
('a1000000-0000-0000-0000-000000000002', 'Govt Boys School Delhi', 'GB-DL-02', 'c1000000-0000-0000-0000-000000000001', 'GOVERNMENT', 'Dwarka Sector 10', 'active'),
('a1000000-0000-0000-0000-000000000003', 'GyanTantra Noida Primary', 'GT-UP-01', 'c1000000-0000-0000-0000-000000000002', 'GYANTANTRA', 'Sector 62', 'active'),
('a1000000-0000-0000-0000-000000000004', 'Govt Girls School Noida', 'GG-UP-02', 'c1000000-0000-0000-0000-000000000002', 'GOVERNMENT', 'Sector 12 Noida', 'active'),
('a1000000-0000-0000-0000-000000000005', 'GyanTantra Gurugram Primary', 'GT-HR-01', 'c1000000-0000-0000-0000-000000000003', 'GYANTANTRA', 'Sector 45', 'active');

-- 5. Create Batches (using valid hex prefix "b1000000")
insert into public.batches (id, name, academic_year, centre_id) values
('b1000000-0000-0000-0000-000000000001', 'Batch 2026 Class V A', '2026', 'c1000000-0000-0000-0000-000000000001'),
('b1000000-0000-0000-0000-000000000002', 'Batch 2026 Class V B', '2026', 'c1000000-0000-0000-0000-000000000002'),
('b1000000-0000-0000-0000-000000000003', 'Batch 2026 Class V C', '2026', 'c1000000-0000-0000-0000-000000000003');

-- 6. Create Students (using valid hex prefixes "d1000000", "e1000000", "f1000000")
insert into public.students (id, student_id, name, gender, date_of_birth, class, centre_id, school_id, batch_id, guardian_name, guardian_mobile, language, status) values
-- Delhi Centre Students (d1000000)
('d1000000-0000-0000-0000-000000000001', 'GT-LIT-2026-000001', 'Aarav Kumar', 'M', '2016-05-12', 'V', 'c1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000001', 'Ramesh Kumar', '9876543210', 'Hindi', 'active'),
('d1000000-0000-0000-0000-000000000002', 'GT-LIT-2026-000002', 'Aditi Sharma', 'F', '2016-08-22', 'V', 'c1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000001', 'Sunita Sharma', '9876543211', 'Hindi', 'active'),
('d1000000-0000-0000-0000-000000000003', 'GT-LIT-2026-000003', 'Amit Patel', 'M', '2016-01-30', 'V', 'c1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000001', 'Vijay Patel', '9876543212', 'Gujarati', 'active'),
('d1000000-0000-0000-0000-000000000004', 'GT-LIT-2026-000004', 'Ananya Gupta', 'F', '2016-11-15', 'V', 'c1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000001', 'Anil Gupta', '9876543213', 'Hindi', 'active'),
('d1000000-0000-0000-0000-000000000005', 'GT-LIT-2026-000005', 'Arjun Singh', 'M', '2016-03-05', 'V', 'c1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000001', 'Bikram Singh', '9876543214', 'Punjabi', 'active'),
('d1000000-0000-0000-0000-000000000006', 'GT-LIT-2026-000006', 'Divya Verma', 'F', '2016-09-19', 'V', 'c1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000001', 'Suresh Verma', '9876543215', 'Hindi', 'active'),

-- Noida Centre Students (e1000000)
('e1000000-0000-0000-0000-000000000001', 'GT-LIT-2026-000007', 'Ishan Choudhary', 'M', '2016-04-18', 'V', 'c1000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000002', 'Rajesh Choudhary', '9876543216', 'Hindi', 'active'),
('e1000000-0000-0000-0000-000000000002', 'GT-LIT-2026-000008', 'Kavya Nair', 'F', '2016-07-28', 'V', 'c1000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000002', 'Mohan Nair', '9876543217', 'Malayalam', 'active'),
('e1000000-0000-0000-0000-000000000003', 'GT-LIT-2026-000009', 'Nikhil Yadav', 'M', '2016-12-05', 'V', 'c1000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000002', 'Satish Yadav', '9876543218', 'Hindi', 'active'),
('e1000000-0000-0000-0000-000000000004', 'GT-LIT-2026-000010', 'Prisha Rao', 'F', '2016-02-14', 'V', 'c1000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000002', 'Krishna Rao', '9876543219', 'Telugu', 'active'),
('e1000000-0000-0000-0000-000000000005', 'GT-LIT-2026-000011', 'Rahul Mishra', 'M', '2016-06-25', 'V', 'c1000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000002', 'Gopal Mishra', '9876543220', 'Hindi', 'active'),
('e1000000-0000-0000-0000-000000000006', 'GT-LIT-2026-000012', 'Sanya Sen', 'F', '2016-10-31', 'V', 'c1000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000002', 'Pradip Sen', '9876543221', 'Bengali', 'active'),

-- Gurugram Centre Students (f1000000)
('f1000000-0000-0000-0000-000000000001', 'GT-LIT-2026-000013', 'Shreya Joshi', 'F', '2016-05-02', 'V', 'c1000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000005', 'b1000000-0000-0000-0000-000000000003', 'Dinesh Joshi', '9876543222', 'Hindi', 'active'),
('f1000000-0000-0000-0000-000000000002', 'GT-LIT-2026-000014', 'Tejas Patil', 'M', '2016-08-08', 'V', 'c1000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000005', 'b1000000-0000-0000-0000-000000000003', 'Sanjay Patil', '9876543223', 'Marathi', 'active'),
('f1000000-0000-0000-0000-000000000003', 'GT-LIT-2026-000015', 'Varun Reddy', 'M', '2016-11-23', 'V', 'c1000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000005', 'b1000000-0000-0000-0000-000000000003', 'Bhaskar Reddy', '9876543224', 'Telugu', 'active'),
('f1000000-0000-0000-0000-000000000004', 'GT-LIT-2026-000016', 'Yash Wardhan', 'M', '2016-02-28', 'V', 'c1000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000005', 'b1000000-0000-0000-0000-000000000003', 'Sukhdev Wardhan', '9876543225', 'Hindi', 'active');

-- 7. Create Event: GyanTantra se Saksharta – Class V Literacy Challenge 2026
insert into public.events (id, name, event_code, event_type, academic_year, class, description, objective, start_date, end_date, registration_start, registration_end, venue, status) values
('e9000000-0000-0000-0000-000000000001', 'GyanTantra se Saksharta – Class V Literacy Challenge 2026', 'GT-LIT-2026', 'Competition', '2026', 'V', 'World Literacy Day Literacy Challenge event for Class V students.', 'Assess student proficiency in reading, writing and spelling skills.', '2026-09-02', '2026-09-08', '2026-08-15', '2026-08-30', 'Centres & Head Office', 'IN_PROGRESS');

-- 8. Create Stages (using valid hex prefix "e1900000")
insert into public.event_stages (id, event_id, name, description, sequence, start_datetime, end_datetime, configuration_deadline, venue, status, participant_rule, advancement_rule_id, advancement_rule_value) values
-- Stage 1: Centre Level Screening
('e1900000-0001-0000-0000-000000000001', 'e9000000-0000-0000-0000-000000000001', 'Stage 1: Centre Level Screening', 'Screening of students inside their local centres.', 1, '2026-09-02 09:00:00+05:30', '2026-09-04 18:00:00+05:30', '2026-09-01 23:59:59+05:30', 'Local Centres', 'OPEN', 'Class V eligible registered students', 'TOP_N_PER_CENTRE', 5),
-- Stage 2: Head Office Literacy Championship
('e1900000-0002-0000-0000-000000000002', 'e9000000-0000-0000-0000-000000000001', 'Stage 2: Head Office Literacy Championship', 'Final tournament for qualified centre winners.', 2, '2026-09-08 10:00:00+05:30', '2026-09-08 17:00:00+05:30', '2026-09-06 23:59:59+05:30', 'Head Office Auditorium', 'DRAFT', 'Top 5 students per centre from Stage 1', 'TOP_N_OVERALL', 3);

-- 9. Create Assessments for Stage 1 (ea900000)
insert into public.event_assessments (id, stage_id, name, description, assessment_type, sequence, max_marks, start_datetime, end_datetime, configuration_deadline, status, required, judge_assignment_mode) values
('ea900000-0001-0001-0000-000000000001', 'e1900000-0001-0000-0000-000000000001', 'Spelling', 'Spelling screening test (10 words, 2 sentences).', 'SCORE', 1, 20.00, '2026-09-02 10:00:00+05:30', '2026-09-02 12:00:00+05:30', '2026-09-01 23:59:00+05:30', 'ACTIVE', true, 'ALL_JUDGES'),
('ea900000-0001-0002-0000-000000000001', 'e1900000-0001-0000-0000-000000000001', 'Writing', 'Writing assessment evaluating creativity and grammar.', 'SCORE', 2, 20.00, '2026-09-03 10:00:00+05:30', '2026-09-03 12:00:00+05:30', '2026-09-02 23:59:00+05:30', 'ACTIVE', true, 'ALL_JUDGES'),
('ea900000-0001-0003-0000-000000000001', 'e1900000-0001-0000-0000-000000000001', 'Reading', 'Reading fluency and correct pronunciation evaluation.', 'SCORE', 3, 20.00, '2026-09-04 10:00:00+05:30', '2026-09-04 12:00:00+05:30', '2026-09-03 23:59:00+05:30', 'ACTIVE', true, 'ALL_JUDGES');

-- 10. Create Assessment Criteria (ac900001)
-- Spelling Criteria
insert into public.assessment_criteria (id, assessment_id, name, description, max_marks, sequence, required) values
('ac900001-0001-0001-0000-000000000001', 'ea900000-0001-0001-0000-000000000001', '10 Words', 'Evaluation of spelling of 10 vocabulary words.', 10.00, 1, true),
('ac900001-0001-0002-0000-000000000001', 'ea900000-0001-0001-0000-000000000001', 'Sentence 1', 'Evaluation of sentence write-out 1.', 5.00, 2, true),
('ac900001-0001-0003-0000-000000000001', 'ea900000-0001-0001-0000-000000000001', 'Sentence 2', 'Evaluation of sentence write-out 2.', 5.00, 3, true);

-- Writing Criteria
insert into public.assessment_criteria (id, assessment_id, name, description, max_marks, sequence, required) values
('ac900001-0002-0001-0000-000000000001', 'ea900000-0001-0002-0000-000000000001', 'Content & Relevance', 'Relevance of written thoughts to theme.', 5.00, 1, true),
('ac900001-0002-0002-0000-000000000001', 'ea900000-0001-0002-0000-000000000001', 'Creativity & Ideas', 'Originality of expressions.', 5.00, 2, true),
('ac900001-0002-0003-0000-000000000001', 'ea900000-0001-0002-0000-000000000001', 'Sentence Formation & Grammar', 'Proper sentence syntax and grammar.', 4.00, 3, true),
('ac900001-0002-0004-0000-000000000001', 'ea900000-0001-0002-0000-000000000001', 'Vocabulary', 'Use of varied vocabulary.', 3.00, 4, true),
('ac900001-0002-0005-0000-000000000001', 'ea900000-0001-0002-0000-000000000001', 'Spelling & Punctuation', 'Accuracy of spelling & commas/periods.', 3.00, 5, true);

-- Reading Criteria
insert into public.assessment_criteria (id, assessment_id, name, description, max_marks, sequence, required) values
('ac900001-0003-0001-0000-000000000001', 'ea900000-0001-0003-0000-000000000001', 'Accuracy', 'Correct reading of text passages.', 8.00, 1, true),
('ac900001-0003-0002-0000-000000000001', 'ea900000-0001-0003-0000-000000000001', 'Fluency', 'Smoothness and speed of narration.', 5.00, 2, true),
('ac900001-0003-0003-0000-000000000001', 'ea900000-0001-0003-0000-000000000001', 'Pronunciation', 'Clear phonetic articulation of syllables.', 3.00, 3, true),
('ac900001-0003-0004-0000-000000000001', 'ea900000-0001-0003-0000-000000000001', 'Expression', 'Tonal dynamics reflecting meanings.', 2.00, 4, true),
('ac900001-0003-0005-0000-000000000001', 'ea900000-0001-0003-0000-000000000001', 'Confidence', 'Poise and posture during presentation.', 2.00, 5, true);

-- 11. Auto-Register students to the Event (APPROVED status)
insert into public.event_participants (id, event_id, student_id, registration_number, registration_status, eligibility_status, current_stage_id)
select 
    uuid_generate_v5('e9000000-0000-0000-0000-000000000001', id::text) as id,
    'e9000000-0000-0000-0000-000000000001' as event_id,
    id as student_id,
    replace(student_id, 'GT-LIT', 'REG') as registration_number,
    'APPROVED' as registration_status,
    'ELIGIBLE' as eligibility_status,
    'e1900000-0001-0000-0000-000000000001' as current_stage_id
from public.students;

-- 12. Register event participants to Stage 1
insert into public.stage_participants (id, stage_id, participant_id, qualification_status, attendance)
select 
    uuid_generate_v5('e1900000-0001-0000-0000-000000000001', id::text) as id,
    'e1900000-0001-0000-0000-000000000001' as stage_id,
    id as participant_id,
    'PENDING' as qualification_status,
    'PRESENT' as attendance
from public.event_participants;
