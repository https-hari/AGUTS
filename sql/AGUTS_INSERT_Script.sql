-- ============================================================
-- AGUTS – Sample Data INSERT Script
-- IT-214 DBMS | Lab Group 5 | DA-IICT | Winter 2025-26
-- Ahmedabad Gandhinagar Unified Transit System
-- ============================================================
-- REAL DATA: Metro stations (GMRC Wikipedia), BRTS routes
--            (Janmarg Wikipedia), fare structure (GMRC official)
-- SAMPLE DATA: Passengers (Gujarati names), trips, tickets,
--              staff, complaints, maintenance
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- 1. CITY
-- ─────────────────────────────────────────────────────────────
INSERT INTO City VALUES (1, 'Ahmedabad',  'Ahmedabad Urban Agglomeration', 23.0225, 72.5714);
INSERT INTO City VALUES (2, 'Gandhinagar','Gandhinagar Capital Region',     23.2156, 72.6369);

-- ─────────────────────────────────────────────────────────────
-- 2. TRANSIT OPERATOR  (real operators)
-- ─────────────────────────────────────────────────────────────
INSERT INTO Transit_Operator VALUES (1, 'GMRC',    'Metro Rail',     1);
INSERT INTO Transit_Operator VALUES (2, 'Janmarg', 'BRTS',           1);
INSERT INTO Transit_Operator VALUES (3, 'AMTS',    'City Bus',       1);
INSERT INTO Transit_Operator VALUES (4, 'GSRTC',   'State Road Bus', 2);

-- ─────────────────────────────────────────────────────────────
-- 3. STOP  (real station/stop names from GMRC & Janmarg)
-- ─────────────────────────────────────────────────────────────
-- GMRC Blue Line stations (East-West, Vastral Gam → Thaltej Gam)
INSERT INTO Stop VALUES (1,  'Vastral Gam',          'Metro Station', 'Vastral Gam, Ahmedabad',         'Vastral',     'Ring Road',           1);
INSERT INTO Stop VALUES (2,  'Vastral',               'Metro Station', 'Vastral, Ahmedabad',             'Vastral',     'Vastral Road',        1);
INSERT INTO Stop VALUES (3,  'Rabari Colony',         'Metro Station', 'Rabari Colony, Ahmedabad',       'Rabari',      'Rabari Colony Road',  1);
INSERT INTO Stop VALUES (4,  'Nirant Cross Road',     'Metro Station', 'Nirant, Ahmedabad',              'Amraiwadi',   'Nirant Road',         1);
INSERT INTO Stop VALUES (5,  'Amraiwadi',             'Metro Station', 'Amraiwadi, Ahmedabad',           'Amraiwadi',   'Amraiwadi Road',      1);
INSERT INTO Stop VALUES (6,  'Apparel Park',          'Metro Station', 'Apparel Park, Ahmedabad',        'Narol',       'Apparel Park Road',   1);
INSERT INTO Stop VALUES (7,  'Kankaria East',         'Metro Station', 'Kankaria, Ahmedabad',            'Kankaria',    'Kankaria Road',       1);
INSERT INTO Stop VALUES (8,  'SP Stadium',            'Metro Station', 'SP Stadium, Ahmedabad',          'Lal Darwaja', 'SP Stadium Road',     1);
INSERT INTO Stop VALUES (9,  'Shahpur',               'Metro Station', 'Shahpur, Ahmedabad',             'Shahpur',     'Shahpur Road',        1);
INSERT INTO Stop VALUES (10, 'Gheekanta',             'Metro Station', 'Gheekanta, Ahmedabad',           'Gheekanta',   'Gheekanta Road',      1);
INSERT INTO Stop VALUES (11, 'Kalupur Railway Station','Metro Station','Kalupur, Ahmedabad',             'Kalupur',     'Station Road',        1);
INSERT INTO Stop VALUES (12, 'Old High Court',        'Metro Station', 'Old High Court, Ahmedabad',      'Lal Darwaja', 'High Court Road',     1);
INSERT INTO Stop VALUES (13, 'Commerce Six Road',     'Metro Station', 'Commerce Six Road, Ahmedabad',   'Navrangpura', 'Commerce Six Road',   1);
INSERT INTO Stop VALUES (14, 'Doordarshan Kendra',    'Metro Station', 'Doordarshan Kendra, Ahmedabad',  'Navrangpura', 'Ashram Road',         1);
INSERT INTO Stop VALUES (15, 'Gujarat University',    'Metro Station', 'Gujarat University, Ahmedabad',  'Navrangpura', 'University Road',     1);
INSERT INTO Stop VALUES (16, 'Gurukul Road',          'Metro Station', 'Gurukul Road, Ahmedabad',        'Gurukul',     'Gurukul Road',        1);
INSERT INTO Stop VALUES (17, 'Thaltej',               'Metro Station', 'Thaltej, Ahmedabad',             'Thaltej',     'SG Highway',          1);
INSERT INTO Stop VALUES (18, 'Thaltej Gam',           'Metro Station', 'Thaltej Gam, Ahmedabad',         'Thaltej',     'Thaltej Gam Road',    1);

-- GMRC Red Line stations (North-South, APMC → Motera Stadium)
INSERT INTO Stop VALUES (19, 'APMC',                  'Metro Station', 'APMC, Ahmedabad',                'Maninagar',   'APMC Road',           1);
INSERT INTO Stop VALUES (20, 'Jivraj Park',            'Metro Station', 'Jivraj Park, Ahmedabad',         'Jivraj Park', 'Jivraj Park Road',    1);
INSERT INTO Stop VALUES (21, 'Shreyas',                'Metro Station', 'Shreyas, Ahmedabad',             'Paldi',       'Shreyas Road',        1);
INSERT INTO Stop VALUES (22, 'Paldi',                  'Metro Station', 'Paldi, Ahmedabad',               'Paldi',       'Paldi Road',          1);
INSERT INTO Stop VALUES (23, 'Old High Court (Red)',   'Metro Station', 'Old High Court, Ahmedabad',      'Lal Darwaja', 'High Court Road',     1);
INSERT INTO Stop VALUES (24, 'Gandhigram',             'Metro Station', 'Gandhigram, Ahmedabad',          'Ashram Road', 'Ashram Road',         1);
INSERT INTO Stop VALUES (25, 'AEC',                    'Metro Station', 'AEC, Ahmedabad',                 'Navrangpura', 'CG Road',             1);
INSERT INTO Stop VALUES (26, 'Usmanpura',              'Metro Station', 'Usmanpura, Ahmedabad',           'Usmanpura',   'Usmanpura Road',      1);
INSERT INTO Stop VALUES (27, 'Vadaj',                  'Metro Station', 'Vadaj, Ahmedabad',               'Vadaj',       'Vadaj Road',          1);
INSERT INTO Stop VALUES (28, 'Ranip',                  'Metro Station', 'Ranip, Ahmedabad',               'Ranip',       'Ranip Road',          1);
INSERT INTO Stop VALUES (29, 'Vijay Nagar',            'Metro Station', 'Vijay Nagar, Ahmedabad',         'Vijaynagar',  'Vijay Nagar Road',    1);
INSERT INTO Stop VALUES (30, 'Rajiv Nagar',            'Metro Station', 'Rajiv Nagar, Ahmedabad',         'Chandkheda',  'Rajiv Nagar Road',    1);
INSERT INTO Stop VALUES (31, 'Sabarmati',              'Metro Station', 'Sabarmati, Ahmedabad',           'Sabarmati',   'Sabarmati Road',      1);
INSERT INTO Stop VALUES (32, 'Motera Stadium',         'Metro Station', 'Motera, Ahmedabad',              'Motera',      'Sardar Patel Road',   1);

-- GMRC Yellow Line (Motera → Sector-1 Gandhinagar)
INSERT INTO Stop VALUES (33, 'Sector-1 Gandhinagar',  'Metro Station', 'Sector-1, Gandhinagar',          'Sector-1',    'Sector-1 Road',       2);
INSERT INTO Stop VALUES (34, 'Infocity',               'Metro Station', 'Infocity, Gandhinagar',          'Infocity',    'Infocity Road',       2);
INSERT INTO Stop VALUES (35, 'Dholakuva Circle',       'Metro Station', 'Dholakuva, Gandhinagar',         'Dholakuva',   'Dholakuva Road',      2);
INSERT INTO Stop VALUES (36, 'Randesan',               'Metro Station', 'Randesan, Gandhinagar',          'Randesan',    'Randesan Road',       2);
INSERT INTO Stop VALUES (37, 'GNLU',                   'Metro Station', 'GNLU, Gandhinagar',              'GNLU',        'GNLU Road',           2);
INSERT INTO Stop VALUES (38, 'Raysan',                 'Metro Station', 'Raysan, Gandhinagar',            'Raysan',      'Raysan Road',         2);

-- BRTS Janmarg key stops (real corridor stops)
INSERT INTO Stop VALUES (40, 'RTO Circle',             'BRTS Station',  'RTO Circle, Ahmedabad',          'Navrangpura', 'RTO Road',            1);
INSERT INTO Stop VALUES (41, 'Maninagar',              'BRTS Station',  'Maninagar, Ahmedabad',           'Maninagar',   'Maninagar Road',      1);
INSERT INTO Stop VALUES (42, 'Anjali (Vasna)',         'BRTS Station',  'Vasna, Ahmedabad',               'Vasna',       'Vasna Road',          1);
INSERT INTO Stop VALUES (43, 'Naroda',                 'BRTS Station',  'Naroda, Ahmedabad',              'Naroda',      'Naroda Road',         1);
INSERT INTO Stop VALUES (44, 'Nehrunagar',             'BRTS Station',  'Nehrunagar, Ahmedabad',          'Nehrunagar',  'Nehrunagar Road',     1);
INSERT INTO Stop VALUES (45, 'Shivranjani',            'BRTS Station',  'Shivranjani, Ahmedabad',         'Satellite',   'Shivranjani Road',    1);
INSERT INTO Stop VALUES (46, 'Sola RoB',               'BRTS Station',  'Sola Road over Bridge',          'Sola',        'Sola Road',           1);
INSERT INTO Stop VALUES (47, 'Chandkheda',             'BRTS Station',  'Chandkheda, Ahmedabad',          'Chandkheda',  'Chandkheda Road',     1);
INSERT INTO Stop VALUES (48, 'Jashodanagar',           'BRTS Station',  'Jashodanagar, Ahmedabad',        'Jashodanagar','Jashodanagar Road',   1);
INSERT INTO Stop VALUES (49, 'Memco',                  'BRTS Station',  'Memco, Ahmedabad',               'Naroda',      'Naroda Road',         1);
INSERT INTO Stop VALUES (50, 'Science City Approach',  'BRTS Station',  'Science City, Ahmedabad',        'Sola',        'Science City Road',   1);
INSERT INTO Stop VALUES (51, 'Narol',                  'BRTS Station',  'Narol, Ahmedabad',               'Narol',       'Narol Road',          1);
INSERT INTO Stop VALUES (52, 'Ghuma',                  'BRTS Station',  'Ghuma, Ahmedabad',               'Ghuma',       'SG Highway',          1);
INSERT INTO Stop VALUES (53, 'Iskon',                  'BRTS Station',  'ISKCON, Ahmedabad',              'Satellite',   'SG Highway',          1);

-- AMTS stops
INSERT INTO Stop VALUES (60, 'Geeta Mandir',           'Bus Stop',      'Geeta Mandir, Ahmedabad',        'Kalupur',     'Geeta Mandir Road',   1);
INSERT INTO Stop VALUES (61, 'Lal Darwaja',            'Bus Stop',      'Lal Darwaja, Ahmedabad',         'Lal Darwaja', 'Lal Darwaja Road',    1);
INSERT INTO Stop VALUES (62, 'Sarkhej',                'Bus Stop',      'Sarkhej, Ahmedabad',             'Sarkhej',     'Sarkhej Road',        1);
INSERT INTO Stop VALUES (63, 'Bopal',                  'Bus Stop',      'Bopal, Ahmedabad',               'Bopal',       'Bopal Road',          1);
INSERT INTO Stop VALUES (64, 'Vatva',                  'Bus Stop',      'Vatva, Ahmedabad',               'Vatva',       'Vatva Road',          1);
INSERT INTO Stop VALUES (65, 'Odhav',                  'Bus Stop',      'Odhav, Ahmedabad',               'Odhav',       'Odhav Road',          1);

-- GSRTC stops (Gandhinagar)
INSERT INTO Stop VALUES (70, 'Gandhinagar Bus Stand',  'Bus Stand',     'Sector-11, Gandhinagar',         'Sector-11',   'Sector-11 Road',      2);
INSERT INTO Stop VALUES (71, 'Infocity Bus Stop',      'Bus Stop',      'Infocity, Gandhinagar',          'Infocity',    'Infocity Road',       2);
INSERT INTO Stop VALUES (72, 'Akshardham Bus Stop',    'Bus Stop',      'Akshardham, Gandhinagar',        'Sector-20',   'Akshardham Road',     2);

-- ─────────────────────────────────────────────────────────────
-- 4. INTERCHANGE  (real interchange points)
-- ─────────────────────────────────────────────────────────────
INSERT INTO Interchange VALUES (1, 'Metro-BRTS',     'Blue & Red Metro lines interchange',          12);
INSERT INTO Interchange VALUES (2, 'Metro-Railway',  'Metro connects to Ahmedabad Railway Station', 11);
INSERT INTO Interchange VALUES (3, 'Metro-BRTS',     'Metro & BRTS interchange at Motera',          32);
INSERT INTO Interchange VALUES (4, 'Metro-BRTS',     'BRTS & Metro at RTO',                         40);

-- ─────────────────────────────────────────────────────────────
-- 5. DEPOT
-- ─────────────────────────────────────────────────────────────
INSERT INTO Depot VALUES (1, 'Apparel Park Metro Depot',   1, 6);
INSERT INTO Depot VALUES (2, 'Motera Metro Depot',         1, 32);
INSERT INTO Depot VALUES (3, 'Janmarg Naroda Depot',       2, 43);
INSERT INTO Depot VALUES (4, 'Janmarg Gyaspur Depot',      2, 40);
INSERT INTO Depot VALUES (5, 'AMTS Geeta Mandir Depot',    3, 60);
INSERT INTO Depot VALUES (6, 'AMTS Maninagar Depot',       3, 41);
INSERT INTO Depot VALUES (7, 'GSRTC Gandhinagar Depot',    4, 70);

-- ─────────────────────────────────────────────────────────────
-- 6. METRO LINE  (real GMRC lines)
-- ─────────────────────────────────────────────────────────────
INSERT INTO Metro_Line VALUES (1, 'Blue Line',   'BL', 1);
INSERT INTO Metro_Line VALUES (2, 'Red Line',    'RL', 1);
INSERT INTO Metro_Line VALUES (3, 'Yellow Line', 'YL', 1);

-- ─────────────────────────────────────────────────────────────
-- 7. FARE ZONE  (real GMRC fare zones – ₹5 to ₹40)
-- ─────────────────────────────────────────────────────────────
INSERT INTO Fare_Zone VALUES (1, 'Zone 1 (0-2 km)',    5.00,  1);
INSERT INTO Fare_Zone VALUES (2, 'Zone 2 (2-5 km)',   10.00,  1);
INSERT INTO Fare_Zone VALUES (3, 'Zone 3 (5-9 km)',   15.00,  1);
INSERT INTO Fare_Zone VALUES (4, 'Zone 4 (9-14 km)',  20.00,  1);
INSERT INTO Fare_Zone VALUES (5, 'Zone 5 (14-19 km)', 25.00,  1);
INSERT INTO Fare_Zone VALUES (6, 'Zone 6 (19+ km)',   40.00,  1);
INSERT INTO Fare_Zone VALUES (7, 'BRTS Flat Fare',     6.00,  2);
INSERT INTO Fare_Zone VALUES (8, 'AMTS City Fare',     7.00,  3);
INSERT INTO Fare_Zone VALUES (9, 'GSRTC Inter-City',  15.00,  4);

-- ─────────────────────────────────────────────────────────────
-- 8. ROUTE  (real route names and numbers)
-- ─────────────────────────────────────────────────────────────
-- Metro routes
INSERT INTO Route VALUES (1,  'BL-01', 'Blue Line: Vastral Gam – Thaltej Gam', 21.16, 1, 1);
INSERT INTO Route VALUES (2,  'RL-01', 'Red Line: APMC – Motera Stadium',       18.87, 1, 2);
INSERT INTO Route VALUES (3,  'YL-01', 'Yellow Line: Motera – Sector-1',        15.40, 1, 2);

-- BRTS Janmarg routes (real route numbers)
INSERT INTO Route VALUES (4,  'J-01',  'BRTS Route 1: RTO Circle – Maninagar',             12.5,  2, 3);
INSERT INTO Route VALUES (5,  'J-02',  'BRTS Route 2: Anjali – Naroda',                    18.2,  2, 3);
INSERT INTO Route VALUES (6,  'J-05',  'BRTS Route 5: Ghuma – ISKCON – Maninagar',         22.0,  2, 3);
INSERT INTO Route VALUES (7,  'J-08',  'BRTS Route 8: Chandkheda – Visat – Maninagar',     24.3,  2, 4);
INSERT INTO Route VALUES (8,  'J-09',  'BRTS Route 9: RTO – Memco – Naroda',               16.8,  2, 4);
INSERT INTO Route VALUES (9,  'J-10',  'BRTS Route 10: Anjali – Kalupur Railway Station',  11.4,  2, 3);

-- AMTS routes
INSERT INTO Route VALUES (10, 'A-31',  'AMTS Route 31: Geeta Mandir – Bopal',              19.5,  3, 5);
INSERT INTO Route VALUES (11, 'A-52',  'AMTS Route 52: Lal Darwaja – Vatva',               14.2,  3, 6);
INSERT INTO Route VALUES (12, 'A-81',  'AMTS Route 81: Geeta Mandir – Sarkhej',            16.8,  3, 5);

-- GSRTC routes
INSERT INTO Route VALUES (13, 'G-101', 'GSRTC: Gandhinagar – Geeta Mandir (Ahmedabad)',    28.5,  4, 7);
INSERT INTO Route VALUES (14, 'G-102', 'GSRTC: Gandhinagar – Maninagar',                   30.1,  4, 7);

-- ─────────────────────────────────────────────────────────────
-- 9. ROUTE_STOP  (sequence of stops on each route)
-- ─────────────────────────────────────────────────────────────
-- Blue Line stops (seq, zone)
INSERT INTO Route_Stop VALUES (1,  1,  1, 1);
INSERT INTO Route_Stop VALUES (1,  2,  2, 1);
INSERT INTO Route_Stop VALUES (1,  3,  3, 1);
INSERT INTO Route_Stop VALUES (1,  4,  4, 2);
INSERT INTO Route_Stop VALUES (1,  5,  5, 2);
INSERT INTO Route_Stop VALUES (1,  6,  6, 2);
INSERT INTO Route_Stop VALUES (1,  7,  7, 3);
INSERT INTO Route_Stop VALUES (1,  8,  8, 3);
INSERT INTO Route_Stop VALUES (1,  9,  9, 3);
INSERT INTO Route_Stop VALUES (1, 10, 10, 4);
INSERT INTO Route_Stop VALUES (1, 11, 11, 4);
INSERT INTO Route_Stop VALUES (1, 12, 12, 4);
INSERT INTO Route_Stop VALUES (1, 13, 13, 5);
INSERT INTO Route_Stop VALUES (1, 14, 14, 5);
INSERT INTO Route_Stop VALUES (1, 15, 15, 5);
INSERT INTO Route_Stop VALUES (1, 16, 16, 6);
INSERT INTO Route_Stop VALUES (1, 17, 17, 6);
INSERT INTO Route_Stop VALUES (1, 18, 18, 6);

-- Red Line stops
INSERT INTO Route_Stop VALUES (2, 19,  1, 1);
INSERT INTO Route_Stop VALUES (2, 20,  2, 1);
INSERT INTO Route_Stop VALUES (2, 21,  3, 2);
INSERT INTO Route_Stop VALUES (2, 22,  4, 2);
INSERT INTO Route_Stop VALUES (2, 23,  5, 3);
INSERT INTO Route_Stop VALUES (2, 24,  6, 3);
INSERT INTO Route_Stop VALUES (2, 25,  7, 3);
INSERT INTO Route_Stop VALUES (2, 26,  8, 4);
INSERT INTO Route_Stop VALUES (2, 27,  9, 4);
INSERT INTO Route_Stop VALUES (2, 28, 10, 4);
INSERT INTO Route_Stop VALUES (2, 29, 11, 5);
INSERT INTO Route_Stop VALUES (2, 30, 12, 5);
INSERT INTO Route_Stop VALUES (2, 31, 13, 5);
INSERT INTO Route_Stop VALUES (2, 32, 14, 6);

-- Yellow Line stops
INSERT INTO Route_Stop VALUES (3, 32,  1, 4);
INSERT INTO Route_Stop VALUES (3, 38,  2, 5);
INSERT INTO Route_Stop VALUES (3, 37,  3, 5);
INSERT INTO Route_Stop VALUES (3, 36,  4, 5);
INSERT INTO Route_Stop VALUES (3, 35,  5, 6);
INSERT INTO Route_Stop VALUES (3, 34,  6, 6);
INSERT INTO Route_Stop VALUES (3, 33,  7, 6);

-- BRTS Route 1
INSERT INTO Route_Stop VALUES (4, 40,  1, 7);
INSERT INTO Route_Stop VALUES (4, 44,  2, 7);
INSERT INTO Route_Stop VALUES (4, 25,  3, 7);
INSERT INTO Route_Stop VALUES (4, 41,  4, 7);

-- BRTS Route 2
INSERT INTO Route_Stop VALUES (5, 42,  1, 7);
INSERT INTO Route_Stop VALUES (5, 45,  2, 7);
INSERT INTO Route_Stop VALUES (5, 40,  3, 7);
INSERT INTO Route_Stop VALUES (5, 49,  4, 7);
INSERT INTO Route_Stop VALUES (5, 43,  5, 7);

-- BRTS Route 5
INSERT INTO Route_Stop VALUES (6, 52,  1, 7);
INSERT INTO Route_Stop VALUES (6, 53,  2, 7);
INSERT INTO Route_Stop VALUES (6, 45,  3, 7);
INSERT INTO Route_Stop VALUES (6, 40,  4, 7);
INSERT INTO Route_Stop VALUES (6, 41,  5, 7);

-- AMTS Route 31
INSERT INTO Route_Stop VALUES (10, 60, 1, 8);
INSERT INTO Route_Stop VALUES (10, 61, 2, 8);
INSERT INTO Route_Stop VALUES (10, 62, 3, 8);
INSERT INTO Route_Stop VALUES (10, 63, 4, 8);

-- AMTS Route 52
INSERT INTO Route_Stop VALUES (11, 61, 1, 8);
INSERT INTO Route_Stop VALUES (11, 60, 2, 8);
INSERT INTO Route_Stop VALUES (11, 65, 3, 8);
INSERT INTO Route_Stop VALUES (11, 64, 4, 8);

-- GSRTC Route 101
INSERT INTO Route_Stop VALUES (13, 70, 1, 9);
INSERT INTO Route_Stop VALUES (13, 72, 2, 9);
INSERT INTO Route_Stop VALUES (13, 60, 3, 9);

-- ─────────────────────────────────────────────────────────────
-- 10. VEHICLE
-- ─────────────────────────────────────────────────────────────
-- Metro Trains
INSERT INTO Vehicle VALUES (1,  'GJ-METRO-BL-01', 1200, 'Apparel Park Depot', 'BEML 3-car EMU',   2018, 'BEML',       1, 1);
INSERT INTO Vehicle VALUES (2,  'GJ-METRO-BL-02', 1200, 'Apparel Park Depot', 'BEML 3-car EMU',   2018, 'BEML',       1, 1);
INSERT INTO Vehicle VALUES (3,  'GJ-METRO-BL-03', 1200, 'Apparel Park Depot', 'BEML 3-car EMU',   2019, 'BEML',       1, 1);
INSERT INTO Vehicle VALUES (4,  'GJ-METRO-RL-01', 1200, 'Motera Depot',       'BEML 3-car EMU',   2022, 'BEML',       1, 2);
INSERT INTO Vehicle VALUES (5,  'GJ-METRO-RL-02', 1200, 'Motera Depot',       'Alstom 3-car EMU', 2022, 'Alstom',     1, 2);
INSERT INTO Vehicle VALUES (6,  'GJ-METRO-YL-01', 1200, 'Motera Depot',       'CRRC 3-car EMU',   2024, 'CRRC',       1, 2);

-- BRTS Buses
INSERT INTO Vehicle VALUES (7,  'GJ-01-BT-2301', 60, 'Naroda Depot',   'Tata Starbus AC',     2021, 'Tata Motors', 2, 3);
INSERT INTO Vehicle VALUES (8,  'GJ-01-BT-2302', 60, 'Naroda Depot',   'Tata Starbus AC',     2021, 'Tata Motors', 2, 3);
INSERT INTO Vehicle VALUES (9,  'GJ-01-BT-2303', 40, 'Gyaspur Depot',  'Tata Starbus Non-AC', 2020, 'Tata Motors', 2, 4);
INSERT INTO Vehicle VALUES (10, 'GJ-01-BT-2304', 60, 'Gyaspur Depot',  'Tata Starbus AC',     2022, 'Tata Motors', 2, 4);
INSERT INTO Vehicle VALUES (11, 'GJ-01-BT-2305', 40, 'Naroda Depot',   'Ashok Leyland Viking',2019, 'Ashok Leyland',2,3);

-- AMTS Buses
INSERT INTO Vehicle VALUES (12, 'GJ-01-AT-1001', 50, 'Geeta Mandir Depot', 'JNNURM CNG Bus',   2018, 'Tata Motors', 3, 5);
INSERT INTO Vehicle VALUES (13, 'GJ-01-AT-1002', 50, 'Maninagar Depot',    'JNNURM CNG Bus',   2019, 'Tata Motors', 3, 6);
INSERT INTO Vehicle VALUES (14, 'GJ-01-AT-1003', 55, 'Geeta Mandir Depot', 'Volvo 8400 CNG',   2021, 'Volvo',       3, 5);

-- GSRTC Buses
INSERT INTO Vehicle VALUES (15, 'GJ-18-GT-5501', 45, 'Gandhinagar Depot', 'Leyland BS6 Diesel',2020, 'Ashok Leyland',4,7);
INSERT INTO Vehicle VALUES (16, 'GJ-18-GT-5502', 45, 'Gandhinagar Depot', 'Leyland BS6 Diesel',2021, 'Ashok Leyland',4,7);

-- ─────────────────────────────────────────────────────────────
-- 11. BUS
-- ─────────────────────────────────────────────────────────────
INSERT INTO Bus VALUES (7,  'CNG',    'AC Standard');
INSERT INTO Bus VALUES (8,  'CNG',    'AC Standard');
INSERT INTO Bus VALUES (9,  'Diesel', 'Non-AC Standard');
INSERT INTO Bus VALUES (10, 'CNG',    'AC Standard');
INSERT INTO Bus VALUES (11, 'Diesel', 'Non-AC Standard');
INSERT INTO Bus VALUES (12, 'CNG',    'City Bus');
INSERT INTO Bus VALUES (13, 'CNG',    'City Bus');
INSERT INTO Bus VALUES (14, 'CNG',    'AC City Bus');
INSERT INTO Bus VALUES (15, 'Diesel', 'Inter-City');
INSERT INTO Bus VALUES (16, 'Diesel', 'Inter-City');

-- ─────────────────────────────────────────────────────────────
-- 12. METRO TRAIN
-- ─────────────────────────────────────────────────────────────
INSERT INTO Metro_Train VALUES (1, 3, 'BL-T01', 1);
INSERT INTO Metro_Train VALUES (2, 3, 'BL-T02', 1);
INSERT INTO Metro_Train VALUES (3, 3, 'BL-T03', 1);
INSERT INTO Metro_Train VALUES (4, 3, 'RL-T01', 2);
INSERT INTO Metro_Train VALUES (5, 3, 'RL-T02', 2);
INSERT INTO Metro_Train VALUES (6, 3, 'YL-T01', 3);

-- ─────────────────────────────────────────────────────────────
-- 13. MAINTENANCE
-- ─────────────────────────────────────────────────────────────
INSERT INTO Maintenance VALUES (1,  'Scheduled Service',  '2024-01-10', '2024-01-11', '6-month scheduled maintenance of BL-T01',   1);
INSERT INTO Maintenance VALUES (2,  'Wheel Check',        '2024-02-05', '2024-02-05', 'Wheel and brake inspection BL-T02',          2);
INSERT INTO Maintenance VALUES (3,  'AC Overhaul',        '2024-03-12', '2024-03-14', 'Air conditioning overhaul for bus 2301',     7);
INSERT INTO Maintenance VALUES (4,  'Engine Service',     '2024-04-20', '2024-04-21', 'Engine service for GSRTC bus 5501',          15);
INSERT INTO Maintenance VALUES (5,  'Pantograph Replace', '2024-05-01', '2024-05-02', 'Pantograph replacement RL-T01',              4);
INSERT INTO Maintenance VALUES (6,  'Tyre Replacement',   '2024-06-15', '2024-06-15', 'Four tyre replacement bus 2302',             8);
INSERT INTO Maintenance VALUES (7,  'Body Repair',        '2024-07-03', '2024-07-05', 'Body damage repair AMTS bus 1001',           12);
INSERT INTO Maintenance VALUES (8,  'Annual Overhaul',    '2024-08-10', '2024-08-15', 'Annual overhaul GSRTC bus 5502',             16);
INSERT INTO Maintenance VALUES (9,  'Signal System',      '2024-09-22', '2024-09-23', 'Signaling system check YL-T01',              6);
INSERT INTO Maintenance VALUES (10, 'Brake Inspection',   '2024-10-05', '2024-10-05', 'Emergency brake inspection bus 2303',        9);

-- ─────────────────────────────────────────────────────────────
-- 14. STAFF  (Gujarati names)
-- ─────────────────────────────────────────────────────────────
-- Metro Motormen
INSERT INTO Staff VALUES (1,  'Dhruv Prajapati',    'Motorman',  '9825011101', '2019-03-01', 'Metro Motorman Cert Level-1', 1, 1);
INSERT INTO Staff VALUES (2,  'Kalpesh Solanki',    'Motorman',  '9825011102', '2019-03-01', 'Metro Motorman Cert Level-1', 1, 1);
INSERT INTO Staff VALUES (3,  'Nilesh Rathod',      'Motorman',  '9825011103', '2022-10-01', 'Metro Motorman Cert Level-2', 2, 1);
INSERT INTO Staff VALUES (4,  'Bhavesh Vaghela',    'Motorman',  '9825011104', '2022-10-01', 'Metro Motorman Cert Level-2', 2, 1);
INSERT INTO Staff VALUES (5,  'Raju Thakor',        'Motorman',  '9825011105', '2024-09-01', 'Metro Motorman Cert Level-1', 2, 1);

-- BRTS Drivers
INSERT INTO Staff VALUES (6,  'Manish Chauhan',     'Driver',    '9825022201', '2020-06-15', 'HMV License Gujarat',         3, 2);
INSERT INTO Staff VALUES (7,  'Suresh Parmar',      'Driver',    '9825022202', '2020-08-20', 'HMV License Gujarat',         3, 2);
INSERT INTO Staff VALUES (8,  'Dinesh Makwana',     'Driver',    '9825022203', '2021-01-10', 'HMV License Gujarat',         4, 2);
INSERT INTO Staff VALUES (9,  'Pravin Gamit',       'Driver',    '9825022204', '2021-03-22', 'HMV License Gujarat',         4, 2);

-- BRTS Conductors
INSERT INTO Staff VALUES (10, 'Harsha Patel',       'Conductor', '9825033301', '2020-07-01', 'BRTS Conductor Cert',         3, 2);
INSERT INTO Staff VALUES (11, 'Rekha Desai',        'Conductor', '9825033302', '2020-09-15', 'BRTS Conductor Cert',         4, 2);
INSERT INTO Staff VALUES (12, 'Jignesh Chavda',     'Conductor', '9825033303', '2021-02-01', 'BRTS Conductor Cert',         3, 2);

-- AMTS Staff
INSERT INTO Staff VALUES (13, 'Ramesh Tadvi',       'Driver',    '9825044401', '2018-05-10', 'HMV License Gujarat',         5, 3);
INSERT INTO Staff VALUES (14, 'Varsha Nayak',       'Conductor', '9825044402', '2018-06-01', 'AMTS Conductor Cert',         5, 3);
INSERT INTO Staff VALUES (15, 'Ashok Baria',        'Driver',    '9825044403', '2019-11-20', 'HMV License Gujarat',         6, 3);
INSERT INTO Staff VALUES (16, 'Meena Rohit',        'Conductor', '9825044404', '2019-12-05', 'AMTS Conductor Cert',         6, 3);

-- GSRTC Staff
INSERT INTO Staff VALUES (17, 'Gopal Vasava',       'Driver',    '9825055501', '2017-08-01', 'HMV License Gujarat',         7, 4);
INSERT INTO Staff VALUES (18, 'Shanta Bhil',        'Conductor', '9825055502', '2017-09-01', 'GSRTC Conductor Cert',        7, 4);

-- ─────────────────────────────────────────────────────────────
-- 15. DRIVER / CONDUCTOR / MOTORMAN  (specializations)
-- ─────────────────────────────────────────────────────────────
INSERT INTO Motorman VALUES (1, 'GJ-MM-2019-001');
INSERT INTO Motorman VALUES (2, 'GJ-MM-2019-002');
INSERT INTO Motorman VALUES (3, 'GJ-MM-2022-003');
INSERT INTO Motorman VALUES (4, 'GJ-MM-2022-004');
INSERT INTO Motorman VALUES (5, 'GJ-MM-2024-005');

INSERT INTO Driver VALUES (6,  'GJ-DL-0023451');
INSERT INTO Driver VALUES (7,  'GJ-DL-0031872');
INSERT INTO Driver VALUES (8,  'GJ-DL-0045209');
INSERT INTO Driver VALUES (9,  'GJ-DL-0067834');
INSERT INTO Driver VALUES (13, 'GJ-DL-0012389');
INSERT INTO Driver VALUES (15, 'GJ-DL-0098723');
INSERT INTO Driver VALUES (17, 'GJ-DL-0056671');

INSERT INTO Conductor VALUES (10, 'BRTS-C-1001');
INSERT INTO Conductor VALUES (11, 'BRTS-C-1002');
INSERT INTO Conductor VALUES (12, 'BRTS-C-1003');
INSERT INTO Conductor VALUES (14, 'AMTS-C-2001');
INSERT INTO Conductor VALUES (16, 'AMTS-C-2002');
INSERT INTO Conductor VALUES (18, 'GSRTC-C-3001');

-- ─────────────────────────────────────────────────────────────
-- 16. PASSENGER  (Gujarati names, realistic profiles)
-- ─────────────────────────────────────────────────────────────
INSERT INTO Passenger VALUES (1,  'Aarav',      'Shah',       'aarav.shah@gmail.com',        '9824101001', '2000-04-15', 'General',          1);
INSERT INTO Passenger VALUES (2,  'Priya',      'Patel',      'priya.patel@yahoo.com',       '9824101002', '1995-08-22', 'General',          1);
INSERT INTO Passenger VALUES (3,  'Mihir',      'Desai',      'mihir.desai@gmail.com',       '9824101003', '2004-01-10', 'Student',          1);
INSERT INTO Passenger VALUES (4,  'Nidhi',      'Joshi',      'nidhi.joshi@gmail.com',       '9824101004', '1958-06-30', 'Senior',           1);
INSERT INTO Passenger VALUES (5,  'Krupal',     'Mehta',      'krupal.mehta@outlook.com',    '9824101005', '1992-11-05', 'General',          1);
INSERT INTO Passenger VALUES (6,  'Dipika',     'Trivedi',    'dipika.trivedi@gmail.com',    '9824101006', '1988-03-18', 'General',          1);
INSERT INTO Passenger VALUES (7,  'Yash',       'Agrawal',    'yash.agrawal@gmail.com',      '9824101007', '2003-09-25', 'Student',          1);
INSERT INTO Passenger VALUES (8,  'Kavya',      'Bhatt',      'kavya.bhatt@gmail.com',       '9824101008', '1975-12-12', 'General',          1);
INSERT INTO Passenger VALUES (9,  'Rohan',      'Modi',       'rohan.modi@rediffmail.com',   '9824101009', '1999-07-04', 'General',          1);
INSERT INTO Passenger VALUES (10, 'Shreya',     'Gandhi',     'shreya.gandhi@gmail.com',     '9824101010', '2005-02-28', 'Student',          1);
INSERT INTO Passenger VALUES (11, 'Tanvi',      'Pandya',     'tanvi.pandya@gmail.com',      '9824101011', '1950-10-01', 'Senior',           2);
INSERT INTO Passenger VALUES (12, 'Jigar',      'Soni',       'jigar.soni@gmail.com',        '9824101012', '1985-05-14', 'General',          1);
INSERT INTO Passenger VALUES (13, 'Pooja',      'Raval',      'pooja.raval@gmail.com',       '9824101013', '1997-08-09', 'Differently-Abled',1);
INSERT INTO Passenger VALUES (14, 'Darshan',    'Nayak',      'darshan.nayak@hotmail.com',   '9824101014', '2002-03-21', 'Student',          1);
INSERT INTO Passenger VALUES (15, 'Bhumika',    'Chaudhary',  'bhumika.chaudhary@gmail.com', '9824101015', '1990-06-17', 'General',          1);
INSERT INTO Passenger VALUES (16, 'Vatsal',     'Parikh',     'vatsal.parikh@gmail.com',     '9824101016', '1983-01-30', 'General',          2);
INSERT INTO Passenger VALUES (17, 'Riya',       'Kapoor',     'riya.kapoor@gmail.com',       '9824101017', '2001-11-11', 'Student',          1);
INSERT INTO Passenger VALUES (18, 'Hardik',     'Thakkar',    'hardik.thakkar@gmail.com',    '9824101018', '1978-04-05', 'General',          1);
INSERT INTO Passenger VALUES (19, 'Foram',      'Chauhan',    'foram.chauhan@gmail.com',     '9824101019', '1965-09-20', 'Senior',           1);
INSERT INTO Passenger VALUES (20, 'Nikhil',     'Vasava',     'nikhil.vasava@gmail.com',     '9824101020', '1993-12-08', 'General',          1);

-- ─────────────────────────────────────────────────────────────
-- 17. SMART CARD
-- ─────────────────────────────────────────────────────────────
INSERT INTO Smart_Card VALUES (1,  250.00, 'Active',   '2026-03-31', 1);
INSERT INTO Smart_Card VALUES (2,   80.00, 'Active',   '2026-06-30', 2);
INSERT INTO Smart_Card VALUES (3,  500.00, 'Active',   '2026-12-31', 3);
INSERT INTO Smart_Card VALUES (4,  150.00, 'Active',   '2025-12-31', 4);
INSERT INTO Smart_Card VALUES (5,   20.00, 'Low',      '2026-03-31', 5);
INSERT INTO Smart_Card VALUES (6,  320.00, 'Active',   '2026-09-30', 6);
INSERT INTO Smart_Card VALUES (7,    0.00, 'Blocked',  '2024-12-31', 7);
INSERT INTO Smart_Card VALUES (8,  100.00, 'Active',   '2026-06-30', 8);
INSERT INTO Smart_Card VALUES (9,  430.00, 'Active',   '2026-12-31', 9);
INSERT INTO Smart_Card VALUES (10, 175.00, 'Active',   '2026-03-31', 10);
INSERT INTO Smart_Card VALUES (11, 220.00, 'Active',   '2026-06-30', 12);
INSERT INTO Smart_Card VALUES (12,  60.00, 'Low',      '2026-03-31', 13);
INSERT INTO Smart_Card VALUES (13, 390.00, 'Active',   '2026-09-30', 15);
INSERT INTO Smart_Card VALUES (14, 110.00, 'Active',   '2026-06-30', 18);

-- ─────────────────────────────────────────────────────────────
-- 18. FARE  (operator + zone + concession combos)
-- ─────────────────────────────────────────────────────────────
-- GMRC Metro fares (zone-based, real ₹5-₹40 structure)
INSERT INTO Fare VALUES (1,  'General',          'Token',     1, 1);   -- Zone1 ₹5
INSERT INTO Fare VALUES (2,  'General',          'Token',     2, 1);   -- Zone2 ₹10
INSERT INTO Fare VALUES (3,  'General',          'Token',     3, 1);   -- Zone3 ₹15
INSERT INTO Fare VALUES (4,  'General',          'Token',     4, 1);   -- Zone4 ₹20
INSERT INTO Fare VALUES (5,  'General',          'Token',     5, 1);   -- Zone5 ₹25
INSERT INTO Fare VALUES (6,  'General',          'Token',     6, 1);   -- Zone6 ₹40
INSERT INTO Fare VALUES (7,  'Student',          'Concession',3, 1);   -- Student Metro
INSERT INTO Fare VALUES (8,  'Senior',           'Concession',3, 1);   -- Senior Metro
INSERT INTO Fare VALUES (9,  'Differently-Abled','Concession',3, 1);   -- DA Metro
-- BRTS fares (flat ₹6)
INSERT INTO Fare VALUES (10, 'General',          'Token',     7, 2);
INSERT INTO Fare VALUES (11, 'Student',          'Concession',7, 2);
-- AMTS fares (flat ₹7)
INSERT INTO Fare VALUES (12, 'General',          'Token',     8, 3);
INSERT INTO Fare VALUES (13, 'Senior',           'Concession',8, 3);
-- GSRTC fares (₹15)
INSERT INTO Fare VALUES (14, 'General',          'Token',     9, 4);

-- ─────────────────────────────────────────────────────────────
-- 19. PASS  (monthly/weekly passes)
-- ─────────────────────────────────────────────────────────────
INSERT INTO Pass VALUES (1,  '2024-01-01', '2024-01-31',  600.00, 20.00, 1,  6, 1);  -- Metro monthly general
INSERT INTO Pass VALUES (2,  '2024-01-01', '2024-01-31',  400.00, 15.00, 3,  7, 1);  -- Metro monthly student
INSERT INTO Pass VALUES (3,  '2024-02-01', '2024-02-07',  150.00,  6.00, 2, 10, 2);  -- BRTS weekly
INSERT INTO Pass VALUES (4,  '2024-01-01', '2024-01-31',  300.00,  7.00, 6, 12, 3);  -- AMTS monthly
INSERT INTO Pass VALUES (5,  '2024-03-01', '2024-03-31',  600.00, 20.00, 8,  6, 1);  -- Metro monthly senior
INSERT INTO Pass VALUES (6,  '2024-02-01', '2024-02-29',  500.00, 20.00, 9,  6, 1);  -- Metro monthly general
INSERT INTO Pass VALUES (7,  '2024-01-15', '2024-01-21',  100.00,  6.00, 5, 10, 2);  -- BRTS weekly
INSERT INTO Pass VALUES (8,  '2024-03-01', '2024-03-31',  600.00, 20.00,12,  6, 1);  -- Metro monthly general

-- ─────────────────────────────────────────────────────────────
-- 20. TRIP
-- ─────────────────────────────────────────────────────────────
INSERT INTO Trip VALUES (1,  '2024-01-15', 'Completed', NULL,         1, 1, 1);   -- Blue Line on time
INSERT INTO Trip VALUES (2,  '2024-01-15', 'Completed', NULL,         2, 4, 3);   -- Red Line on time
INSERT INTO Trip VALUES (3,  '2024-01-16', 'Delayed',   '12 min',     1, 2, 2);   -- Blue Line delayed
INSERT INTO Trip VALUES (4,  '2024-01-16', 'Completed', NULL,         4, 7, 6);   -- BRTS Rt1 on time
INSERT INTO Trip VALUES (5,  '2024-01-17', 'Completed', NULL,         5, 9, 8);   -- BRTS Rt2 on time
INSERT INTO Trip VALUES (6,  '2024-01-17', 'Delayed',   '8 min',      2, 5, 4);   -- Red Line delayed
INSERT INTO Trip VALUES (7,  '2024-01-18', 'Completed', NULL,         10,12,13);  -- AMTS Rt31
INSERT INTO Trip VALUES (8,  '2024-01-18', 'Completed', NULL,         13,15,17);  -- GSRTC Rt101
INSERT INTO Trip VALUES (9,  '2024-01-19', 'Cancelled', 'Vehicle fault',1,3, 1);  -- Blue Line cancelled
INSERT INTO Trip VALUES (10, '2024-01-20', 'Completed', NULL,          3, 6, 5);  -- Yellow Line
INSERT INTO Trip VALUES (11, '2024-01-20', 'Completed', NULL,          6,10, 6);  -- BRTS Rt5
INSERT INTO Trip VALUES (12, '2024-01-21', 'Completed', NULL,          11,13,15); -- AMTS Rt52
INSERT INTO Trip VALUES (13, '2024-01-22', 'Delayed',   '20 min',      4, 8, 7);  -- BRTS Rt1 delayed
INSERT INTO Trip VALUES (14, '2024-01-22', 'Completed', NULL,           2, 4, 3);  -- Red Line
INSERT INTO Trip VALUES (15, '2024-01-23', 'Completed', NULL,           1, 1, 2);  -- Blue Line

-- ─────────────────────────────────────────────────────────────
-- 21. TRIP_STOP
-- ─────────────────────────────────────────────────────────────
-- Trip 1 (Blue Line, Vastral Gam → Thaltej, on time)
INSERT INTO Trip_Stop VALUES (1,  1,  1, '06:20:00', '06:20:00', '06:20:00');
INSERT INTO Trip_Stop VALUES (1,  2,  2, '06:22:00', '06:22:00', '06:22:00');
INSERT INTO Trip_Stop VALUES (1,  5,  3, '06:26:00', '06:26:00', '06:26:00');
INSERT INTO Trip_Stop VALUES (1, 11,  4, '06:35:00', '06:35:00', '06:34:00');
INSERT INTO Trip_Stop VALUES (1, 15,  5, '06:44:00', '06:44:00', '06:44:00');
INSERT INTO Trip_Stop VALUES (1, 17,  6, '06:52:00', '06:52:00', '06:52:00');

-- Trip 2 (Red Line, APMC → Motera, on time)
INSERT INTO Trip_Stop VALUES (2, 19,  1, '07:00:00', '07:00:00', '07:00:00');
INSERT INTO Trip_Stop VALUES (2, 22,  2, '07:06:00', '07:06:00', '07:06:00');
INSERT INTO Trip_Stop VALUES (2, 24,  3, '07:14:00', '07:14:00', '07:14:00');
INSERT INTO Trip_Stop VALUES (2, 27,  4, '07:22:00', '07:22:00', '07:22:00');
INSERT INTO Trip_Stop VALUES (2, 32,  5, '07:35:00', '07:35:00', '07:35:00');

-- Trip 3 (Blue Line, delayed 12 min)
INSERT INTO Trip_Stop VALUES (3,  1,  1, '08:00:00', '08:12:00', '08:12:00');
INSERT INTO Trip_Stop VALUES (3,  5,  2, '08:04:00', '08:16:00', '08:15:00');
INSERT INTO Trip_Stop VALUES (3, 11,  3, '08:13:00', '08:25:00', '08:25:00');
INSERT INTO Trip_Stop VALUES (3, 17,  4, '08:22:00', '08:34:00', '08:33:00');

-- Trip 4 (BRTS Rt1 on time)
INSERT INTO Trip_Stop VALUES (4, 40,  1, '09:00:00', '09:00:00', '09:00:00');
INSERT INTO Trip_Stop VALUES (4, 44,  2, '09:08:00', '09:09:00', '09:08:00');
INSERT INTO Trip_Stop VALUES (4, 41,  3, '09:20:00', '09:21:00', '09:20:00');

-- Trip 13 (BRTS Rt1, delayed 20 min)
INSERT INTO Trip_Stop VALUES (13, 40, 1, '14:00:00', '14:20:00', '14:20:00');
INSERT INTO Trip_Stop VALUES (13, 44, 2, '14:08:00', '14:28:00', '14:27:00');
INSERT INTO Trip_Stop VALUES (13, 41, 3, '14:20:00', '14:40:00', '14:39:00');

-- ─────────────────────────────────────────────────────────────
-- 22. TICKET TRANSACTION
-- ─────────────────────────────────────────────────────────────
INSERT INTO Ticket_Transaction VALUES (1,  'Token',       20.00, 'Cash',        'Single Journey',  1, 4, NULL, 1);
INSERT INTO Ticket_Transaction VALUES (2,  'Smart Card',  10.00, 'Smart Card',  'Single Journey',  2, 2, 2,    2);
INSERT INTO Ticket_Transaction VALUES (3,  'Token',       15.00, 'UPI',         'Single Journey',  3, 3, NULL, 1);
INSERT INTO Ticket_Transaction VALUES (4,  'Monthly Pass',600.00,'Cash',        'Monthly Pass',    1, 6, 1,    NULL);
INSERT INTO Ticket_Transaction VALUES (5,  'Smart Card',   6.00, 'Smart Card',  'Single Journey',  5, 10,5,   4);
INSERT INTO Ticket_Transaction VALUES (6,  'Token',        6.00, 'UPI',         'Single Journey',  6, 10,NULL, 5);
INSERT INTO Ticket_Transaction VALUES (7,  'Monthly Pass',400.00,'Smart Card',  'Student Pass',    3, 7, 3,    NULL);
INSERT INTO Ticket_Transaction VALUES (8,  'Token',        7.00, 'Cash',        'Single Journey',  4, 12,NULL, 7);
INSERT INTO Ticket_Transaction VALUES (9,  'Smart Card',  15.00, 'Smart Card',  'Single Journey',  9, 3, 9,    2);
INSERT INTO Ticket_Transaction VALUES (10, 'Token',       15.00, 'Cash',        'Single Journey', 10, 3, NULL, 1);
INSERT INTO Ticket_Transaction VALUES (11, 'Smart Card',  25.00, 'Smart Card',  'Single Journey',  8, 5, 8,    2);
INSERT INTO Ticket_Transaction VALUES (12, 'Token',       40.00, 'UPI',         'Single Journey', 12, 6, NULL, 1);
INSERT INTO Ticket_Transaction VALUES (13, 'Token',        6.00, 'Cash',        'Single Journey', 14, 10,NULL, 4);
INSERT INTO Ticket_Transaction VALUES (14, 'Smart Card',  15.00, 'Smart Card',  'Single Journey', 15, 3, 13,   7);
INSERT INTO Ticket_Transaction VALUES (15, 'Token',       10.00, 'UPI',         'Single Journey', 17, 2, NULL, 3);
INSERT INTO Ticket_Transaction VALUES (16, 'Token',       15.00, 'Cash',        'Single Journey',  6, 14,NULL, 8);
INSERT INTO Ticket_Transaction VALUES (17, 'Smart Card',  20.00, 'Smart Card',  'Single Journey', 18, 4, 14,   2);
INSERT INTO Ticket_Transaction VALUES (18, 'Monthly Pass',600.00,'UPI',         'Monthly Pass',   15, 6, 13,   NULL);
INSERT INTO Ticket_Transaction VALUES (19, 'Token',       10.00, 'Cash',        'Single Journey', 20, 2, NULL, 11);
INSERT INTO Ticket_Transaction VALUES (20, 'Token',       15.00, 'UPI',         'Single Journey',  7, 3, NULL, 3);
INSERT INTO Ticket_Transaction VALUES (21, 'Smart Card',   6.00, 'Smart Card',  'Single Journey', 16, 10,NULL, 11);

-- ─────────────────────────────────────────────────────────────
-- 23. COMPLAINT
-- ─────────────────────────────────────────────────────────────
INSERT INTO Complaint VALUES (1,  'Delay',         'Resolved', 'Train delayed by 12 minutes on Blue Line',      '2024-01-18', 'Vastral Gam to Thaltej, morning peak', 1,  3, 1);
INSERT INTO Complaint VALUES (2,  'Overcrowding',  'Open',     'Bus extremely crowded during peak hours',        NULL,         'BRTS Route 1, RTO Circle, 9am',        2,  4, 2);
INSERT INTO Complaint VALUES (3,  'Cleanliness',   'Resolved', 'Dirty seats on AMTS bus, Route 31',             '2024-01-20', 'Geeta Mandir to Bopal route',          6,  7, 3);
INSERT INTO Complaint VALUES (4,  'AC Not Working','Resolved', 'Air conditioning not working in coach 2',       '2024-01-22', 'Blue Line BL-T02, morning trip',        8,  3, 1);
INSERT INTO Complaint VALUES (5,  'Rude Behaviour','In Progress','Conductor was rude to elderly passenger',      NULL,         'GSRTC bus Gandhinagar route',          11, 8, 4);
INSERT INTO Complaint VALUES (6,  'Delay',         'Resolved', 'BRTS Route 1 delayed 20 min, missed connection','2024-01-25', 'RTO Circle to Maninagar, afternoon',   14, 13,2);
INSERT INTO Complaint VALUES (7,  'Safety',        'Open',     'Platform edge gap too wide at Kalupur station', NULL,         'Blue Line Kalupur station',             4,  NULL,1);
INSERT INTO Complaint VALUES (8,  'Ticketing',     'Resolved', 'Smart card not working at entry gate',          '2024-01-21', 'Thaltej station entry gate 3',          5,  1, 1);
INSERT INTO Complaint VALUES (9,  'Delay',         'Open',     'Red Line delayed frequently in morning',        NULL,         'APMC to Gandhigram stretch',            9,  6, 1);
INSERT INTO Complaint VALUES (10, 'Lost & Found',  'Resolved', 'Left umbrella on Blue Line train',              '2024-01-24', 'Found at Thaltej station lost & found',18, 15,1);

