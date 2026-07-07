-- =============================================================
-- AGUTS – SQL SELECT Queries (Final Submission)
-- IT-214 DBMS | Lab Group 5 | DA-IICT | Winter 2025-26
-- Ahmedabad Gandhinagar Unified Transit System
-- =============================================================
-- Group Members:
--   Hari Sharma        : 202401195
--   Arjunsinh Vaghela  : 202401235
--   Tirth Ditani       : 202401417
--   Neeti Gunsai       : 202401423
--   Rudra Bhatt        : 202401461
-- =============================================================
-- Scenario A: Network & Infrastructure     
-- Scenario B: Schedule & Trip Operations   
-- Scenario C: Passenger & Smart Card       
-- Scenario D: Ticketing & Revenue          
-- Scenario E: Fleet & Maintenance          
-- Scenario F: Staff & Operations           

-- =============================================================
-- SCENARIO A: NETWORK & INFRASTRUCTURE
-- Real-world use: Passenger journey planner, admin route
-- management, city transport planning dashboard
-- =============================================================
-- Q01. All stops on Blue Line with sequence and zone name.
--      Used by: Journey planner, station display boards
SELECT rs.sequence_no, s.stop_name, s.stop_type,
       fz.zone_name
FROM   Route_Stop rs
JOIN   Stop s       ON s.stop_id  = rs.stop_id
JOIN   Fare_Zone fz ON fz.zone_id = rs.zone_id
JOIN   Route r      ON r.route_id = rs.route_id
WHERE  r.route_number = 'BL-01'
ORDER  BY rs.sequence_no;

-- Q02. Total distinct stops served per transit operator.
--      Used by: Admin network summary dashboard
SELECT o.operator_name,
       COUNT(DISTINCT rs.stop_id) AS total_stops_served
FROM   Transit_Operator o
JOIN   Route r       ON r.operator_id = o.operator_id
JOIN   Route_Stop rs ON rs.route_id   = r.route_id
GROUP  BY o.operator_id, o.operator_name
ORDER  BY total_stops_served DESC;

-- Q03. All routes per operator with distance and stop count.
--      Used by: Route management, timetable publishing
SELECT o.operator_name, r.route_number, r.route_name,
       r.distance_km,
       COUNT(rs.stop_id) AS stop_count
FROM   Transit_Operator o
JOIN   Route r       ON r.operator_id = o.operator_id
JOIN   Route_Stop rs ON rs.route_id   = r.route_id
GROUP  BY o.operator_id, o.operator_name,
          r.route_id, r.route_number,
          r.route_name, r.distance_km
ORDER  BY o.operator_name, r.route_number;

-- Q04. All interchange stops with type and description.
--      Used by: Journey planner, station signage
SELECT s.stop_name, s.stop_type,
       i.interchange_type, i.description, c.city_name
FROM   Interchange i
JOIN   Stop s ON s.stop_id = i.stop_id
JOIN   City c ON c.city_id = s.city_id
ORDER  BY c.city_name, s.stop_name;

-- Q05. Stops serving more than one route (transfer points).
--      Used by: Intermodal journey planning
SELECT s.stop_name, s.stop_type,
       COUNT(DISTINCT rs.route_id) AS route_count,
       STRING_AGG(r.route_number, ', '
           ORDER BY r.route_number) AS routes_served
FROM   Stop s
JOIN   Route_Stop rs ON rs.stop_id = s.stop_id
JOIN   Route r       ON r.route_id = rs.route_id
GROUP  BY s.stop_id, s.stop_name, s.stop_type
HAVING COUNT(DISTINCT rs.route_id) > 1
ORDER  BY route_count DESC;

-- Q06. Fare lookup for all concession types between two zones.
--      Used by: Real-time fare calculator (GMRC app feature)
SELECT f.concession_type,
       fz_from.zone_name AS from_zone,
       fz_to.zone_name   AS to_zone,
       f.fare_amount      AS fare_inr,
       o.operator_name
FROM   Fare f
JOIN   Fare_Zone fz_from ON fz_from.zone_id = f.from_zone_id
JOIN   Fare_Zone fz_to   ON fz_to.zone_id   = f.to_zone_id
JOIN   Transit_Operator o ON o.operator_id  = f.operator_id
WHERE  f.from_zone_id = 1
  AND  f.to_zone_id   = 4
ORDER  BY o.operator_name, f.concession_type;

-- Q07. Stop count per fare zone per operator.
--      Used by: Zone-based pricing analysis
SELECT o.operator_name, fz.zone_name,
       COUNT(DISTINCT rs.stop_id) AS stop_count
FROM   Fare_Zone fz
JOIN   Route_Stop rs ON rs.zone_id   = fz.zone_id
JOIN   Route r       ON r.route_id   = rs.route_id
JOIN   Transit_Operator o
                     ON o.operator_id = r.operator_id
GROUP  BY o.operator_id, o.operator_name,
          fz.zone_id, fz.zone_name
ORDER  BY o.operator_name, fz.zone_name;

-- Q08. Longest route per operator by distance.
--      Used by: Operations planning, scheduling
SELECT o.operator_name, r.route_number,
       r.route_name, r.distance_km
FROM   Route r
JOIN   Transit_Operator o ON o.operator_id = r.operator_id
WHERE  r.distance_km = (
    SELECT MAX(r2.distance_km) FROM Route r2
    WHERE  r2.operator_id = r.operator_id
)
ORDER  BY r.distance_km DESC;

-- Q09. All depots with operator, city, and address.
--      Used by: Depot management, vehicle dispatch
SELECT d.depot_id, d.depot_name, d.address,
       o.operator_name, c.city_name
FROM   Depot d
JOIN   Transit_Operator o ON o.operator_id = d.operator_id
JOIN   City c             ON c.city_id     = d.city_id
ORDER  BY o.operator_name, d.depot_name;

-- Q10. Routes passing through Kalupur Railway Station.
--      Used by: Journey planning from/to railway station
SELECT r.route_number, r.route_name, o.operator_name,
       rs.sequence_no AS stop_position
FROM   Route_Stop rs
JOIN   Stop s  ON s.stop_id  = rs.stop_id
JOIN   Route r ON r.route_id = rs.route_id
JOIN   Transit_Operator o ON o.operator_id = r.operator_id
WHERE  s.stop_name LIKE '%Kalupur%'
ORDER  BY o.operator_name, r.route_number;

-- Q11. Total network length and route count per operator.
--      Used by: Annual report, city transport statistics
SELECT o.operator_name,
       COUNT(r.route_id)           AS total_routes,
       SUM(r.distance_km)          AS total_network_km,
       ROUND(AVG(r.distance_km),2) AS avg_route_km
FROM   Transit_Operator o
JOIN   Route r ON r.operator_id = o.operator_id
GROUP  BY o.operator_id, o.operator_name
ORDER  BY total_network_km DESC;

-- Q12. Routes with the maximum number of stops per operator.
--      Used by: Capacity and coverage planning
SELECT o.operator_name, r.route_number,
       r.route_name,
       COUNT(rs.stop_id) AS stop_count
FROM   Transit_Operator o
JOIN   Route r       ON r.operator_id = o.operator_id
JOIN   Route_Stop rs ON rs.route_id   = r.route_id
GROUP  BY o.operator_id, o.operator_name,
          r.route_id, r.route_number, r.route_name
HAVING COUNT(rs.stop_id) = (
    SELECT MAX(cnt) FROM (
        SELECT COUNT(rs2.stop_id) AS cnt
        FROM   Route r2
        JOIN   Route_Stop rs2 ON rs2.route_id = r2.route_id
        WHERE  r2.operator_id = r.operator_id
        GROUP  BY r2.route_id
    ) sub
)
ORDER  BY o.operator_name;

-- Q13. Next stop on Red Line using LEAD window function.
--      Used by: Real-time train information displays
SELECT rs.sequence_no, s.stop_name,
       LEAD(s.stop_name)
           OVER (PARTITION BY rs.route_id
                 ORDER BY rs.sequence_no) AS next_stop
FROM   Route_Stop rs
JOIN   Stop  s ON s.stop_id  = rs.stop_id
JOIN   Route r ON r.route_id = rs.route_id
WHERE  r.route_number = 'RL-01'
ORDER  BY rs.sequence_no;

-- Q14. Routes serving each city per operator.
--      Used by: City-level transport coverage report
SELECT c.city_name, o.operator_name,
       COUNT(DISTINCT r.route_id) AS routes_serving
FROM   City c
JOIN   Stop s        ON s.city_id    = c.city_id
JOIN   Route_Stop rs ON rs.stop_id   = s.stop_id
JOIN   Route r       ON r.route_id   = rs.route_id
JOIN   Transit_Operator o
                     ON o.operator_id = r.operator_id
GROUP  BY c.city_id, c.city_name,
          o.operator_id, o.operator_name
ORDER  BY c.city_name, routes_serving DESC;

-- Q15. All routes on each Metro Line with distance.
--      Used by: Metro network overview, website display
SELECT ml.line_name, ml.line_code,
       r.route_number, r.route_name, r.distance_km
FROM   Metro_Line ml
JOIN   Route r ON r.line_id = ml.line_id
ORDER  BY ml.line_name, r.route_number;

-- Q16. Geographic coordinates of all stops (for map display).
--      Used by: Passenger app map, route visualization
SELECT s.stop_id, s.stop_name, s.stop_type,
       s.latitude, s.longitude, c.city_name,
       o.operator_name
FROM   Stop s
JOIN   City c        ON c.city_id    = s.city_id
JOIN   Route_Stop rs ON rs.stop_id   = s.stop_id
JOIN   Route r       ON r.route_id   = rs.route_id
JOIN   Transit_Operator o
                     ON o.operator_id = r.operator_id
GROUP  BY s.stop_id, s.stop_name, s.stop_type,
          s.latitude, s.longitude, c.city_name,
          o.operator_id, o.operator_name
ORDER  BY o.operator_name, s.stop_name;


-- =============================================================
-- SCENARIO B: SCHEDULE & TRIP OPERATIONS
-- Real-world use: Operations control centre, driver app,
-- delay management dashboard
-- =============================================================

-- Q17. All trips with route, vehicle, staff, and status.
--      Used by: Operations dashboard, daily trip log
SELECT t.trip_id, t.trip_date,
       r.route_number, r.route_name, o.operator_name,
       v.registration_no,
       st.first_name || ' ' || st.last_name AS staff_name,
       st.role, t.trip_status
FROM   Trip t
JOIN   Route r ON r.route_id = t.route_id
JOIN   Transit_Operator o ON o.operator_id = r.operator_id
JOIN   Vehicle v ON v.vehicle_id = t.vehicle_id
JOIN   Staff  st ON st.staff_id  = t.staff_id
ORDER  BY t.trip_date, r.route_number;

-- Q18. All delayed trips with operator and staff details.
--      Used by: Delay management, passenger alerts
SELECT t.trip_id, t.trip_date, r.route_number,
       o.operator_name, v.registration_no,
       st.first_name || ' ' || st.last_name AS staff_name,
       t.trip_status
FROM   Trip t
JOIN   Route r ON r.route_id = t.route_id
JOIN   Transit_Operator o ON o.operator_id = r.operator_id
JOIN   Vehicle v ON v.vehicle_id = t.vehicle_id
JOIN   Staff  st ON st.staff_id  = t.staff_id
WHERE  t.trip_status = 'Delayed'
ORDER  BY t.trip_date;

-- Q19. Stop-by-stop timetable: scheduled vs actual for a trip.
--      Used by: Real-time tracking, post-trip analysis
SELECT ts.sequence_no, s.stop_name,
       ts.sched_arrival  AS scheduled,
       ts.actual_arrival AS actual,
       (ts.actual_arrival - ts.sched_arrival) AS delay
FROM   Trip_Stop ts
JOIN   Stop s ON s.stop_id = ts.stop_id
WHERE  ts.trip_id = 3
ORDER  BY ts.sequence_no;

-- Q20. On-time performance (OTP) percentage per operator.
--      Used by: KPI dashboard, management reports
SELECT o.operator_name,
       COUNT(t.trip_id) AS total_trips,
       SUM(CASE WHEN t.trip_status='Completed'
                THEN 1 ELSE 0 END) AS on_time,
       SUM(CASE WHEN t.trip_status='Delayed'
                THEN 1 ELSE 0 END) AS delayed,
       SUM(CASE WHEN t.trip_status='Cancelled'
                THEN 1 ELSE 0 END) AS cancelled,
       ROUND(100.0 *
           SUM(CASE WHEN t.trip_status='Completed'
                    THEN 1 ELSE 0 END)
           / COUNT(t.trip_id), 1) AS otp_percent
FROM   Trip t
JOIN   Route r ON r.route_id = t.route_id
JOIN   Transit_Operator o ON o.operator_id = r.operator_id
GROUP  BY o.operator_id, o.operator_name
ORDER  BY otp_percent DESC;

-- Q21. All cancelled trips with route and assigned staff.
--      Used by: Incident log, passenger refund processing
SELECT t.trip_id, t.trip_date, r.route_number,
       r.route_name, o.operator_name,
       v.registration_no,
       st.first_name || ' ' || st.last_name AS staff_name
FROM   Trip t
JOIN   Route r ON r.route_id = t.route_id
JOIN   Transit_Operator o ON o.operator_id = r.operator_id
JOIN   Vehicle v ON v.vehicle_id = t.vehicle_id
JOIN   Staff  st ON st.staff_id  = t.staff_id
WHERE  t.trip_status = 'Cancelled'
ORDER  BY t.trip_date;

-- Q22. Routes with the most delayed trips.
--      Used by: Route performance review, bottleneck detection
SELECT r.route_number, r.route_name, o.operator_name,
       COUNT(t.trip_id) AS delayed_trips
FROM   Trip t
JOIN   Route r ON r.route_id = t.route_id
JOIN   Transit_Operator o ON o.operator_id = r.operator_id
WHERE  t.trip_status = 'Delayed'
GROUP  BY r.route_id, r.route_number,
          r.route_name, o.operator_name
ORDER  BY delayed_trips DESC;

-- Q23. All trips for a specific staff member (Manish Chauhan).
--      Used by: Driver/Motorman personal duty log
SELECT t.trip_id, t.trip_date, r.route_number,
       r.route_name, v.registration_no, t.trip_status
FROM   Trip t
JOIN   Route r   ON r.route_id   = t.route_id
JOIN   Vehicle v ON v.vehicle_id = t.vehicle_id
JOIN   Staff  st ON st.staff_id  = t.staff_id
WHERE  st.first_name = 'Manish'
  AND  st.last_name  = 'Chauhan'
ORDER  BY t.trip_date;

-- Q24. Trip count and on-time performance per vehicle.
--      Used by: Fleet performance dashboard
SELECT v.registration_no, o.operator_name,
       COUNT(t.trip_id) AS total_trips,
       SUM(CASE WHEN t.trip_status='Completed'
                THEN 1 ELSE 0 END) AS completed,
       SUM(CASE WHEN t.trip_status='Delayed'
                THEN 1 ELSE 0 END) AS delayed
FROM   Vehicle v
JOIN   Transit_Operator o ON o.operator_id = v.operator_id
LEFT JOIN Trip t ON t.vehicle_id = v.vehicle_id
GROUP  BY v.vehicle_id, v.registration_no, o.operator_name
ORDER  BY total_trips DESC;

-- Q25. Routes with no trips recorded at all (unserved routes).
--      Used by: Service gap detection, network audit
SELECT r.route_number, r.route_name, o.operator_name
FROM   Route r
JOIN   Transit_Operator o ON o.operator_id = r.operator_id
WHERE  r.route_id NOT IN (SELECT DISTINCT route_id FROM Trip)
ORDER  BY o.operator_name, r.route_number;

-- Q26. Daily trip count trend across Jan-Mar 2024.
--      Used by: Operations trend analysis, monthly report
SELECT t.trip_date,
       COUNT(t.trip_id) AS daily_trips,
       SUM(CASE WHEN t.trip_status='Completed'
                THEN 1 ELSE 0 END) AS completed,
       SUM(CASE WHEN t.trip_status='Delayed'
                THEN 1 ELSE 0 END) AS delayed,
       SUM(CASE WHEN t.trip_status='Cancelled'
                THEN 1 ELSE 0 END) AS cancelled
FROM   Trip t
WHERE  t.trip_date BETWEEN '2024-01-01' AND '2024-03-31'
GROUP  BY t.trip_date
ORDER  BY t.trip_date;

-- Q27. Vehicles that operated on more than one distinct route.
--      Used by: Fleet flexibility analysis, depot planning
SELECT v.registration_no, o.operator_name,
       COUNT(DISTINCT t.route_id) AS routes_operated,
       STRING_AGG(DISTINCT r.route_number, ', '
           ORDER BY r.route_number) AS route_list
FROM   Trip t
JOIN   Vehicle v ON v.vehicle_id = t.vehicle_id
JOIN   Route   r ON r.route_id   = t.route_id
JOIN   Transit_Operator o ON o.operator_id = v.operator_id
GROUP  BY v.vehicle_id, v.registration_no, o.operator_name
HAVING COUNT(DISTINCT t.route_id) > 1
ORDER  BY routes_operated DESC;


-- =============================================================
-- SCENARIO C: PASSENGER & SMART CARD MANAGEMENT
-- Real-world use: Passenger app, customer care portal,
-- smart card management system (like GMRC Go Card)
-- =============================================================

-- Q28. Full travel history for a passenger (passenger_id = 1).
--      Used by: Passenger app "My Trips" section
SELECT p.first_name || ' ' || p.last_name AS passenger,
       tt.txn_id, tt.ticket_type,
       DATE(tt.txn_datetime) AS trip_date,
       r.route_name, o.operator_name,
       tt.amount AS fare_inr, tt.payment_mode
FROM   Ticket_Transaction tt
JOIN   Passenger p ON p.passenger_id = tt.passenger_id
JOIN   Trip      t ON t.trip_id      = tt.trip_id
JOIN   Route     r ON r.route_id     = t.route_id
JOIN   Transit_Operator o ON o.operator_id = r.operator_id
WHERE  p.passenger_id = 1
ORDER  BY tt.txn_datetime;

-- Q29. Passengers with low smart card balance (below Rs.50).
--      Used by: Low-balance alert system, auto-recharge trigger
SELECT p.passenger_id,
       p.first_name || ' ' || p.last_name AS passenger_name,
       p.email, pp.phone,
       sc.card_id, sc.balance,
       sc.card_status, sc.expiry_date
FROM   Smart_Card sc
JOIN   Passenger p ON p.passenger_id = sc.passenger_id
LEFT JOIN Passenger_Phone pp
    ON pp.passenger_id = p.passenger_id
   AND pp.phone_type   = 'Mobile'
WHERE  sc.balance < 50
  AND  sc.card_status NOT IN ('Blocked','Expired')
ORDER  BY sc.balance;

-- Q30. All blocked or expired smart cards with contact.
--      Used by: Smart card renewal campaign, block resolution
SELECT sc.card_id, sc.card_status,
       p.first_name || ' ' || p.last_name AS passenger,
       p.email, pp.phone,
       sc.balance, sc.issue_date, sc.expiry_date
FROM   Smart_Card sc
JOIN   Passenger p ON p.passenger_id = sc.passenger_id
LEFT JOIN Passenger_Phone pp
    ON pp.passenger_id = p.passenger_id
   AND pp.phone_type   = 'Mobile'
WHERE  sc.card_status IN ('Blocked','Expired')
ORDER  BY sc.expiry_date;

-- Q31. Active passes with days remaining.
--      Used by: Passenger app "My Passes", expiry alert
SELECT ps.pass_id, ps.pass_type,
       p.first_name || ' ' || p.last_name AS passenger,
       p.concession_type, o.operator_name,
       ps.valid_from, ps.valid_to, ps.amount_paid,
       (ps.valid_to - CURRENT_DATE) AS days_remaining
FROM   Pass ps
JOIN   Passenger p ON p.passenger_id = ps.passenger_id
JOIN   Transit_Operator o ON o.operator_id = ps.operator_id
WHERE  ps.valid_to >= CURRENT_DATE
ORDER  BY days_remaining;

-- Q32. Passenger count by concession category per city.
--      Used by: Concession management, demographic reporting
SELECT c.city_name, p.concession_type,
       COUNT(p.passenger_id) AS count
FROM   Passenger p
JOIN   City c ON c.city_id = p.city_id
GROUP  BY c.city_id, c.city_name, p.concession_type
ORDER  BY c.city_name, count DESC;

-- Q33. Passenger registration growth by month.
--      Used by: User acquisition tracking (like real apps)
SELECT TO_CHAR(sc.issue_date, 'YYYY-MM') AS month,
       COUNT(sc.card_id) AS new_cards_issued,
       COUNT(DISTINCT sc.passenger_id) AS new_passengers
FROM   Smart_Card sc
GROUP  BY TO_CHAR(sc.issue_date, 'YYYY-MM')
ORDER  BY month;

-- Q34. Passengers who filed more than one complaint.
--      Used by: Customer care escalation, chronic complainers
SELECT p.first_name || ' ' || p.last_name AS passenger,
       p.email,
       COUNT(c.complaint_id) AS total_complaints,
       SUM(CASE WHEN c.status='Open'
                THEN 1 ELSE 0 END) AS open_count
FROM   Passenger p
JOIN   Complaint c ON c.passenger_id = p.passenger_id
GROUP  BY p.passenger_id, p.first_name,
          p.last_name, p.email
HAVING COUNT(c.complaint_id) > 1
ORDER  BY total_complaints DESC;

-- Q35. Top 10 most frequent travellers by transaction count.
--      Used by: Loyalty programme, frequent rider recognition
SELECT p.first_name || ' ' || p.last_name AS passenger,
       p.concession_type,
       COUNT(tt.txn_id) AS total_transactions,
       SUM(tt.amount)   AS total_spent_inr
FROM   Passenger p
JOIN   Ticket_Transaction tt
    ON tt.passenger_id = p.passenger_id
GROUP  BY p.passenger_id, p.first_name,
          p.last_name, p.concession_type
ORDER  BY total_transactions DESC
LIMIT  10;

-- Q36. All complaints filed by passenger_id = 1 with route.
--      Used by: Customer care — complaint history view
SELECT c.complaint_id, c.category, c.description,
       c.status, c.filed_date, c.resolved_date,
       r.route_name, o.operator_name
FROM   Complaint c
JOIN   Trip t ON t.trip_id = c.trip_id
JOIN   Route r ON r.route_id = t.route_id
JOIN   Transit_Operator o ON o.operator_id = r.operator_id
WHERE  c.passenger_id = 1
ORDER  BY c.filed_date;

-- Q37. All student passengers with smart card balance.
--      Used by: Student concession management
SELECT p.first_name || ' ' || p.last_name AS student,
       p.email,
       sc.card_id, sc.balance, sc.card_status
FROM   Passenger p
LEFT JOIN Smart_Card sc ON sc.passenger_id = p.passenger_id
WHERE  p.concession_type = 'Student'
ORDER  BY sc.balance;

-- Q38. Senior passengers with their active pass details.
--      Used by: Senior concession verification
SELECT p.first_name || ' ' || p.last_name
           AS senior_passenger,
       p.date_of_birth, c.city_name,
       ps.pass_id, ps.pass_type, o.operator_name,
       ps.valid_from, ps.valid_to
FROM   Passenger p
JOIN   Pass ps ON ps.passenger_id = p.passenger_id
JOIN   Transit_Operator o ON o.operator_id = ps.operator_id
JOIN   City c ON c.city_id = p.city_id
WHERE  p.concession_type = 'Senior'
ORDER  BY p.passenger_id;

-- Q39. Passengers who used more than one payment mode.
--      Used by: Payment behaviour analysis, UPI adoption study
SELECT p.first_name || ' ' || p.last_name AS passenger,
       STRING_AGG(DISTINCT tt.payment_mode, ', '
           ORDER BY tt.payment_mode) AS modes_used
FROM   Passenger p
JOIN   Ticket_Transaction tt
    ON tt.passenger_id = p.passenger_id
GROUP  BY p.passenger_id, p.first_name, p.last_name
HAVING COUNT(DISTINCT tt.payment_mode) > 1
ORDER  BY passenger;

-- Q40. Passengers who have never made any transaction.
--      Used by: Inactive user identification, outreach
SELECT p.passenger_id,
       p.first_name || ' ' || p.last_name AS passenger,
       p.email, p.concession_type
FROM   Passenger p
WHERE  p.passenger_id NOT IN (
    SELECT DISTINCT passenger_id FROM Ticket_Transaction
)
ORDER  BY p.passenger_id;


-- =============================================================
-- SCENARIO D: TICKETING & REVENUE
-- Real-world use: Finance dashboard, ticketing audit,
-- pass management system
-- =============================================================

-- Q41. Revenue per operator broken down by ticket type.
--      Used by: Finance — operator-wise income breakdown
SELECT o.operator_name, tt.ticket_type,
       COUNT(tt.txn_id)        AS transactions,
       SUM(tt.amount)          AS total_revenue_inr,
       ROUND(AVG(tt.amount),2) AS avg_fare_inr
FROM   Ticket_Transaction tt
JOIN   Trip t ON t.trip_id = tt.trip_id
JOIN   Route r ON r.route_id = t.route_id
JOIN   Transit_Operator o ON o.operator_id = r.operator_id
GROUP  BY o.operator_id, o.operator_name, tt.ticket_type
ORDER  BY o.operator_name, total_revenue_inr DESC;

-- Q42. Revenue breakdown by payment mode with percentage.
--      Used by: UPI/cash/card adoption analysis
SELECT tt.payment_mode,
       COUNT(tt.txn_id) AS txn_count,
       SUM(tt.amount)   AS revenue_inr,
       ROUND(100.0 * SUM(tt.amount)
             / (SELECT SUM(amount) FROM Ticket_Transaction),
             1) AS pct
FROM   Ticket_Transaction tt
GROUP  BY tt.payment_mode
ORDER  BY revenue_inr DESC;

-- Q43. Complete GMRC fare table for all concession categories.
--      Used by: Fare display at stations, app fare lookup
SELECT f.concession_type,
       fz_from.zone_name AS from_zone,
       fz_to.zone_name   AS to_zone,
       f.fare_amount      AS fare_inr
FROM   Fare f
JOIN   Fare_Zone fz_from ON fz_from.zone_id = f.from_zone_id
JOIN   Fare_Zone fz_to   ON fz_to.zone_id   = f.to_zone_id
JOIN   Transit_Operator o ON o.operator_id  = f.operator_id
WHERE  o.operator_name = 'GMRC'
ORDER  BY f.concession_type, f.from_zone_id, f.to_zone_id;

-- Q44. Daily revenue trend across Jan-Mar 2024.
--      Used by: Finance — revenue trend chart
SELECT DATE(tt.txn_datetime)  AS txn_date,
       COUNT(tt.txn_id)       AS daily_transactions,
       SUM(tt.amount)         AS daily_revenue_inr
FROM   Ticket_Transaction tt
WHERE  DATE(tt.txn_datetime)
       BETWEEN '2024-01-01' AND '2024-03-31'
GROUP  BY DATE(tt.txn_datetime)
ORDER  BY txn_date;

-- Q45. Concession-wise fare comparison: GMRC vs BRTS.
--      Used by: Policy comparison, subsidy calculation
SELECT o.operator_name, f.concession_type,
       MIN(f.fare_amount) AS min_fare,
       MAX(f.fare_amount) AS max_fare,
       ROUND(AVG(f.fare_amount),2) AS avg_fare
FROM   Fare f
JOIN   Transit_Operator o ON o.operator_id = f.operator_id
WHERE  o.operator_name IN ('GMRC','Janmarg BRTS')
GROUP  BY o.operator_id, o.operator_name, f.concession_type
ORDER  BY o.operator_name, f.concession_type;

-- Q46. Top 5 highest revenue transactions.
--      Used by: Audit, anomaly detection
SELECT tt.txn_id,
       p.first_name || ' ' || p.last_name AS passenger,
       tt.ticket_type, tt.amount, tt.payment_mode,
       DATE(tt.txn_datetime) AS txn_date, o.operator_name
FROM   Ticket_Transaction tt
JOIN   Passenger p ON p.passenger_id = tt.passenger_id
JOIN   Trip t ON t.trip_id = tt.trip_id
JOIN   Route r ON r.route_id = t.route_id
JOIN   Transit_Operator o ON o.operator_id = r.operator_id
ORDER  BY tt.amount DESC
LIMIT  5;

-- Q47. Average and range of fare per ticket type.
--      Used by: Fare policy review, pricing analytics
SELECT tt.ticket_type,
       COUNT(tt.txn_id)        AS transactions,
       ROUND(AVG(tt.amount),2) AS avg_fare_inr,
       MIN(tt.amount)          AS min_fare,
       MAX(tt.amount)          AS max_fare
FROM   Ticket_Transaction tt
GROUP  BY tt.ticket_type
ORDER  BY avg_fare_inr DESC;

-- Q48. Revenue generated per route.
--      Used by: Route profitability analysis
SELECT r.route_number, r.route_name, o.operator_name,
       COUNT(tt.txn_id) AS transactions,
       SUM(tt.amount)   AS route_revenue_inr
FROM   Ticket_Transaction tt
JOIN   Trip t ON t.trip_id = tt.trip_id
JOIN   Route r ON r.route_id = t.route_id
JOIN   Transit_Operator o ON o.operator_id = r.operator_id
GROUP  BY r.route_id, r.route_number,
          r.route_name, o.operator_name
ORDER  BY route_revenue_inr DESC;

-- Q49. Pass revenue by type and operator.
--      Used by: Pass scheme performance, pricing policy
SELECT o.operator_name, ps.pass_type,
       COUNT(ps.pass_id)   AS passes_sold,
       SUM(ps.amount_paid) AS total_revenue_inr
FROM   Pass ps
JOIN   Transit_Operator o ON o.operator_id = ps.operator_id
GROUP  BY o.operator_id, o.operator_name, ps.pass_type
ORDER  BY o.operator_name, total_revenue_inr DESC;

-- Q50. Passes sold in January 2024 with passenger details.
--      Used by: Monthly pass audit, validity verification
SELECT ps.pass_id,
       p.first_name || ' ' || p.last_name AS passenger,
       o.operator_name, ps.pass_type,
       ps.amount_paid, ps.valid_from, ps.valid_to
FROM   Pass ps
JOIN   Passenger p ON p.passenger_id = ps.passenger_id
JOIN   Transit_Operator o ON o.operator_id = ps.operator_id
WHERE  ps.valid_from BETWEEN '2024-01-01' AND '2024-01-31'
ORDER  BY ps.valid_from;

-- Q51. Revenue per vehicle (highest earning vehicles).
--      Used by: Vehicle ROI analysis, fleet review
SELECT v.registration_no, o.operator_name,
       COUNT(tt.txn_id) AS transactions,
       SUM(tt.amount)   AS vehicle_revenue_inr
FROM   Ticket_Transaction tt
JOIN   Trip t ON t.trip_id = tt.trip_id
JOIN   Vehicle v ON v.vehicle_id = t.vehicle_id
JOIN   Transit_Operator o ON o.operator_id = v.operator_id
GROUP  BY v.vehicle_id, v.registration_no, o.operator_name
ORDER  BY vehicle_revenue_inr DESC;

-- Q52. Each operator's percentage share of total revenue.
--      Used by: Finance — revenue attribution, cost sharing
SELECT o.operator_name,
       SUM(tt.amount) AS operator_revenue,
       ROUND(100.0 * SUM(tt.amount)
             / (SELECT SUM(amount) FROM Ticket_Transaction),
             2) AS revenue_share_pct
FROM   Ticket_Transaction tt
JOIN   Trip t ON t.trip_id = tt.trip_id
JOIN   Route r ON r.route_id = t.route_id
JOIN   Transit_Operator o ON o.operator_id = r.operator_id
GROUP  BY o.operator_id, o.operator_name
ORDER  BY operator_revenue DESC;

-- Q53. Smart card transactions with balance before deduction.
--      Used by: Smart card audit, balance dispute resolution
SELECT tt.txn_id,
       p.first_name || ' ' || p.last_name AS passenger,
       sc.card_id,
       tt.amount                     AS deducted_inr,
       sc.balance                    AS current_balance,
       sc.balance + tt.amount        AS balance_before_txn
FROM   Ticket_Transaction tt
JOIN   Smart_Card sc ON sc.card_id     = tt.card_id
JOIN   Passenger  p  ON p.passenger_id = tt.passenger_id
WHERE  tt.card_id IS NOT NULL
ORDER  BY tt.txn_datetime;


-- =============================================================
-- SCENARIO E: FLEET & MAINTENANCE
-- Real-world use: Depot manager system, maintenance scheduler,
-- vehicle health monitoring dashboard
-- =============================================================

-- Q54. Full maintenance history per vehicle with duration.
--      Used by: Maintenance log, service history
SELECT v.registration_no, o.operator_name, d.depot_name,
       m.maintenance_type, m.description,
       m.start_date, m.end_date,
       (m.end_date - m.start_date + 1) AS duration_days
FROM   Maintenance m
JOIN   Vehicle v ON v.vehicle_id  = m.vehicle_id
JOIN   Transit_Operator o ON o.operator_id = v.operator_id
JOIN   Depot d ON d.depot_id = v.depot_id
ORDER  BY m.start_date DESC;

-- Q55. Fleet breakdown: trains vs buses per operator.
--      Used by: Fleet overview dashboard
SELECT o.operator_name,
       CASE WHEN mt.vehicle_id IS NOT NULL
            THEN 'Metro Train' ELSE 'Bus'
       END AS vehicle_type,
       COUNT(v.vehicle_id)      AS fleet_count,
       SUM(v.capacity)          AS total_capacity,
       ROUND(AVG(v.capacity),0) AS avg_capacity
FROM   Vehicle v
JOIN   Transit_Operator o ON o.operator_id = v.operator_id
LEFT JOIN Metro_Train mt ON mt.vehicle_id = v.vehicle_id
LEFT JOIN Bus         b  ON b.vehicle_id  = v.vehicle_id
GROUP  BY o.operator_id, o.operator_name, vehicle_type
ORDER  BY o.operator_name, vehicle_type;

-- Q56. Vehicles with more than one maintenance event.
--      Used by: High-maintenance vehicle tracking
SELECT v.registration_no, o.operator_name,
       COUNT(m.maintenance_id) AS maintenance_count,
       SUM(m.end_date - m.start_date + 1) AS total_downtime_days
FROM   Maintenance m
JOIN   Vehicle v ON v.vehicle_id = m.vehicle_id
JOIN   Transit_Operator o ON o.operator_id = v.operator_id
GROUP  BY v.vehicle_id, v.registration_no, o.operator_name
HAVING COUNT(m.maintenance_id) > 1
ORDER  BY maintenance_count DESC;

-- Q57. Vehicles currently under maintenance.
--      Used by: Real-time fleet availability screen
SELECT v.vehicle_id, v.registration_no, v.status,
       o.operator_name, d.depot_name,
       v.manufacturer_name, v.manufacture_year
FROM   Vehicle v
JOIN   Transit_Operator o ON o.operator_id = v.operator_id
JOIN   Depot d            ON d.depot_id    = v.depot_id
WHERE  v.status = 'Under Maintenance'
ORDER  BY o.operator_name;

-- Q58. Fuel type distribution of the bus fleet.
--      Used by: Environmental compliance, fuel cost planning
SELECT b.fuel_type,
       COUNT(b.vehicle_id) AS count,
       ROUND(100.0 * COUNT(b.vehicle_id)
             / (SELECT COUNT(*) FROM Bus), 1) AS pct
FROM   Bus b
GROUP  BY b.fuel_type
ORDER  BY count DESC;

-- Q59. AC vs Non-AC bus breakdown per operator.
--      Used by: Comfort level reporting, fleet upgrade planning
SELECT o.operator_name,
       CASE WHEN b.bus_type LIKE '%AC%'
                 AND b.bus_type NOT LIKE 'Non-AC%'
            THEN 'AC' ELSE 'Non-AC'
       END AS ac_type,
       COUNT(b.vehicle_id) AS count
FROM   Bus b
JOIN   Vehicle v ON v.vehicle_id = b.vehicle_id
JOIN   Transit_Operator o ON o.operator_id = v.operator_id
GROUP  BY o.operator_id, o.operator_name, ac_type
ORDER  BY o.operator_name;

-- Q60. Vehicles with most trips (busiest vehicles).
--      Used by: Vehicle workload balancing, priority servicing
SELECT v.registration_no, o.operator_name,
       COUNT(t.trip_id) AS trips_assigned
FROM   Vehicle v
JOIN   Transit_Operator o ON o.operator_id = v.operator_id
LEFT JOIN Trip t ON t.vehicle_id = v.vehicle_id
GROUP  BY v.vehicle_id, v.registration_no, o.operator_name
ORDER  BY trips_assigned DESC;

-- Q61. Vehicles not used in any trip for 60+ days (idle risk).
--      Used by: Idle asset detection, depot cost review
SELECT v.registration_no, o.operator_name,
       d.depot_name, v.status, v.manufacture_year,
       MAX(t.trip_date) AS last_trip_date,
       (CURRENT_DATE - MAX(t.trip_date)) AS days_idle
FROM   Vehicle v
JOIN   Transit_Operator o ON o.operator_id = v.operator_id
JOIN   Depot d            ON d.depot_id    = v.depot_id
LEFT JOIN Trip t          ON t.vehicle_id  = v.vehicle_id
GROUP  BY v.vehicle_id, v.registration_no,
          o.operator_name, d.depot_name,
          v.status, v.manufacture_year
HAVING MAX(t.trip_date) IS NULL
    OR (CURRENT_DATE - MAX(t.trip_date)) >= 60
ORDER  BY days_idle DESC NULLS FIRST;

-- Q62. Metro trains per line with rake and coach details.
--      Used by: Metro fleet assignment, rake management
SELECT ml.line_name, mt.rake_number, mt.num_coaches,
       v.registration_no, v.manufacture_year,
       v.manufacturer_name, d.depot_name
FROM   Metro_Train mt
JOIN   Vehicle    v  ON v.vehicle_id = mt.vehicle_id
JOIN   Depot      d  ON d.depot_id   = v.depot_id
JOIN   Route      r  ON r.operator_id = v.operator_id
                    AND r.line_id IS NOT NULL
JOIN   Metro_Line ml ON ml.line_id = r.line_id
GROUP  BY ml.line_name, mt.vehicle_id, mt.rake_number,
          mt.num_coaches, v.registration_no,
          v.manufacture_year, v.manufacturer_name, d.depot_name
ORDER  BY ml.line_name, mt.rake_number;


-- Q63. Average vehicle age per operator.
--      Used by: Fleet renewal planning, age-based policy
SELECT o.operator_name,
       ROUND(AVG(EXTRACT(YEAR FROM CURRENT_DATE)
             - v.manufacture_year), 1) AS avg_age_years,
       MIN(v.manufacture_year) AS oldest_year,
       MAX(v.manufacture_year) AS newest_year
FROM   Vehicle v
JOIN   Transit_Operator o ON o.operator_id = v.operator_id
GROUP  BY o.operator_id, o.operator_name
ORDER  BY avg_age_years DESC;

-- Q64. Most common maintenance types and average duration.
--      Used by: Maintenance scheduling, spare parts planning
SELECT m.maintenance_type,
       COUNT(m.maintenance_id) AS frequency,
       ROUND(AVG(m.end_date - m.start_date + 1), 1)
           AS avg_duration_days
FROM   Maintenance m
GROUP  BY m.maintenance_type
ORDER  BY frequency DESC;

-- Q65. All GSRTC vehicles with bus type, depot, and status.
--      Used by: Operator-specific fleet list
SELECT v.registration_no, b.fuel_type, b.bus_type,
       d.depot_name, v.manufacture_year,
       v.capacity, v.status
FROM   Vehicle v
JOIN   Bus   b ON b.vehicle_id = v.vehicle_id
JOIN   Depot d ON d.depot_id   = v.depot_id
JOIN   Transit_Operator o ON o.operator_id = v.operator_id
WHERE  o.operator_name = 'GSRTC'
ORDER  BY v.manufacture_year;

-- Q66. Month-by-month maintenance event summary.
--      Used by: Annual maintenance calendar, budgeting
SELECT TO_CHAR(m.start_date, 'YYYY-MM')  AS month,
       COUNT(m.maintenance_id)             AS events,
       COUNT(DISTINCT m.vehicle_id)        AS vehicles_maintained
FROM   Maintenance m
GROUP  BY TO_CHAR(m.start_date, 'YYYY-MM')
ORDER  BY month;

-- Q67. Maintenance frequency by vehicle manufacturer.
--      Used by: Procurement evaluation, warranty tracking
SELECT v.manufacturer_name,
       COUNT(DISTINCT v.vehicle_id) AS vehicles,
       COUNT(m.maintenance_id)       AS total_events,
       ROUND(1.0 * COUNT(m.maintenance_id)
             / COUNT(DISTINCT v.vehicle_id), 1)
           AS avg_events_per_vehicle
FROM   Vehicle v
LEFT JOIN Maintenance m ON m.vehicle_id = v.vehicle_id
GROUP  BY v.manufacturer_name
ORDER  BY total_events DESC;

-- Q68. Vehicle age vs trip count (fleet health indicator).
--      Used by: Fleet performance vs age analysis
SELECT v.registration_no, o.operator_name,
       v.manufacture_year,
       (EXTRACT(YEAR FROM CURRENT_DATE)
        - v.manufacture_year) AS age_years,
       COUNT(t.trip_id) AS total_trips,
       v.status
FROM   Vehicle v
JOIN   Transit_Operator o ON o.operator_id = v.operator_id
LEFT JOIN Trip t ON t.vehicle_id = v.vehicle_id
GROUP  BY v.vehicle_id, v.registration_no, o.operator_name,
          v.manufacture_year, v.status
ORDER  BY age_years DESC, total_trips DESC;

-- Q69. Total capacity: Metro trains vs Buses.
--      Used by: Network-level capacity planning
SELECT
    SUM(CASE WHEN mt.vehicle_id IS NOT NULL
             THEN v.capacity ELSE 0 END) AS metro_total_capacity,
    SUM(CASE WHEN b.vehicle_id IS NOT NULL
             THEN v.capacity ELSE 0 END) AS bus_total_capacity,
    COUNT(CASE WHEN mt.vehicle_id IS NOT NULL
               THEN 1 END) AS metro_count,
    COUNT(CASE WHEN b.vehicle_id IS NOT NULL
               THEN 1 END) AS bus_count
FROM   Vehicle v
LEFT JOIN Metro_Train mt ON mt.vehicle_id = v.vehicle_id
LEFT JOIN Bus         b  ON b.vehicle_id  = v.vehicle_id;


-- =============================================================
-- SCENARIO F: STAFF & OPERATIONS
-- Real-world use: HR system, depot manager portal,
-- driver/conductor duty management
-- =============================================================

-- Q70. Full staff listing with role, operator, and depot.
--      Used by: HR directory, staff management system
SELECT st.staff_id,
       st.first_name || ' ' ||
       COALESCE(st.middle_name || ' ', '') ||
       st.last_name     AS full_name,
       st.role, o.operator_name,
       d.depot_name, st.date_of_joining, st.contact
FROM   Staff st
JOIN   Transit_Operator o ON o.operator_id = st.operator_id
JOIN   Depot            d ON d.depot_id    = st.depot_id
ORDER  BY o.operator_name, st.role, st.first_name;

-- Q71. All trips per staff member in Jan-Mar 2024.
--      Used by: Duty log, payroll attendance
SELECT st.staff_id,
       st.first_name || ' ' || st.last_name AS staff_name,
       st.role, o.operator_name,
       t.trip_id, t.trip_date,
       r.route_name, t.trip_status
FROM   Staff st
JOIN   Transit_Operator o ON o.operator_id = st.operator_id
JOIN   Trip t ON t.staff_id  = st.staff_id
JOIN   Route r ON r.route_id = t.route_id
WHERE  t.trip_date BETWEEN '2024-01-01' AND '2024-03-31'
ORDER  BY st.first_name, t.trip_date;

-- Q72. Trip count and OTP percentage per staff member.
--      Used by: Performance appraisal, KPI tracking
SELECT st.first_name || ' ' || st.last_name AS staff_name,
       st.role, o.operator_name,
       COUNT(t.trip_id) AS total_trips,
       SUM(CASE WHEN t.trip_status='Completed'
                THEN 1 ELSE 0 END) AS on_time,
       ROUND(100.0 *
           SUM(CASE WHEN t.trip_status='Completed'
                    THEN 1 ELSE 0 END)
           / COUNT(t.trip_id), 1) AS otp_pct
FROM   Staff st
JOIN   Transit_Operator o ON o.operator_id = st.operator_id
JOIN   Trip t ON t.staff_id = st.staff_id
GROUP  BY st.staff_id, st.first_name, st.last_name,
          st.role, o.operator_name
ORDER  BY otp_pct ASC, total_trips DESC;

-- Q73. Motormen with metro license and trip count.
--      Used by: Motorman duty allocation, license verification
SELECT st.first_name || ' ' || st.last_name AS motorman_name,
       mm.metro_license_no,
       o.operator_name,
       COUNT(t.trip_id) AS trips_operated
FROM   Staff   st
JOIN   Motorman mm ON mm.staff_id = st.staff_id
JOIN   Transit_Operator o ON o.operator_id = st.operator_id
LEFT JOIN Trip t ON t.staff_id = st.staff_id
GROUP  BY st.staff_id, st.first_name, st.last_name,
          mm.metro_license_no, o.operator_name
ORDER  BY trips_operated DESC;

-- Q74. All conductors with badge number and operator.
--      Used by: Conductor roster, badge verification
SELECT st.first_name || ' ' || st.last_name AS conductor_name,
       c.badge_no, o.operator_name,
       d.depot_name, st.date_of_joining, st.contact
FROM   Staff     st
JOIN   Conductor  c ON c.staff_id  = st.staff_id
JOIN   Transit_Operator o ON o.operator_id = st.operator_id
JOIN   Depot      d ON d.depot_id  = st.depot_id
ORDER  BY o.operator_name, st.first_name;

-- Q75. Staff who handled delayed or cancelled trips.
--      Used by: Incident investigation, training targeting
SELECT st.first_name || ' ' || st.last_name AS staff_name,
       st.role, o.operator_name,
       COUNT(t.trip_id) AS problem_trips
FROM   Staff st
JOIN   Trip t ON t.staff_id = st.staff_id
JOIN   Transit_Operator o ON o.operator_id = st.operator_id
WHERE  t.trip_status IN ('Delayed','Cancelled')
GROUP  BY st.staff_id, st.first_name, st.last_name,
          st.role, o.operator_name
ORDER  BY problem_trips DESC;

-- Q76. Drivers with license number and depot.
--      Used by: License verification, driving roster
SELECT st.first_name || ' ' || st.last_name AS driver_name,
       dr.license_no, o.operator_name,
       d.depot_name, st.date_of_joining
FROM   Staff  st
JOIN   Driver  dr ON dr.staff_id  = st.staff_id
JOIN   Transit_Operator o ON o.operator_id = st.operator_id
JOIN   Depot   d ON d.depot_id    = st.depot_id
ORDER  BY o.operator_name, st.first_name;

-- Q77. Years of experience per staff member.
--      Used by: HR — seniority tracking, promotion eligibility
SELECT st.first_name || ' ' || st.last_name AS staff_name,
       st.role, o.operator_name,
       st.date_of_joining,
       EXTRACT(YEAR FROM AGE(CURRENT_DATE,
           st.date_of_joining)) AS years_experience
FROM   Staff st
JOIN   Transit_Operator o ON o.operator_id = st.operator_id
ORDER  BY years_experience DESC;

-- Q78. Staff with no trips assigned.
--      Used by: Underutilised staff detection, scheduling
SELECT st.staff_id,
       st.first_name || ' ' || st.last_name AS staff_name,
       st.role, o.operator_name, d.depot_name
FROM   Staff st
JOIN   Transit_Operator o ON o.operator_id = st.operator_id
JOIN   Depot            d ON d.depot_id    = st.depot_id
WHERE  st.staff_id NOT IN (
    SELECT DISTINCT staff_id FROM Trip
)
ORDER  BY o.operator_name;

-- Q79. Staff count per operator and role.
--      Used by: Staffing summary, workforce planning
SELECT o.operator_name, st.role,
       COUNT(st.staff_id) AS count
FROM   Staff st
JOIN   Transit_Operator o ON o.operator_id = st.operator_id
GROUP  BY o.operator_id, o.operator_name, st.role
ORDER  BY o.operator_name, st.role;


-- Q80. Depot with most staff, broken down by role.
--      Used by: Depot capacity planning, HR allocation
SELECT d.depot_name, o.operator_name,
       COUNT(st.staff_id) AS total_staff,
       SUM(CASE WHEN st.role='Driver'
                THEN 1 ELSE 0 END) AS drivers,
       SUM(CASE WHEN st.role='Conductor'
                THEN 1 ELSE 0 END) AS conductors,
       SUM(CASE WHEN st.role='Motorman'
                THEN 1 ELSE 0 END) AS motormen
FROM   Depot d
JOIN   Transit_Operator o ON o.operator_id = d.operator_id
LEFT JOIN Staff st ON st.depot_id = d.depot_id
GROUP  BY d.depot_id, d.depot_name,
          o.operator_id, o.operator_name
ORDER  BY total_staff DESC;

-- Q81. Complaints linked to each staff member's trips.
--      Used by: Accountability tracking, passenger feedback
SELECT st.first_name || ' ' || st.last_name AS staff_name,
       st.role, o.operator_name,
       COUNT(c.complaint_id) AS complaints_on_trips,
       SUM(CASE WHEN c.status='Open'
                THEN 1 ELSE 0 END) AS open_complaints
FROM   Staff st
JOIN   Trip t ON t.staff_id = st.staff_id
JOIN   Complaint c ON c.trip_id = t.trip_id
JOIN   Transit_Operator o ON o.operator_id = st.operator_id
GROUP  BY st.staff_id, st.first_name, st.last_name,
          st.role, o.operator_name
ORDER  BY complaints_on_trips DESC;

-- Q82. All complaints with status, route, and action flag.
--      Used by: Admin complaint dashboard (like GMRC portal)
SELECT c.complaint_id,
       p.first_name || ' ' || p.last_name AS passenger,
       c.category, c.description, c.status,
       c.filed_date, c.resolved_date,
       r.route_name, o.operator_name,
       CASE WHEN c.status='Open'
                 THEN 'Action Needed'
            WHEN c.status='In Progress'
                 THEN 'Being Handled'
            ELSE 'Closed'
       END AS action_flag
FROM   Complaint c
JOIN   Passenger p ON p.passenger_id = c.passenger_id
JOIN   Trip t      ON t.trip_id      = c.trip_id
JOIN   Route r     ON r.route_id     = t.route_id
JOIN   Transit_Operator o ON o.operator_id = r.operator_id
ORDER  BY
    CASE c.status
        WHEN 'Open'        THEN 1
        WHEN 'In Progress' THEN 2
        ELSE 3
    END,
    c.filed_date;


-- Q83. Staff certifications expiring within 180 days.
--       Used by: Compliance alert, renewal scheduling
SELECT st.first_name || ' ' || st.last_name AS staff_name,
       st.role, o.operator_name,
       sc.certification,
       sc.issued_date, sc.expiry_date,
       (sc.expiry_date - CURRENT_DATE) AS days_to_expiry
FROM   Staff st
JOIN   Staff_Certification sc ON sc.staff_id   = st.staff_id
JOIN   Transit_Operator    o  ON o.operator_id = st.operator_id
WHERE  sc.expiry_date BETWEEN CURRENT_DATE
                          AND CURRENT_DATE + INTERVAL '180 days'
ORDER  BY days_to_expiry;

-- Q84. Annual staff hiring trend per operator.
--       Used by: HR workforce growth report, annual review
SELECT EXTRACT(YEAR FROM st.date_of_joining) AS year_joined,
       o.operator_name,
       COUNT(st.staff_id) AS new_hires
FROM   Staff st
JOIN   Transit_Operator o ON o.operator_id = st.operator_id
GROUP  BY EXTRACT(YEAR FROM st.date_of_joining),
          o.operator_id, o.operator_name
ORDER  BY year_joined, o.operator_name;

