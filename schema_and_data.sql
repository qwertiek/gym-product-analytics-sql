-- 1. Таблица клиентов
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100),
    registration_date DATE DEFAULT CURRENT_DATE,
    card_number VARCHAR(50) UNIQUE
);

-- 2. Таблица подписок
CREATE TABLE subscriptions (
    id SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(10) CHECK (status IN ('active', 'expired')) DEFAULT 'active',
    price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_subscriptions_clients 
        FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    CONSTRAINT chk_dates CHECK (end_date > start_date)
);

-- 3. Таблица тренеров
CREATE TABLE trainers (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    hire_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(10) CHECK (status IN ('active', 'inactive')) DEFAULT 'active'
);

-- 4. Таблица залов
CREATE TABLE halls (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    type VARCHAR(10) CHECK (type IN ('gym', 'group', 'cardio', 'pool')) DEFAULT 'gym',
    capacity INTEGER DEFAULT 20,
    status VARCHAR(10) CHECK (status IN ('open', 'closed')) DEFAULT 'open'
);

-- 5. Таблица типов занятий
CREATE TABLE class_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    duration_minutes INTEGER NOT NULL,
    category VARCHAR(50)
);

-- 6. Таблица расписания
CREATE TABLE schedule (
    id SERIAL PRIMARY KEY,
    class_type_id INTEGER NOT NULL,
    trainer_id INTEGER,
    hall_id INTEGER NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    max_participants INTEGER DEFAULT 20,
    CONSTRAINT fk_schedule_class_types 
        FOREIGN KEY (class_type_id) REFERENCES class_types(id),
    CONSTRAINT fk_schedule_trainers 
        FOREIGN KEY (trainer_id) REFERENCES trainers(id) ON DELETE SET NULL,
    CONSTRAINT fk_schedule_halls 
        FOREIGN KEY (hall_id) REFERENCES halls(id) ON DELETE CASCADE,
    CONSTRAINT chk_time CHECK (end_time > start_time),
    CONSTRAINT unique_hall_time UNIQUE (hall_id, start_time)
);

-- 7. Таблица специализаций
CREATE TABLE specializations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

-- 8. Таблица посещений (M:M: клиенты ↔ расписание)
CREATE TABLE visits (
    id SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL,
    schedule_id INTEGER NOT NULL,
    subscription_id INTEGER NOT NULL,
    visit_date DATE NOT NULL,
    visit_time TIME NOT NULL,
    status VARCHAR(10) CHECK (status IN ('attended', 'missed')) DEFAULT 'attended',
    CONSTRAINT fk_visits_clients 
        FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    CONSTRAINT fk_visits_schedule 
        FOREIGN KEY (schedule_id) REFERENCES schedule(id) ON DELETE CASCADE,
    CONSTRAINT fk_visits_subscriptions 
        FOREIGN KEY (subscription_id) REFERENCES subscriptions(id),
    CONSTRAINT unique_visit UNIQUE (client_id, schedule_id, visit_date)
);

-- 9. Таблица тренерских специализаций (M:M: тренеры ↔ специализации)
CREATE TABLE trainer_specializations (
    id SERIAL PRIMARY KEY,
    trainer_id INTEGER NOT NULL,
    specialization_id INTEGER NOT NULL,
    certification_date DATE,
    level VARCHAR(10) CHECK (level IN ('basic', 'advanced', 'expert')) DEFAULT 'basic',
    CONSTRAINT fk_trainer_spec_trainers 
        FOREIGN KEY (trainer_id) REFERENCES trainers(id) ON DELETE CASCADE,
    CONSTRAINT fk_trainer_spec_specializations 
        FOREIGN KEY (specialization_id) REFERENCES specializations(id) ON DELETE CASCADE,
    CONSTRAINT unique_trainer_spec UNIQUE (trainer_id, specialization_id)
);

-- 10. Таблица доступа тренеров к залам (M:M: тренеры ↔ залы)
CREATE TABLE trainer_hall_access (
    id SERIAL PRIMARY KEY,
    trainer_id INTEGER NOT NULL,
    hall_id INTEGER NOT NULL,
    access_granted DATE DEFAULT CURRENT_DATE,
    access_type VARCHAR(10) CHECK (access_type IN ('full', 'limited')) DEFAULT 'full',
    CONSTRAINT fk_trainer_access_trainers 
        FOREIGN KEY (trainer_id) REFERENCES trainers(id) ON DELETE CASCADE,
    CONSTRAINT fk_trainer_access_halls 
        FOREIGN KEY (hall_id) REFERENCES halls(id) ON DELETE CASCADE,
    CONSTRAINT unique_trainer_hall UNIQUE (trainer_id, hall_id)
);


-- Клиенты
INSERT INTO clients (full_name, phone, email, registration_date, card_number) VALUES
('Иванов Иван Иванович', '+79161234501', 'ivanov@mail.ru', '2024-01-15', 'CARD001'),
('Петрова Анна Сергеевна', '+79161234502', 'petrova@gmail.com', '2024-01-20', 'CARD002'),
('Сидоров Алексей Петрович', '+79161234503', 'sidorov@yandex.ru', '2024-02-01', 'CARD003'),
('Кузнецова Мария Владимировна', '+79161234504', 'kuznetsova@mail.ru', '2024-02-10', 'CARD004'),
('Новиков Дмитрий Андреевич', '+79161234505', 'novikov@gmail.com', '2024-02-15', 'CARD005'),
('Морозова Екатерина Игоревна', '+79161234506', 'morozova@mail.ru', '2024-03-01', 'CARD006'),
('Васильев Павел Олегович', '+79161234507', 'vasilev@yandex.ru', '2024-03-05', 'CARD007'),
('Федорова Ольга Александровна', '+79161234508', 'fedorova@gmail.com', '2024-03-10', 'CARD008'),
('Лебедев Артем Викторович', '+79161234509', 'lebedev@mail.ru', '2024-03-15', 'CARD009'),
('Соколова Виктория Дмитриевна', '+79161234510', 'sokolova@gmail.com', '2024-03-20', 'CARD010');

-- Подписки 
INSERT INTO subscriptions (client_id, start_date, end_date, status, price) VALUES
(1, '2024-03-01', '2024-04-01', 'active', 3000.00),
(2, '2024-03-05', '2024-04-05', 'active', 3000.00),
(3, '2024-02-01', '2024-03-01', 'expired', 2800.00),
(4, '2024-03-10', '2024-04-10', 'active', 3200.00),
(5, '2024-03-15', '2024-04-15', 'active', 3000.00),
(6, '2024-03-01', '2024-04-01', 'active', 2900.00),
(7, '2024-02-20', '2024-03-20', 'expired', 2800.00),
(8, '2024-03-10', '2024-04-10', 'active', 3100.00),
(9, '2024-03-15', '2024-04-15', 'active', 3000.00),
(10, '2024-03-20', '2024-04-20', 'active', 3200.00);

-- Тренеры
INSERT INTO trainers (full_name, phone, hire_date, status) VALUES
('Смирнов Александр Игоревич', '+79165551101', '2023-01-15', 'active'),
('Ковалева Елена Васильевна', '+79165551102', '2023-02-20', 'active'),
('Попов Сергей Николаевич', '+79165551103', '2023-03-10', 'active'),
('Волкова Ирина Петровна', '+79165551104', '2023-04-05', 'active'),
('Алексеев Михаил Дмитриевич', '+79165551105', '2023-05-12', 'inactive'),
('Орлова Татьяна Сергеевна', '+79165551106', '2023-06-18', 'active'),
('Никитин Андрей Владимирович', '+79165551107', '2023-07-22', 'active'),
('Захарова Юлия Александровна', '+79165551108', '2023-08-30', 'active'),
('Белов Роман Олегович', '+79165551109', '2023-09-14', 'active'),
('Григорьева Анастасия Игоревна', '+79165551110', '2023-10-25', 'active');

-- Залы 
INSERT INTO halls (name, type, capacity, status) VALUES
('Тренажерный зал A', 'gym', 30, 'open'),
('Тренажерный зал B', 'gym', 25, 'open'),
('Зал групповых занятий 1', 'group', 20, 'open'),
('Зал групповых занятий 2', 'group', 15, 'open'),
('Кардио-зона', 'cardio', 10, 'open'),
('Бассейн', 'pool', 8, 'open'),
('Йога-студия', 'group', 12, 'open'),
('Функциональный тренинг', 'gym', 18, 'closed'),
('Боксерский зал', 'gym', 10, 'open'),
('Танцевальный зал', 'group', 25, 'open');

-- Типы занятий 
INSERT INTO class_types (name, description, duration_minutes, category) VALUES
('Йога', 'Хатха йога для начинающих', 60, 'Растяжка'),
('Пилатес', 'Упражнения на силу и гибкость', 55, 'Силовые'),
('Кроссфит', 'Высокоинтенсивные тренировки', 45, 'Функциональные'),
('Стретчинг', 'Растяжка всех групп мышц', 50, 'Растяжка'),
('TRX', 'Тренировки с петлями TRX', 40, 'Функциональные'),
('Бодипамп', 'Силовая тренировка с мини-штангой', 60, 'Силовые'),
('Зумба', 'Танцевальная аэробика', 50, 'Кардио'),
('Бокс', 'Тренировка по боксу', 60, 'Единоборства'),
('Плавание', 'Тренировка в бассейне', 45, 'Кардио'),
('Функциональный тренинг', 'Тренировка на все группы мышц', 55, 'Функциональные');

-- Специализации
INSERT INTO specializations (name, description) VALUES
('Йога', 'Инструктор по йоге'),
('Пилатес', 'Инструктор по пилатесу'),
('Кроссфит', 'Тренер по кроссфиту'),
('Стретчинг', 'Инструктор по растяжке'),
('TRX', 'Тренер по TRX'),
('Бодипамп', 'Инструктор по бодипампу'),
('Зумба', 'Инструктор по зумбе'),
('Бокс', 'Тренер по боксу'),
('Плавание', 'Инструктор по плаванию'),
('Фитнес', 'Общий фитнес-тренер');

-- Расписание 
INSERT INTO schedule (class_type_id, trainer_id, hall_id, start_time, end_time, max_participants) VALUES
(1, 2, 3, '2024-03-25 10:00:00', '2024-03-25 11:00:00', 15),
(2, 4, 4, '2024-03-25 12:00:00', '2024-03-25 13:00:00', 12),
(3, 1, 1, '2024-03-25 18:00:00', '2024-03-25 19:00:00', 20),
(4, 6, 3, '2024-03-26 09:00:00', '2024-03-26 10:00:00', 15),
(5, 3, 2, '2024-03-26 11:00:00', '2024-03-26 12:00:00', 10),
(6, 7, 1, '2024-03-26 17:00:00', '2024-03-26 18:00:00', 18),
(7, 8, 10, '2024-03-27 10:00:00', '2024-03-27 11:00:00', 20),
(8, 9, 9, '2024-03-27 19:00:00', '2024-03-27 20:00:00', 8),
(9, 10, 6, '2024-03-28 08:00:00', '2024-03-28 09:00:00', 6),
(10, 1, 1, '2024-03-28 20:00:00', '2024-03-28 21:00:00', 15);

-- Посещения (M:M связь)
INSERT INTO visits (client_id, schedule_id, subscription_id, visit_date, visit_time, status) VALUES
(1, 1, 1, '2024-03-25', '10:00:00', 'attended'),
(2, 1, 2, '2024-03-25', '10:00:00', 'attended'),
(3, 3, 3, '2024-03-25', '18:00:00', 'attended'),
(4, 4, 4, '2024-03-26', '09:00:00', 'attended'),
(5, 5, 5, '2024-03-26', '11:00:00', 'attended'),
(6, 6, 6, '2024-03-26', '17:00:00', 'missed'),
(7, 7, 7, '2024-03-27', '10:00:00', 'attended'),
(8, 8, 8, '2024-03-27', '19:00:00', 'attended'),
(9, 9, 9, '2024-03-28', '08:00:00', 'attended'),
(10, 10, 10, '2024-03-28', '20:00:00', 'attended');

-- Тренерские специализации (M:M связь)
INSERT INTO trainer_specializations (trainer_id, specialization_id, certification_date, level) VALUES
(1, 3, '2022-05-15', 'expert'),
(1, 10, '2022-01-10', 'expert'),
(2, 1, '2021-08-20', 'advanced'),
(2, 4, '2021-10-05', 'advanced'),
(3, 5, '2022-03-12', 'advanced'),
(4, 2, '2021-11-30', 'expert'),
(5, 8, '2020-09-15', 'expert'),
(6, 4, '2022-02-28', 'basic'),
(7, 6, '2021-12-10', 'advanced'),
(8, 7, '2022-04-05', 'basic');

-- Доступы тренеров к залам (M:M связь)
INSERT INTO trainer_hall_access (trainer_id, hall_id, access_granted, access_type) VALUES
(1, 1, '2023-01-20', 'full'),
(1, 2, '2023-01-20', 'full'),
(2, 3, '2023-02-25', 'full'),
(2, 7, '2023-03-10', 'full'),
(3, 1, '2023-03-15', 'full'),
(3, 2, '2023-03-15', 'limited'),
(4, 4, '2023-04-10', 'full'),
(5, 9, '2023-05-15', 'full'),
(6, 3, '2023-06-20', 'full'),
(7, 1, '2023-07-25', 'full');
