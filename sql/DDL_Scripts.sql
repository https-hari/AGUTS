-- ============================================================
--  AGUTS — Ahmedabad Gandhinagar Unified Transit System
--  Milestone 3  |  File 3 of 3  |  DDL Scripts (Corrected v2)
--  IT-214 DBMS  |  Winter 2025-26  |  DAU  |  Lab Group 5
-- ============================================================
--  27 relations in FK-dependency order.
--  Changes from v1:
--    + DEPOT gets city_id FK (HOUSES relationship)
--    + FARE_ZONE gets operator_id FK (DEFINES relationship)
--    + ROUTE gets operator_id FK (SERVES) and line_id FK (CONTAINS)
--    + STOP loses zone_id (moved to ROUTE_STOP)
--    + ROUTE_STOP PK extended to (route_id, stop_id, sequence_no);
--      zone_id FK added
--    + INTERCHANGE: stop_id FK UNIQUE (1:1, not junction table)
--    + METRO_TRAIN: train_number renamed to rake_number
--    + MAINTENANCE: maintenance_type column added
--    + STAFF: name split into first/middle/last; certificate removed
--    + STAFF_CERTIFICATION added (multi-valued attribute)
--    + TRIP: etd, eta, delay_minutes removed (derived attributes)
--    + TRIP_STOP: stop_order renamed to sequence_no
--    + PASSENGER: name split; phone removed
--    + PASSENGER_PHONE added (multi-valued attribute)
--    + PASS: fare_id replaced by operator_id FK; amount_paid added
--    + FARE: operator_id FK added; amount renamed to fare_amount
-- ============================================================

-- ============================================================
--  1. CITY
-- ============================================================
CREATE TABLE City (
    city_id     INT          NOT NULL,
    city_name   VARCHAR(100) NOT NULL,
    city_state  VARCHAR(100) NOT NULL DEFAULT 'Gujarat',
    CONSTRAINT pk_city PRIMARY KEY (city_id)
);

-- ============================================================
--  2. TRANSIT_OPERATOR
-- ============================================================
CREATE TABLE Transit_Operator (
    operator_id     INT          NOT NULL,
    operator_name   VARCHAR(150) NOT NULL,
    service_type    VARCHAR(50)  NOT NULL,
    city_id         INT          NOT NULL,
    CONSTRAINT pk_transit_operator PRIMARY KEY (operator_id),
    CONSTRAINT fk_to_city
        FOREIGN KEY (city_id) REFERENCES City(city_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
--  3. METRO_LINE
-- ============================================================
CREATE TABLE Metro_Line (
    line_id     INT          NOT NULL,
    line_name   VARCHAR(100) NOT NULL,
    line_code   VARCHAR(10)  NOT NULL,
    operator_id INT          NOT NULL,
    CONSTRAINT pk_metro_line PRIMARY KEY (line_id),
    CONSTRAINT fk_ml_operator
        FOREIGN KEY (operator_id) REFERENCES Transit_Operator(operator_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
--  4. FARE_ZONE  — operator_id FK added (DEFINES 1:N)
-- ============================================================
CREATE TABLE Fare_Zone (
    zone_id     INT         NOT NULL,
    zone_name   VARCHAR(50) NOT NULL,
    operator_id INT         NOT NULL,
    CONSTRAINT pk_fare_zone PRIMARY KEY (zone_id),
    CONSTRAINT fk_fz_operator
        FOREIGN KEY (operator_id) REFERENCES Transit_Operator(operator_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
--  5. DEPOT  — city_id FK added (HOUSES 1:N)
-- ============================================================
CREATE TABLE Depot (
    depot_id    INT          NOT NULL,
    depot_name  VARCHAR(150) NOT NULL,
    address     VARCHAR(300),
    operator_id INT          NOT NULL,
    city_id     INT          NOT NULL,
    CONSTRAINT pk_depot PRIMARY KEY (depot_id),
    CONSTRAINT fk_depot_operator
        FOREIGN KEY (operator_id) REFERENCES Transit_Operator(operator_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_depot_city
        FOREIGN KEY (city_id) REFERENCES City(city_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
--  6. VEHICLE
-- ============================================================
CREATE TABLE Vehicle (
    vehicle_id          INT         NOT NULL,
    registration_no     VARCHAR(20) NOT NULL,
    capacity            INT         NOT NULL,
    manufacture_year    INT,
    manufacturer_name   VARCHAR(100),
    manufacturer_info   VARCHAR(255),
    status              VARCHAR(20) NOT NULL DEFAULT 'Active',
    operator_id         INT         NOT NULL,
    depot_id            INT         NOT NULL,
    CONSTRAINT pk_vehicle     PRIMARY KEY (vehicle_id),
    CONSTRAINT uq_vehicle_reg UNIQUE (registration_no),
    CONSTRAINT fk_veh_operator
        FOREIGN KEY (operator_id) REFERENCES Transit_Operator(operator_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_veh_depot
        FOREIGN KEY (depot_id) REFERENCES Depot(depot_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
--  7. BUS  (ISA subtype of VEHICLE)
-- ============================================================
CREATE TABLE Bus (
    vehicle_id  INT         NOT NULL,
    fuel_type   VARCHAR(20) NOT NULL,
    bus_type    VARCHAR(50) NOT NULL,
    CONSTRAINT pk_bus PRIMARY KEY (vehicle_id),
    CONSTRAINT fk_bus_vehicle
        FOREIGN KEY (vehicle_id) REFERENCES Vehicle(vehicle_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
--  8. METRO_TRAIN  (ISA subtype of VEHICLE)
--     train_number renamed to rake_number
-- ============================================================
CREATE TABLE Metro_Train (
    vehicle_id   INT         NOT NULL,
    rake_number  VARCHAR(20) NOT NULL,
    num_coaches  INT         NOT NULL,
    CONSTRAINT pk_metro_train PRIMARY KEY (vehicle_id),
    CONSTRAINT fk_mt_vehicle
        FOREIGN KEY (vehicle_id) REFERENCES Vehicle(vehicle_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
--  9. MAINTENANCE  — maintenance_type column added
-- ============================================================
CREATE TABLE Maintenance (
    maintenance_id   INT          NOT NULL,
    vehicle_id       INT          NOT NULL,
    start_date       DATE         NOT NULL,
    end_date         DATE,
    maintenance_type VARCHAR(50)  NOT NULL DEFAULT 'Scheduled',
    description      VARCHAR(500),
    CONSTRAINT pk_maintenance PRIMARY KEY (maintenance_id),
    CONSTRAINT fk_maint_vehicle
        FOREIGN KEY (vehicle_id) REFERENCES Vehicle(vehicle_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
--  10. STOP  — zone_id removed (now lives in ROUTE_STOP)
-- ============================================================
CREATE TABLE Stop (
    stop_id     INT           NOT NULL,
    stop_name   VARCHAR(200)  NOT NULL,
    stop_type   VARCHAR(50)   NOT NULL,
    latitude    DECIMAL(9,6),
    longitude   DECIMAL(9,6),
    city_id     INT           NOT NULL,
    CONSTRAINT pk_stop PRIMARY KEY (stop_id),
    CONSTRAINT fk_stop_city
        FOREIGN KEY (city_id) REFERENCES City(city_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
--  11. INTERCHANGE  — stop_id FK UNIQUE (1:1 with STOP)
--      Replaces the previous INTERCHANGE_STOP junction table.
-- ============================================================
CREATE TABLE Interchange (
    interchange_id   INT          NOT NULL,
    stop_id          INT          NOT NULL,
    interchange_type VARCHAR(100) NOT NULL,
    description      VARCHAR(300),
    CONSTRAINT pk_interchange    PRIMARY KEY (interchange_id),
    CONSTRAINT uq_ic_stop        UNIQUE (stop_id),
    CONSTRAINT fk_ic_stop
        FOREIGN KEY (stop_id) REFERENCES Stop(stop_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
--  12. ROUTE  — operator_id + line_id FKs added
-- ============================================================
CREATE TABLE Route (
    route_id     INT           NOT NULL,
    route_number VARCHAR(20)   NOT NULL,
    route_name   VARCHAR(200)  NOT NULL,
    distance_km  DECIMAL(6,2),
    operator_id  INT           NOT NULL,
    line_id      INT,
    CONSTRAINT pk_route PRIMARY KEY (route_id),
    CONSTRAINT fk_route_operator
        FOREIGN KEY (operator_id) REFERENCES Transit_Operator(operator_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_route_line
        FOREIGN KEY (line_id) REFERENCES Metro_Line(line_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- ============================================================
--  13. ROUTE_STOP  (weak entity)
--      PK extended to (route_id, stop_id, sequence_no).
--      zone_id FK added.
-- ============================================================
CREATE TABLE Route_Stop (
    route_id    INT NOT NULL,
    stop_id     INT NOT NULL,
    sequence_no INT NOT NULL,
    zone_id     INT,
    CONSTRAINT pk_route_stop PRIMARY KEY (route_id, stop_id, sequence_no),
    CONSTRAINT fk_rs_route
        FOREIGN KEY (route_id) REFERENCES Route(route_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_rs_stop
        FOREIGN KEY (stop_id) REFERENCES Stop(stop_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_rs_zone
        FOREIGN KEY (zone_id) REFERENCES Fare_Zone(zone_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- ============================================================
--  14. STAFF  — name split; certificate column removed
-- ============================================================
CREATE TABLE Staff (
    staff_id        INT          NOT NULL,
    first_name      VARCHAR(100) NOT NULL,
    middle_name     VARCHAR(100),
    last_name       VARCHAR(100) NOT NULL,
    role            VARCHAR(30)  NOT NULL,
    contact         VARCHAR(20),
    date_of_joining DATE         NOT NULL,
    operator_id     INT          NOT NULL,
    depot_id        INT          NOT NULL,
    CONSTRAINT pk_staff PRIMARY KEY (staff_id),
    CONSTRAINT fk_staff_operator
        FOREIGN KEY (operator_id) REFERENCES Transit_Operator(operator_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_staff_depot
        FOREIGN KEY (depot_id) REFERENCES Depot(depot_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
--  15. STAFF_CERTIFICATION  (multi-valued attribute of STAFF)
-- ============================================================
CREATE TABLE Staff_Certification (
    staff_id      INT          NOT NULL,
    certification VARCHAR(200) NOT NULL,
    issued_date   DATE,
    expiry_date   DATE,
    CONSTRAINT pk_staff_cert PRIMARY KEY (staff_id, certification),
    CONSTRAINT fk_sc_staff
        FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
--  16. DRIVER  (ISA subtype of STAFF)
-- ============================================================
CREATE TABLE Driver (
    staff_id   INT         NOT NULL,
    license_no VARCHAR(50) NOT NULL,
    CONSTRAINT pk_driver  PRIMARY KEY (staff_id),
    CONSTRAINT uq_drv_lic UNIQUE (license_no),
    CONSTRAINT fk_driver_staff
        FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
--  17. CONDUCTOR  (ISA subtype of STAFF)
-- ============================================================
CREATE TABLE Conductor (
    staff_id INT         NOT NULL,
    badge_no VARCHAR(50) NOT NULL,
    CONSTRAINT pk_conductor  PRIMARY KEY (staff_id),
    CONSTRAINT uq_cond_badge UNIQUE (badge_no),
    CONSTRAINT fk_conductor_staff
        FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
--  18. MOTORMAN  (ISA subtype of STAFF)
-- ============================================================
CREATE TABLE Motorman (
    staff_id         INT         NOT NULL,
    metro_license_no VARCHAR(50) NOT NULL,
    CONSTRAINT pk_motorman PRIMARY KEY (staff_id),
    CONSTRAINT uq_mm_lic   UNIQUE (metro_license_no),
    CONSTRAINT fk_motorman_staff
        FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
--  19. PASSENGER  — name split; phone removed (see PASSENGER_PHONE)
-- ============================================================
CREATE TABLE Passenger (
    passenger_id    INT          NOT NULL,
    first_name      VARCHAR(100) NOT NULL,
    middle_name     VARCHAR(100),
    last_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(200),
    date_of_birth   DATE,
    concession_type VARCHAR(30)  NOT NULL DEFAULT 'General',
    city_id         INT          NOT NULL,
    CONSTRAINT pk_passenger       PRIMARY KEY (passenger_id),
    CONSTRAINT uq_passenger_email UNIQUE (email),
    CONSTRAINT fk_pax_city
        FOREIGN KEY (city_id) REFERENCES City(city_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
--  20. PASSENGER_PHONE  (multi-valued attribute of PASSENGER)
-- ============================================================
CREATE TABLE Passenger_Phone (
    passenger_id INT         NOT NULL,
    phone        VARCHAR(20) NOT NULL,
    phone_type   VARCHAR(20),
    CONSTRAINT pk_pax_phone PRIMARY KEY (passenger_id, phone),
    CONSTRAINT fk_pp_passenger
        FOREIGN KEY (passenger_id) REFERENCES Passenger(passenger_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
--  21. SMART_CARD  — 1:1 with PASSENGER
-- ============================================================
CREATE TABLE Smart_Card (
    card_id      INT           NOT NULL,
    passenger_id INT           NOT NULL,
    balance      DECIMAL(8,2)  NOT NULL DEFAULT 0.00,
    issue_date   DATE          NOT NULL,
    expiry_date  DATE,
    card_status  VARCHAR(20)   NOT NULL DEFAULT 'Active',
    CONSTRAINT pk_smart_card   PRIMARY KEY (card_id),
    CONSTRAINT uq_sc_passenger UNIQUE (passenger_id),
    CONSTRAINT fk_sc_passenger
        FOREIGN KEY (passenger_id) REFERENCES Passenger(passenger_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
--  22. TRIP  — etd, eta, delay_minutes removed (derived attrs)
-- ============================================================
CREATE TABLE Trip (
    trip_id      INT         NOT NULL,
    trip_date    DATE        NOT NULL,
    trip_status  VARCHAR(30) NOT NULL DEFAULT 'Scheduled',
    route_id     INT         NOT NULL,
    vehicle_id   INT         NOT NULL,
    staff_id     INT         NOT NULL,
    CONSTRAINT pk_trip PRIMARY KEY (trip_id),
    CONSTRAINT fk_trip_route
        FOREIGN KEY (route_id) REFERENCES Route(route_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_trip_vehicle
        FOREIGN KEY (vehicle_id) REFERENCES Vehicle(vehicle_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_trip_staff
        FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
--  23. TRIP_STOP  (weak entity)
--      stop_order renamed to sequence_no; sched_arrival kept
-- ============================================================
CREATE TABLE Trip_Stop (
    trip_id        INT  NOT NULL,
    sequence_no    INT  NOT NULL,
    stop_id        INT  NOT NULL,
    sched_arrival  TIME,
    actual_arrival TIME,
    CONSTRAINT pk_trip_stop PRIMARY KEY (trip_id, sequence_no),
    CONSTRAINT fk_ts_trip
        FOREIGN KEY (trip_id) REFERENCES Trip(trip_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ts_stop
        FOREIGN KEY (stop_id) REFERENCES Stop(stop_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
--  24. FARE  — operator_id FK added; amount renamed fare_amount
-- ============================================================
CREATE TABLE Fare (
    fare_id         INT          NOT NULL,
    fare_amount     DECIMAL(6,2) NOT NULL,
    concession_type VARCHAR(30)  NOT NULL DEFAULT 'General',
    operator_id     INT          NOT NULL,
    from_zone_id    INT          NOT NULL,
    to_zone_id      INT          NOT NULL,
    CONSTRAINT pk_fare PRIMARY KEY (fare_id),
    CONSTRAINT fk_fare_operator
        FOREIGN KEY (operator_id) REFERENCES Transit_Operator(operator_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_fare_from_zone
        FOREIGN KEY (from_zone_id) REFERENCES Fare_Zone(zone_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_fare_to_zone
        FOREIGN KEY (to_zone_id) REFERENCES Fare_Zone(zone_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
--  25. PASS  — fare_id replaced by operator_id FK; amount_paid added
-- ============================================================
CREATE TABLE Pass (
    pass_id      INT           NOT NULL,
    pass_type    VARCHAR(30)   NOT NULL,
    valid_from   DATE          NOT NULL,
    valid_to     DATE          NOT NULL,
    amount_paid  DECIMAL(8,2)  NOT NULL,
    passenger_id INT           NOT NULL,
    operator_id  INT           NOT NULL,
    CONSTRAINT pk_pass PRIMARY KEY (pass_id),
    CONSTRAINT fk_pass_passenger
        FOREIGN KEY (passenger_id) REFERENCES Passenger(passenger_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pass_operator
        FOREIGN KEY (operator_id) REFERENCES Transit_Operator(operator_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
--  26. TICKET_TRANSACTION
-- ============================================================
CREATE TABLE Ticket_Transaction (
    txn_id       INT           NOT NULL,
    ticket_type  VARCHAR(30)   NOT NULL,
    amount       DECIMAL(8,2)  NOT NULL,
    txn_datetime DATETIME      NOT NULL,
    payment_mode VARCHAR(30)   NOT NULL,
    passenger_id INT           NOT NULL,
    trip_id      INT           NOT NULL,
    card_id      INT,
    CONSTRAINT pk_ticket_txn PRIMARY KEY (txn_id),
    CONSTRAINT fk_txn_passenger
        FOREIGN KEY (passenger_id) REFERENCES Passenger(passenger_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_txn_trip
        FOREIGN KEY (trip_id) REFERENCES Trip(trip_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_txn_card
        FOREIGN KEY (card_id) REFERENCES Smart_Card(card_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- ============================================================
--  27. COMPLAINT
-- ============================================================
CREATE TABLE Complaint (
    complaint_id  INT           NOT NULL,
    category      VARCHAR(50)   NOT NULL,
    description   VARCHAR(1000),
    status        VARCHAR(20)   NOT NULL DEFAULT 'Open',
    filed_date    DATE          NOT NULL,
    resolved_date DATE,
    passenger_id  INT           NOT NULL,
    trip_id       INT           NOT NULL,
    CONSTRAINT pk_complaint PRIMARY KEY (complaint_id),
    CONSTRAINT fk_comp_passenger
        FOREIGN KEY (passenger_id) REFERENCES Passenger(passenger_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_comp_trip
        FOREIGN KEY (trip_id) REFERENCES Trip(trip_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
--  END OF DDL  |  Total: 27 tables  |  41 FK constraints
--  Weak entities   : Route_Stop, Trip_Stop
--  ISA subtypes    : Bus, Metro_Train, Driver, Conductor, Motorman
--  MV attr tables  : Staff_Certification, Passenger_Phone
--  1:1 via UNIQUE  : Smart_Card(passenger_id), Interchange(stop_id)
-- ============================================================
