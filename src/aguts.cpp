#include <iostream>
#include <libpq-fe.h>
#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <string>
#include <openssl/sha.h>
#include <sstream>
#include <iomanip>
#include <termios.h>
#include <unistd.h>

using namespace std;

// ── Global connection ────────────────────────────────────
PGconn *conn;
// ── SHA-256 password hashing ─────────────────────────────
string sha256(const string &input) {
    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256(reinterpret_cast<const unsigned char*>(input.c_str()),
           input.size(), hash);

    ostringstream oss;
    for (int i = 0; i < SHA256_DIGEST_LENGTH; i++)
        oss << hex << setw(2) << setfill('0')
            << (int)hash[i];
    return oss.str();
}

// ── Read password without echo ───────────────────────────
string read_password(const string &prompt) {
    cout << prompt;
    cout.flush();

    struct termios oldt, newt;
    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;
    newt.c_lflag &= ~ECHO;
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);

    string pwd;
    getline(cin, pwd);

    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
    cout << "\n";
    return pwd;
}

// ── Connect to database ──────────────────────────────────
conn = PQconnectdb(
    "host=localhost "
    "port=5432 "
    "dbname=aguts "
    "user=your_user "
    "password=your_password"
);
    if (PQstatus(conn) == CONNECTION_OK) {
        PQexec(conn, "SET search_path TO aguts");
        cout << "Connected to AGUTS database!\n";
        return true;
    } else {
        cout << "Connection failed: "
             << PQerrorMessage(conn) << "\n";
        return false;
    }
}

// ── Disconnect ───────────────────────────────────────────
void db_disconnect() {
    PQfinish(conn);
    cout << "Disconnected.\n";
}

// ── Pause helper ─────────────────────────────────────────
void pause_screen() {
    cout << "\nPress Enter to continue...";
    cin.ignore();
    cin.get();
}

// ════════════════════════════════════════════════════════
// MENU A — NETWORK & INFRASTRUCTURE
// ════════════════════════════════════════════════════════

// A1. View all operators
void show_operators() {
    cout << "\n--- All Transit Operators ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT o.operator_id, o.operator_name, "
        "       o.service_type, c.city_name "
        "FROM   transit_operator o "
        "JOIN   city c ON c.city_id = o.city_id "
        "ORDER  BY o.operator_id");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    printf("%-5s %-20s %-18s %-15s\n",
           "ID", "Operator", "Service Type", "City");
    cout << string(60, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-5s %-20s %-18s %-15s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3));
    PQclear(res);
    pause_screen();
}

// A2. View stops on a route
void show_route_stops() {
    cout << "\n--- Stops on a Route ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT route_id, route_number, route_name "
        "FROM   route "
        "ORDER  BY operator_id, route_number");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    printf("%-5s %-10s %-50s\n", "ID", "Route No", "Route Name");
    cout << string(65, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-5s %-10s %-50s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2));
    PQclear(res);

    cout << "\nEnter Route ID: ";
    int route_id; cin >> route_id;

    char query[512];
    snprintf(query, sizeof(query),
        "SELECT rs.sequence_no, s.stop_name, "
        "       s.stop_type, "
        "       COALESCE(fz.zone_name, 'N/A') "
        "FROM   route_stop rs "
        "JOIN   stop s ON s.stop_id = rs.stop_id "
        "LEFT JOIN fare_zone fz ON fz.zone_id = rs.zone_id "
        "WHERE  rs.route_id = %d "
        "ORDER  BY rs.sequence_no", route_id);

    PGresult *res2 = PQexec(conn, query);
    if (PQresultStatus(res2) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res2); return;
    }

    int rows2 = PQntuples(res2);
    cout << "\n";
    printf("%-5s %-35s %-20s %-20s\n",
           "Seq", "Stop Name", "Type", "Zone");
    cout << string(80, '-') << "\n";
    for (int i = 0; i < rows2; i++)
        printf("%-5s %-35s %-20s %-20s\n",
               PQgetvalue(res2,i,0), PQgetvalue(res2,i,1),
               PQgetvalue(res2,i,2), PQgetvalue(res2,i,3));
    PQclear(res2);
    pause_screen();
}

// A3. View interchange points
void show_interchanges() {
    cout << "\n--- Interchange Points ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT s.stop_name, i.interchange_type, "
        "       COALESCE(i.description, 'N/A'), c.city_name "
        "FROM   interchange i "
        "JOIN   stop s ON s.stop_id = i.stop_id "
        "JOIN   city c ON c.city_id = s.city_id "
        "ORDER  BY c.city_name, s.stop_name");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    printf("%-30s %-20s %-40s\n",
           "Stop", "Type", "Description");
    cout << string(90, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-30s %-20s %-40s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2));
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// MENU B — TRIP OPERATIONS
// ════════════════════════════════════════════════════════

// B1. View trips by date
void view_trips_by_date() {
    cout << "\nEnter date (YYYY-MM-DD): ";
    char date[11]; cin >> date;

    char query[512];
    snprintf(query, sizeof(query),
        "SELECT t.trip_id, r.route_number, "
        "       v.registration_no, "
        "       s.first_name || ' ' || s.last_name, "
        "       t.trip_status "
        "FROM   trip t "
        "JOIN   route r   ON r.route_id   = t.route_id "
        "JOIN   vehicle v ON v.vehicle_id = t.vehicle_id "
        "JOIN   staff s   ON s.staff_id   = t.staff_id "
        "WHERE  t.trip_date = '%s' "
        "ORDER  BY t.trip_id", date);

    PGresult *res = PQexec(conn, query);
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    if (rows == 0) {
        cout << "No trips found for " << date << "\n";
        PQclear(res); pause_screen(); return;
    }

    cout << "\n";
    printf("%-6s %-10s %-22s %-25s %-12s\n",
           "ID", "Route", "Vehicle", "Staff", "Status");
    cout << string(75, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-6s %-10s %-22s %-25s %-12s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3),
               PQgetvalue(res,i,4));
    PQclear(res);
    pause_screen();
}

// B2. View delayed trips
void view_delayed_trips() {
    cout << "\n--- Delayed Trips ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT t.trip_id, "
        "       TO_CHAR(t.trip_date,'YYYY-MM-DD'), "
        "       r.route_number, o.operator_name, "
        "       v.registration_no, "
        "       s.first_name || ' ' || s.last_name "
        "FROM   trip t "
        "JOIN   route r ON r.route_id = t.route_id "
        "JOIN   transit_operator o "
        "              ON o.operator_id = r.operator_id "
        "JOIN   vehicle v ON v.vehicle_id = t.vehicle_id "
        "JOIN   staff s   ON s.staff_id   = t.staff_id "
        "WHERE  t.trip_status = 'Delayed' "
        "ORDER  BY t.trip_date");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    if (rows == 0) {
        cout << "No delayed trips found.\n";
        PQclear(res); pause_screen(); return;
    }

    printf("%-6s %-12s %-10s %-16s %-20s %-20s\n",
           "ID", "Date", "Route", "Operator", "Vehicle", "Staff");
    cout << string(84, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-6s %-12s %-10s %-16s %-20s %-20s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3),
               PQgetvalue(res,i,4), PQgetvalue(res,i,5));
    PQclear(res);
    pause_screen();
}

// B3. On-time performance by operator
void view_otp() {
    cout << "\n--- On-Time Performance by Operator ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT o.operator_name, "
        "       COUNT(t.trip_id), "
        "       SUM(CASE WHEN t.trip_status='Completed' "
        "                THEN 1 ELSE 0 END), "
        "       SUM(CASE WHEN t.trip_status='Delayed' "
        "                THEN 1 ELSE 0 END), "
        "       SUM(CASE WHEN t.trip_status='Cancelled' "
        "                THEN 1 ELSE 0 END), "
        "       ROUND(100.0 * "
        "         SUM(CASE WHEN t.trip_status='Completed' "
        "                  THEN 1 ELSE 0 END) "
        "         / COUNT(t.trip_id), 1) "
        "FROM   trip t "
        "JOIN   route r ON r.route_id = t.route_id "
        "JOIN   transit_operator o "
        "              ON o.operator_id = r.operator_id "
        "GROUP  BY o.operator_name "
        "ORDER  BY o.operator_name");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    printf("%-20s %-8s %-11s %-9s %-11s %-8s\n",
           "Operator", "Total", "Completed",
           "Delayed", "Cancelled", "OTP %");
    cout << string(67, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-20s %-8s %-11s %-9s %-11s %-8s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3),
               PQgetvalue(res,i,4), PQgetvalue(res,i,5));
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// MENU C — PASSENGER SERVICES
// ════════════════════════════════════════════════════════

// C1. Check smart card balance
void check_smart_card() {
    cout << "\nEnter Passenger ID: ";
    int pid; cin >> pid;

    char query[512];
    snprintf(query, sizeof(query),
        "SELECT p.first_name || ' ' || p.last_name, "
        "       sc.card_id, sc.balance, "
        "       sc.card_status, "
        "       TO_CHAR(sc.expiry_date,'YYYY-MM-DD') "
        "FROM   passenger p "
        "JOIN   smart_card sc "
        "       ON sc.passenger_id = p.passenger_id "
        "WHERE  p.passenger_id = %d", pid);

    PGresult *res = PQexec(conn, query);
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    if (PQntuples(res) == 0) {
        cout << "No smart card found for passenger ID "
             << pid << "\n";
        PQclear(res); pause_screen(); return;
    }

    cout << "\n" << string(40, '-') << "\n";
    cout << "Passenger : " << PQgetvalue(res,0,0) << "\n";
    cout << "Card ID   : " << PQgetvalue(res,0,1) << "\n";
    cout << "Balance   : Rs." << PQgetvalue(res,0,2) << "\n";
    cout << "Status    : " << PQgetvalue(res,0,3) << "\n";
    cout << "Expiry    : " << PQgetvalue(res,0,4) << "\n";
    cout << string(40, '-') << "\n";
    PQclear(res);
    pause_screen();
}

// C2. View travel history
void view_travel_history() {
    cout << "\nEnter Passenger ID: ";
    int pid; cin >> pid;

    char query[512];
    snprintf(query, sizeof(query),
        "SELECT tt.txn_id, "
        "       TO_CHAR(tt.txn_datetime,'YYYY-MM-DD'), "
        "       tt.ticket_type, tt.amount, "
        "       tt.payment_mode, r.route_name "
        "FROM   ticket_transaction tt "
        "JOIN   trip t  ON t.trip_id  = tt.trip_id "
        "JOIN   route r ON r.route_id = t.route_id "
        "WHERE  tt.passenger_id = %d "
        "ORDER  BY tt.txn_datetime", pid);

    PGresult *res = PQexec(conn, query);
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    if (rows == 0) {
        cout << "No travel history found.\n";
        PQclear(res); pause_screen(); return;
    }

    cout << "\n";
    printf("%-6s %-12s %-14s %-8s %-12s %-30s\n",
           "TxnID", "Date", "Type", "Amt", "Payment", "Route");
    cout << string(82, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-6s %-12s %-14s %-8s %-12s %-30s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3),
               PQgetvalue(res,i,4), PQgetvalue(res,i,5));
    PQclear(res);
    pause_screen();
}

// C3. Register new passenger
// C3. Register new passenger (with password)
void register_passenger() {
    cout << "\n--- Register New Passenger ---\n\n";

    char fname[100], lname[100], email[200];
    char phone[20], dob[11];
    char uname[100], pwd[100];

    cout << "First Name         : ";
    cin.ignore(); cin.getline(fname, 100);
    cout << "Last Name          : ";
    cin.getline(lname, 100);
    cout << "Email              : ";
    cin.getline(email, 200);
    cout << "Phone              : ";
    cin.getline(phone, 20);
    cout << "Date of Birth (YYYY-MM-DD): ";
    cin.getline(dob, 11);

    cout << "Concession Type:\n";
    cout << "  1. General\n  2. Student\n";
    cout << "  3. Senior\n  4. Differently-Abled\n";
    cout << "Choice: ";
    int cc; cin >> cc;
    const char *conc = (cc==2) ? "Student"  :
                       (cc==3) ? "Senior"   :
                       (cc==4) ? "Differently-Abled" : "General";

    cout << "City: 1=Ahmedabad  2=Gandhinagar\n";
    cout << "Choice: ";
    int cid; cin >> cid;
    cin.ignore();

    cout << "\n--- Create Login Account ---\n";
    cout << "Username           : ";
    cin.getline(uname, 100);
    string pwd_str = read_password("Password           : ");
    strncpy(pwd, pwd_str.c_str(), 99);
    pwd[99] = '\0';

    // Hash the password
    string hashed = sha256(string(pwd));

    // Get next passenger_id
    PGresult *rid = PQexec(conn,
        "SELECT COALESCE(MAX(passenger_id),0)+1 "
        "FROM passenger");
    int new_pid = atoi(PQgetvalue(rid, 0, 0));
    PQclear(rid);

    // Insert into passenger
    char q1[1024];
    snprintf(q1, sizeof(q1),
        "INSERT INTO passenger "
        "(passenger_id, first_name, last_name, email, "
        " date_of_birth, concession_type, city_id) "
        "VALUES (%d, '%s', '%s', '%s', '%s', '%s', %d)",
        new_pid, fname, lname, email, dob, conc, cid);

    PGresult *r1 = PQexec(conn, q1);
    if (PQresultStatus(r1) != PGRES_COMMAND_OK) {
        cout << "Registration failed: "
             << PQerrorMessage(conn) << "\n";
        PQclear(r1); pause_screen(); return;
    }
    PQclear(r1);

    // Insert phone
    char qphone[256];
    snprintf(qphone, sizeof(qphone),
        "INSERT INTO passenger_phone "
        "(passenger_id, phone, phone_type) "
        "VALUES (%d, '%s', 'Mobile')", new_pid, phone);
    PQexec(conn, qphone);

    // Insert into app_user
    char q2[512];
    snprintf(q2, sizeof(q2),
        "INSERT INTO app_user "
        "(username, password_hash, role, ref_id, is_active) "
        "VALUES ('%s', '%s', 'passenger', %d, true)",
        uname, hashed.c_str(), new_pid);

    PGresult *r2 = PQexec(conn, q2);
    if (PQresultStatus(r2) == PGRES_COMMAND_OK) {
        cout << "\nRegistration successful!\n";
        cout << "Passenger ID : " << new_pid << "\n";
        cout << "Username     : " << uname << "\n";
        cout << "You can now login with your credentials.\n";
    } else {
        cout << "Account creation failed: "
             << PQerrorMessage(conn) << "\n";
    }
    PQclear(r2);
    pause_screen();
}

// C4. File a complaint
void file_complaint() {
    cout << "\n--- File a Complaint ---\n\n";

    int pid, tid;
    char cat[50], desc[500];

    cout << "Passenger ID  : "; cin >> pid;
    cout << "Trip ID       : "; cin >> tid;
    cin.ignore();
    cout << "Category      : "; cin.getline(cat, 50);
    cout << "Description   : "; cin.getline(desc, 500);

    PGresult *rid = PQexec(conn,
        "SELECT COALESCE(MAX(complaint_id),0)+1 "
        "FROM complaint");
    int new_cid = atoi(PQgetvalue(rid, 0, 0));
    PQclear(rid);

    char query[1024];
    snprintf(query, sizeof(query),
        "INSERT INTO complaint "
        "(complaint_id, category, description, status, "
        " filed_date, passenger_id, trip_id) "
        "VALUES (%d, '%s', '%s', 'Open', "
        "CURRENT_DATE, %d, %d)",
        new_cid, cat, desc, pid, tid);

    PGresult *res = PQexec(conn, query);
    if (PQresultStatus(res) == PGRES_COMMAND_OK)
        cout << "\nComplaint filed! ID = " << new_cid << "\n";
    else
        cout << "Insert failed: " << PQerrorMessage(conn) << "\n";
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// MENU D — TICKETING
// ════════════════════════════════════════════════════════

// D1. Revenue by operator
void view_revenue() {
    cout << "\n--- Revenue by Operator ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT o.operator_name, "
        "       COUNT(tt.txn_id), "
        "       SUM(tt.amount) "
        "FROM   ticket_transaction tt "
        "JOIN   trip t  ON t.trip_id    = tt.trip_id "
        "JOIN   route r ON r.route_id   = t.route_id "
        "JOIN   transit_operator o "
        "              ON o.operator_id = r.operator_id "
        "GROUP  BY o.operator_name "
        "ORDER  BY SUM(tt.amount) DESC");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    printf("%-22s %-14s %-16s\n",
           "Operator", "Transactions", "Total Revenue");
    cout << string(52, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-22s %-14s Rs.%-13s\n",
               PQgetvalue(res,i,0),
               PQgetvalue(res,i,1),
               PQgetvalue(res,i,2));
    PQclear(res);
    pause_screen();
}

// D2. Issue new ticket
// D2. Issue new ticket (uses stored procedure)
void issue_ticket() {
    cout << "\n--- Issue New Ticket ---\n\n";

    int pid, tid;
    cout << "Passenger ID : "; cin >> pid;
    cout << "Trip ID      : "; cin >> tid;

    cout << "Ticket Type:\n";
    cout << "  1. Token\n  2. Smart Card\n  3. Monthly Pass\n";
    cout << "Choice: ";
    int tc; cin >> tc;
    const char *ttype = (tc==2) ? "Smart Card" :
                        (tc==3) ? "Monthly Pass" : "Token";

    cout << "Payment Mode:\n";
    cout << "  1. Cash\n  2. UPI\n  3. Smart Card\n";
    cout << "Choice: ";
    int pc; cin >> pc;
    const char *pmode = (pc==2) ? "UPI" :
                        (pc==3) ? "Smart Card" : "Cash";

    cout << "Amount (Rs.) : ";
    double amt; cin >> amt;

    // Call stored procedure
    char query[512];
    snprintf(query, sizeof(query),
        "SELECT aguts.issue_ticket(%d, %d, '%s', "
        "%.2f, '%s', NULL)",
        pid, tid, ttype, amt, pmode);

    PGresult *res = PQexec(conn, query);
    if (PQresultStatus(res) == PGRES_TUPLES_OK) {
        cout << "\nTicket issued via stored procedure!\n";
        cout << "Transaction ID = "
             << PQgetvalue(res, 0, 0) << "\n";
    } else {
        cout << "Failed: " << PQerrorMessage(conn) << "\n";
    }
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// MENU E — FLEET & MAINTENANCE
// ════════════════════════════════════════════════════════

// E1. Fleet status summary
void view_fleet_status() {
    cout << "\n--- Fleet Status Summary ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT o.operator_name, "
        "       CASE WHEN mt.vehicle_id IS NOT NULL "
        "            THEN 'Metro Train' ELSE 'Bus' END, "
        "       COUNT(v.vehicle_id), "
        "       SUM(v.capacity) "
        "FROM   vehicle v "
        "JOIN   transit_operator o "
        "              ON o.operator_id = v.operator_id "
        "LEFT JOIN metro_train mt "
        "              ON mt.vehicle_id = v.vehicle_id "
        "LEFT JOIN bus b ON b.vehicle_id = v.vehicle_id "
        "GROUP  BY o.operator_name, "
        "          CASE WHEN mt.vehicle_id IS NOT NULL "
        "               THEN 'Metro Train' ELSE 'Bus' END "
        "ORDER  BY o.operator_name");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    printf("%-20s %-14s %-8s %-12s\n",
           "Operator", "Type", "Count", "Total Cap.");
    cout << string(54, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-20s %-14s %-8s %-12s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3));
    PQclear(res);
    pause_screen();
}

// E2. Maintenance history
void view_maintenance() {
    cout << "\n--- Recent Maintenance Records ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT m.maintenance_id, v.registration_no, "
        "       m.maintenance_type, "
        "       TO_CHAR(m.start_date,'YYYY-MM-DD'), "
        "       COALESCE(TO_CHAR(m.end_date,'YYYY-MM-DD'),"
        "                'Ongoing') "
        "FROM   maintenance m "
        "JOIN   vehicle v ON v.vehicle_id = m.vehicle_id "
        "ORDER  BY m.start_date DESC "
        "LIMIT  20");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    printf("%-5s %-22s %-25s %-12s %-12s\n",
           "ID", "Vehicle", "Type", "Start", "End");
    cout << string(76, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-5s %-22s %-25s %-12s %-12s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3),
               PQgetvalue(res,i,4));
    PQclear(res);
    pause_screen();
}

// E3. Vehicles not assigned to any trip (idle fleet)
void view_idle_vehicles() {
    cout << "\n--- Idle Vehicles (No trips in Jan 2024) ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT v.registration_no, o.operator_name, "
        "       v.status, d.depot_name "
        "FROM   vehicle v "
        "JOIN   transit_operator o "
        "              ON o.operator_id = v.operator_id "
        "JOIN   depot d ON d.depot_id   = v.depot_id "
        "WHERE  v.vehicle_id NOT IN ( "
        "    SELECT DISTINCT vehicle_id FROM trip "
        "    WHERE trip_date BETWEEN '2024-01-01' "
        "                       AND '2024-01-31') "
        "ORDER  BY o.operator_name");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    if (rows == 0) {
        cout << "All vehicles were used in January 2024.\n";
        PQclear(res); pause_screen(); return;
    }

    printf("%-22s %-18s %-10s %-25s\n",
           "Registration", "Operator", "Status", "Depot");
    cout << string(75, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-22s %-18s %-10s %-25s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3));
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// MENU F — STAFF & COMPLAINTS
// ════════════════════════════════════════════════════════

// F1. View all staff
void view_staff() {
    cout << "\n--- All Staff ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT s.staff_id, "
        "       s.first_name || ' ' || s.last_name, "
        "       s.role, o.operator_name, "
        "       d.depot_name, s.contact "
        "FROM   staff s "
        "JOIN   transit_operator o "
        "              ON o.operator_id = s.operator_id "
        "JOIN   depot d ON d.depot_id   = s.depot_id "
        "ORDER  BY o.operator_name, s.role");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    printf("%-5s %-25s %-12s %-16s %-22s %-14s\n",
           "ID", "Name", "Role", "Operator",
           "Depot", "Contact");
    cout << string(94, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-5s %-25s %-12s %-16s %-22s %-14s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3),
               PQgetvalue(res,i,4), PQgetvalue(res,i,5));
    PQclear(res);
    pause_screen();
}

// F2. View all complaints
void view_complaints() {
    cout << "\n--- All Complaints ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT c.complaint_id, c.category, c.status, "
        "       TO_CHAR(c.filed_date,'YYYY-MM-DD'), "
        "       p.first_name || ' ' || p.last_name, "
        "       LEFT(c.description, 35) "
        "FROM   complaint c "
        "JOIN   passenger p "
        "              ON p.passenger_id = c.passenger_id "
        "ORDER  BY "
        "    CASE c.status "
        "        WHEN 'Open'        THEN 1 "
        "        WHEN 'In Progress' THEN 2 "
        "        ELSE 3 END, "
        "    c.filed_date");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    printf("%-5s %-18s %-14s %-12s %-22s %-35s\n",
           "ID", "Category", "Status",
           "Filed", "Passenger", "Description");
    cout << string(106, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-5s %-18s %-14s %-12s %-22s %-35s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3),
               PQgetvalue(res,i,4), PQgetvalue(res,i,5));
    PQclear(res);
    pause_screen();
}

// F3. Staff trip performance
void view_staff_performance() {
    cout << "\n--- Staff Trip Performance (Jan 2024) ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT s.first_name || ' ' || s.last_name, "
        "       s.role, o.operator_name, "
        "       COUNT(t.trip_id), "
        "       SUM(CASE WHEN t.trip_status='Completed' "
        "                THEN 1 ELSE 0 END), "
        "       SUM(CASE WHEN t.trip_status='Delayed' "
        "                THEN 1 ELSE 0 END) "
        "FROM   staff s "
        "JOIN   transit_operator o "
        "              ON o.operator_id = s.operator_id "
        "JOIN   trip t ON t.staff_id = s.staff_id "
        "WHERE  t.trip_date BETWEEN '2024-01-01' "
        "                       AND '2024-01-31' "
        "GROUP  BY s.first_name, s.last_name, "
        "          s.role, o.operator_name "
        "ORDER  BY o.operator_name, s.first_name");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    printf("%-25s %-12s %-16s %-7s %-11s %-9s\n",
           "Staff Name", "Role", "Operator",
           "Total", "Completed", "Delayed");
    cout << string(80, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-25s %-12s %-16s %-7s %-11s %-9s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3),
               PQgetvalue(res,i,4), PQgetvalue(res,i,5));
    PQclear(res);
    pause_screen();
}


// ── Login ────────────────────────────────────────────────
// Returns role: "passenger", "staff", "admin", "" = failed
string login(int &ref_id) {
    cout << "\n--- AGUTS Login ---\n";
    cout << "Username: ";
    char uname[100];
    cin.ignore();
    cin.getline(uname, 100);

   string pwd_str = read_password("Password: ");
    char pwd[100];
    strncpy(pwd, pwd_str.c_str(), 99);
    pwd[99] = '\0';

    string hashed = sha256(string(pwd));

    char query[512];
    snprintf(query, sizeof(query),
        "SELECT role, ref_id, is_active "
        "FROM   app_user "
        "WHERE  username = '%s' "
        "AND    password_hash = '%s'",
        uname, hashed.c_str());

    PGresult *res = PQexec(conn, query);

    if (PQresultStatus(res) != PGRES_TUPLES_OK ||
        PQntuples(res) == 0) {
        cout << "Invalid username or password.\n";
        PQclear(res);
        return "";
    }

    string is_active = PQgetvalue(res, 0, 2);
    if (is_active == "f") {
        cout << "Account not activated yet. "
             << "Please wait for admin approval.\n";
        PQclear(res);
        return "";
    }

    string role = PQgetvalue(res, 0, 0);
    ref_id = PQgetisnull(res, 0, 1) ? -1 :
             atoi(PQgetvalue(res, 0, 1));

    PQclear(res);
    cout << "Login successful! Role: " << role << "\n";
    return role;
}
// ── Staff Registration Request ───────────────────────────
void request_staff_registration() {
    cout << "\n--- Staff Registration Request ---\n";
    cout << "Note: Your request will be reviewed by Admin.\n\n";

    char fname[100], lname[100], contact[20];
    cin.ignore();
    cout << "First Name  : "; cin.getline(fname, 100);
    cout << "Last Name   : "; cin.getline(lname, 100);
    cout << "Contact     : "; cin.getline(contact, 20);

    cout << "Role:\n";
    cout << "  1. Driver\n";
    cout << "  2. Conductor\n";
    cout << "  3. Motorman\n";
    cout << "Choice: ";
    int rc; cin >> rc;
    const char *role = (rc==2) ? "Conductor" :
                       (rc==3) ? "Motorman"  : "Driver";

    // Show operators
    PGresult *ops = PQexec(conn,
        "SELECT operator_id, operator_name "
        "FROM transit_operator ORDER BY operator_id");
    int nops = PQntuples(ops);
    cout << "\nOperator:\n";
    for (int i = 0; i < nops; i++)
        printf("  %s. %s\n",
               PQgetvalue(ops,i,0),
               PQgetvalue(ops,i,1));
    PQclear(ops);
    cout << "Choice: ";
    int oid; cin >> oid;

    // Show depots for that operator
    char dq[256];
    snprintf(dq, sizeof(dq),
        "SELECT depot_id, depot_name "
        "FROM depot WHERE operator_id = %d "
        "ORDER BY depot_id", oid);
    PGresult *deps = PQexec(conn, dq);
    int ndeps = PQntuples(deps);
    cout << "\nDepot:\n";
    for (int i = 0; i < ndeps; i++)
        printf("  %s. %s\n",
               PQgetvalue(deps,i,0),
               PQgetvalue(deps,i,1));
    PQclear(deps);
    cout << "Choice: ";
    int did; cin >> did;

    // Insert into staff_request
    char query[512];
    snprintf(query, sizeof(query),
        "INSERT INTO staff_request "
        "(first_name, last_name, role, contact, "
        " operator_id, depot_id, status) "
        "VALUES ('%s', '%s', '%s', '%s', %d, %d, 'Pending')",
        fname, lname, role, contact, oid, did);

    PGresult *res = PQexec(conn, query);
    if (PQresultStatus(res) == PGRES_COMMAND_OK)
        cout << "\nRequest submitted! "
             << "Please wait for Admin approval.\n";
    else
        cout << "Failed: " << PQerrorMessage(conn) << "\n";
    PQclear(res);
    pause_screen();
}
// ── Admin: Approve Staff Requests ───────────────────────
void approve_staff_requests() {
    cout << "\n--- Pending Staff Requests ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT sr.request_id, sr.first_name, "
        "       sr.last_name, sr.role, sr.contact, "
        "       o.operator_name, d.depot_name, "
        "       TO_CHAR(sr.requested_at,'YYYY-MM-DD') "
        "FROM   staff_request sr "
        "JOIN   transit_operator o "
        "              ON o.operator_id = sr.operator_id "
        "JOIN   depot d ON d.depot_id   = sr.depot_id "
        "WHERE  sr.status = 'Pending' "
        "ORDER  BY sr.requested_at");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    if (rows == 0) {
        cout << "No pending requests.\n";
        PQclear(res); pause_screen(); return;
    }

    printf("%-5s %-20s %-12s %-12s %-16s %-20s %-12s\n",
           "ID", "Name", "Role", "Contact",
           "Operator", "Depot", "Requested");
    cout << string(97, '-') << "\n";

    for (int i = 0; i < rows; i++) {
        string fullname = string(PQgetvalue(res,i,1))
                        + " " + PQgetvalue(res,i,2);
        printf("%-5s %-20s %-12s %-12s %-16s %-20s %-12s\n",
               PQgetvalue(res,i,0),
               fullname.c_str(),
               PQgetvalue(res,i,3),
               PQgetvalue(res,i,4),
               PQgetvalue(res,i,5),
               PQgetvalue(res,i,6),
               PQgetvalue(res,i,7));
    }
    PQclear(res);

    cout << "\nEnter Request ID to approve (0 to cancel): ";
    int req_id; cin >> req_id;
    if (req_id == 0) { pause_screen(); return; }

    // Fetch request details
    char qdet[256];
    snprintf(qdet, sizeof(qdet),
        "SELECT first_name, last_name, role, "
        "       contact, operator_id, depot_id "
        "FROM   staff_request "
        "WHERE  request_id = %d AND status = 'Pending'",
        req_id);

    PGresult *det = PQexec(conn, qdet);
    if (PQresultStatus(det) != PGRES_TUPLES_OK ||
        PQntuples(det) == 0) {
        cout << "Request not found.\n";
        PQclear(det); pause_screen(); return;
    }

    char fname[100], lname[100], role[30];
    char contact[20];
    int oid, did;
    strcpy(fname,   PQgetvalue(det,0,0));
    strcpy(lname,   PQgetvalue(det,0,1));
    strcpy(role,    PQgetvalue(det,0,2));
    strcpy(contact, PQgetvalue(det,0,3));
    oid = atoi(PQgetvalue(det,0,4));
    did = atoi(PQgetvalue(det,0,5));
    PQclear(det);

    cout << "Approve " << fname << " " << lname
         << " as " << role << "? (y/n): ";
    char confirm; cin >> confirm;
    if (confirm != 'y' && confirm != 'Y') {
        cout << "Cancelled.\n";
        pause_screen(); return;
    }

    // Ask for joining date
    cin.ignore();
    char doj[11];
    cout << "Date of Joining (YYYY-MM-DD): ";
    cin.getline(doj, 11);

    // Get next staff_id
    PGresult *sid = PQexec(conn,
        "SELECT COALESCE(MAX(staff_id),0)+1 FROM staff");
    int new_sid = atoi(PQgetvalue(sid, 0, 0));
    PQclear(sid);

    // Insert into staff
    char q1[512];
    snprintf(q1, sizeof(q1),
        "INSERT INTO staff "
        "(staff_id, first_name, last_name, role, "
        " contact, date_of_joining, "
        " operator_id, depot_id) "
        "VALUES (%d, '%s', '%s', '%s', "
        "'%s', '%s', %d, %d)",
        new_sid, fname, lname, role,
        contact, doj, oid, did);

    PGresult *r1 = PQexec(conn, q1);
    if (PQresultStatus(r1) != PGRES_COMMAND_OK) {
        cout << "Staff insert failed: "
             << PQerrorMessage(conn) << "\n";
        PQclear(r1); pause_screen(); return;
    }
    PQclear(r1);

    // Insert into driver/conductor/motorman
    if (string(role) == "Driver") {
        char lic[50];
        cout << "License Number: "; cin.getline(lic, 50);
        char qd[256];
        snprintf(qd, sizeof(qd),
            "INSERT INTO driver (staff_id, license_no) "
            "VALUES (%d, '%s')", new_sid, lic);
        PQexec(conn, qd);
    } else if (string(role) == "Conductor") {
        char badge[50];
        cout << "Badge Number: "; cin.getline(badge, 50);
        char qc[256];
        snprintf(qc, sizeof(qc),
            "INSERT INTO conductor (staff_id, badge_no) "
            "VALUES (%d, '%s')", new_sid, badge);
        PQexec(conn, qc);
    } else if (string(role) == "Motorman") {
        char mlic[50];
        cout << "Metro License Number: ";
        cin.getline(mlic, 50);
        char qm[256];
        snprintf(qm, sizeof(qm),
            "INSERT INTO motorman "
            "(staff_id, metro_license_no) "
            "VALUES (%d, '%s')", new_sid, mlic);
        PQexec(conn, qm);
    }

    // Create app_user for staff
    string uname = string(fname) + "_" +
                   to_string(new_sid);
    string default_pwd = sha256("Staff@2024");

    char q2[512];
    snprintf(q2, sizeof(q2),
        "INSERT INTO app_user "
        "(username, password_hash, role, "
        " ref_id, is_active) "
        "VALUES ('%s', '%s', 'staff', %d, true)",
        uname.c_str(), default_pwd.c_str(), new_sid);
    PQexec(conn, q2);

    // Update staff_request status
    char qu[256];
    snprintf(qu, sizeof(qu),
        "UPDATE staff_request "
        "SET status = 'Approved', "
        "    reviewed_at = NOW() "
        "WHERE request_id = %d", req_id);
    PQexec(conn, qu);

    cout << "\nStaff approved successfully!\n";
    cout << "Staff ID   : " << new_sid << "\n";
    cout << "Username   : " << uname << "\n";
    cout << "Password   : Staff@2024 (default)\n";
    cout << "Staff can now login.\n";
    pause_screen();
}

// ── Staff: My certifications ─────────────────────────────
void my_certifications(int staff_id) {
    cout << "\n--- My Certifications ---\n\n";

    char query[512];
    snprintf(query, sizeof(query),
        "SELECT sc.certification, "
        "       TO_CHAR(sc.issued_date,'YYYY-MM-DD'), "
        "       TO_CHAR(sc.expiry_date,'YYYY-MM-DD'), "
        "       CASE WHEN sc.expiry_date < CURRENT_DATE "
        "            THEN 'EXPIRED' "
        "            WHEN sc.expiry_date < "
        "                 CURRENT_DATE + INTERVAL '90 days' "
        "            THEN 'EXPIRING SOON' "
        "            ELSE 'Valid' END "
        "FROM   staff_certification sc "
        "WHERE  sc.staff_id = %d", staff_id);

    PGresult *res = PQexec(conn, query);
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    if (rows == 0) {
        cout << "No certifications found.\n";
        PQclear(res); pause_screen(); return;
    }

    printf("%-35s %-12s %-12s %-15s\n",
           "Certification", "Issued", "Expiry", "Status");
    cout << string(74, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-35s %-12s %-12s %-15s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3));
    PQclear(res);
    pause_screen();
}

// ── Staff: My assigned trips ─────────────────────────────
void my_trips(int staff_id) {
    cout << "\n--- My Assigned Trips ---\n\n";

    char query[512];
    snprintf(query, sizeof(query),
        "SELECT t.trip_id, "
        "       TO_CHAR(t.trip_date,'YYYY-MM-DD'), "
        "       r.route_number, r.route_name, "
        "       v.registration_no, t.trip_status "
        "FROM   trip t "
        "JOIN   route r   ON r.route_id   = t.route_id "
        "JOIN   vehicle v ON v.vehicle_id = t.vehicle_id "
        "WHERE  t.staff_id = %d "
        "ORDER  BY t.trip_date DESC", staff_id);

    PGresult *res = PQexec(conn, query);
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    if (rows == 0) {
        cout << "No trips assigned yet.\n";
        PQclear(res); pause_screen(); return;
    }

    printf("%-6s %-12s %-8s %-40s %-20s %-12s\n",
           "ID", "Date", "Route",
           "Route Name", "Vehicle", "Status");
    cout << string(98, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-6s %-12s %-8s %-40s %-20s %-12s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3),
               PQgetvalue(res,i,4), PQgetvalue(res,i,5));
    PQclear(res);
    pause_screen();
}

// ── Passenger: smart card (auto id) ─────────────────────
void check_smart_card_by_id(int pid) {
    char query[512];
    snprintf(query, sizeof(query),
        "SELECT p.first_name || ' ' || p.last_name, "
        "       sc.card_id, sc.balance, "
        "       sc.card_status, "
        "       TO_CHAR(sc.expiry_date,'YYYY-MM-DD') "
        "FROM   passenger p "
        "JOIN   smart_card sc "
        "       ON sc.passenger_id = p.passenger_id "
        "WHERE  p.passenger_id = %d", pid);

    PGresult *res = PQexec(conn, query);
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    if (PQntuples(res) == 0) {
        cout << "\nYou do not have a smart card yet.\n";
        PQclear(res); pause_screen(); return;
    }

    cout << "\n" << string(40, '-') << "\n";
    cout << "Passenger : " << PQgetvalue(res,0,0) << "\n";
    cout << "Card ID   : " << PQgetvalue(res,0,1) << "\n";
    cout << "Balance   : Rs." << PQgetvalue(res,0,2) << "\n";
    cout << "Status    : " << PQgetvalue(res,0,3) << "\n";
    cout << "Expiry    : " << PQgetvalue(res,0,4) << "\n";
    cout << string(40, '-') << "\n";
    PQclear(res);
    pause_screen();
}

// ── Passenger: travel history (auto id) ─────────────────
void view_travel_history_by_id(int pid) {
    cout << "\n--- My Travel History ---\n\n";

    char query[512];
    snprintf(query, sizeof(query),
        "SELECT tt.txn_id, "
        "       TO_CHAR(tt.txn_datetime,'YYYY-MM-DD'), "
        "       tt.ticket_type, tt.amount, "
        "       tt.payment_mode, r.route_name "
        "FROM   ticket_transaction tt "
        "JOIN   trip t  ON t.trip_id  = tt.trip_id "
        "JOIN   route r ON r.route_id = t.route_id "
        "WHERE  tt.passenger_id = %d "
        "ORDER  BY tt.txn_datetime", pid);

    PGresult *res = PQexec(conn, query);
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    if (rows == 0) {
        cout << "No travel history found.\n";
        PQclear(res); pause_screen(); return;
    }

    printf("%-6s %-12s %-14s %-8s %-12s %-30s\n",
           "TxnID", "Date", "Type",
           "Amt", "Payment", "Route");
    cout << string(82, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-6s %-12s %-14s %-8s %-12s %-30s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3),
               PQgetvalue(res,i,4), PQgetvalue(res,i,5));
    PQclear(res);
    pause_screen();
}

// ── Passenger: file complaint (auto id) ─────────────────
// Passenger: file complaint (uses stored procedure)
void file_complaint_by_id(int pid) {
    cout << "\n--- File a Complaint ---\n\n";

    int tid;
    char cat[50], desc[500];

    cout << "Trip ID      : "; cin >> tid;
    cin.ignore();
    cout << "Category     : "; cin.getline(cat, 50);
    cout << "Description  : "; cin.getline(desc, 500);

    // Call stored procedure
    char query[1024];
    snprintf(query, sizeof(query),
        "SELECT aguts.file_complaint(%d, %d, '%s', '%s')",
        pid, tid, cat, desc);

    PGresult *res = PQexec(conn, query);
    if (PQresultStatus(res) == PGRES_TUPLES_OK) {
        cout << "\nComplaint filed via stored procedure!\n";
        cout << "Complaint ID = "
             << PQgetvalue(res, 0, 0) << "\n";
    } else {
        cout << "Failed: " << PQerrorMessage(conn) << "\n";
    }
    PQclear(res);
    pause_screen();
}

// ── Passenger: my complaints (auto id) ──────────────────
void view_my_complaints(int pid) {
    cout << "\n--- My Complaints ---\n\n";

    char query[512];
    snprintf(query, sizeof(query),
        "SELECT c.complaint_id, c.category, c.status, "
        "       TO_CHAR(c.filed_date,'YYYY-MM-DD'), "
        "       COALESCE(TO_CHAR(c.resolved_date,"
        "                        'YYYY-MM-DD'),'Pending'), "
        "       LEFT(c.description, 35) "
        "FROM   complaint c "
        "WHERE  c.passenger_id = %d "
        "ORDER  BY c.filed_date DESC", pid);

    PGresult *res = PQexec(conn, query);
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    if (rows == 0) {
        cout << "You have no complaints filed.\n";
        PQclear(res); pause_screen(); return;
    }

    printf("%-5s %-18s %-14s %-12s %-12s %-35s\n",
           "ID", "Category", "Status",
           "Filed", "Resolved", "Description");
    cout << string(96, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-5s %-18s %-14s %-12s %-12s %-35s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3),
               PQgetvalue(res,i,4), PQgetvalue(res,i,5));
    PQclear(res);
    pause_screen();
}

// Passenger: recharge smart card (uses stored procedure)
void recharge_smart_card(int pid) {
    cout << "\n--- Recharge Smart Card ---\n\n";

    // First show current balance
    char qbal[256];
    snprintf(qbal, sizeof(qbal),
        "SELECT card_id, balance FROM aguts.smart_card "
        "WHERE passenger_id = %d", pid);
    PGresult *bal = PQexec(conn, qbal);

    if (PQresultStatus(bal) != PGRES_TUPLES_OK ||
        PQntuples(bal) == 0) {
        cout << "No smart card found.\n";
        PQclear(bal); pause_screen(); return;
    }

    int card_id = atoi(PQgetvalue(bal, 0, 0));
    cout << "Current Balance : Rs."
         << PQgetvalue(bal, 0, 1) << "\n";
    PQclear(bal);

    cout << "Recharge Amount : Rs.";
    double amt; cin >> amt;

    // Call stored procedure
    char query[256];
    snprintf(query, sizeof(query),
        "SELECT aguts.recharge_smart_card(%d, %.2f)",
        card_id, amt);

    PGresult *res = PQexec(conn, query);
    if (PQresultStatus(res) == PGRES_TUPLES_OK) {
        cout << "\nRecharge successful!\n";
        cout << "New Balance : Rs."
             << PQgetvalue(res, 0, 0) << "\n";
    } else {
        cout << "Failed: " << PQerrorMessage(conn) << "\n";
    }
    PQclear(res);
    pause_screen();
}


void book_ticket(int pid) {
    cout << "\n--- Book a Ticket ---\n\n";

    // Step 1: Select operator
    PGresult *ops = PQexec(conn,
        "SELECT operator_id, operator_name, service_type "
        "FROM aguts.transit_operator "
        "ORDER BY operator_id");

    if (PQresultStatus(ops) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(ops); return;
    }

    cout << "--- Select Operator ---\n";
    int nops = PQntuples(ops);
    for (int i = 0; i < nops; i++)
        printf("  %s. %-20s (%s)\n",
               PQgetvalue(ops,i,0),
               PQgetvalue(ops,i,1),
               PQgetvalue(ops,i,2));
    PQclear(ops);

    cout << "Choice: ";
    int oid; cin >> oid;

    // Step 2: Show FROM stops for that operator
    char qstops[512];
    snprintf(qstops, sizeof(qstops),
        "SELECT DISTINCT s.stop_id, s.stop_name, "
        "       s.stop_type "
        "FROM   aguts.stop s "
        "JOIN   aguts.route_stop rs ON rs.stop_id = s.stop_id "
        "JOIN   aguts.route r       ON r.route_id = rs.route_id "
        "WHERE  r.operator_id = %d "
        "ORDER  BY s.stop_id", oid);

    PGresult *stops = PQexec(conn, qstops);
    if (PQresultStatus(stops) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(stops); return;
    }

    cout << "\n--- Select FROM Stop ---\n";
    printf("%-6s %-35s %-20s\n", "ID", "Stop Name", "Type");
    cout << string(61, '-') << "\n";
    int nstops = PQntuples(stops);
    for (int i = 0; i < nstops; i++)
        printf("%-6s %-35s %-20s\n",
               PQgetvalue(stops,i,0),
               PQgetvalue(stops,i,1),
               PQgetvalue(stops,i,2));
    PQclear(stops);

    cout << "Choice: ";
    int from_stop; cin >> from_stop;

    // Show selected FROM stop
    char qfsn[256];
    snprintf(qfsn, sizeof(qfsn),
        "SELECT stop_name FROM aguts.stop "
        "WHERE stop_id = %d", from_stop);
    PGresult *fsn = PQexec(conn, qfsn);
    if (PQresultStatus(fsn) == PGRES_TUPLES_OK &&
        PQntuples(fsn) > 0)
        cout << "FROM: " << PQgetvalue(fsn,0,0) << "\n";
    PQclear(fsn);

    // Step 3: Show reachable TO stops from FROM stop
    char qto[512];
    snprintf(qto, sizeof(qto),
        "SELECT DISTINCT s.stop_id, s.stop_name "
        "FROM   aguts.stop s "
        "JOIN   aguts.route_stop rs2 ON rs2.stop_id = s.stop_id "
        "JOIN   aguts.route r        ON r.route_id  = rs2.route_id "
        "WHERE  r.operator_id = %d "
        "AND    r.route_id IN ( "
        "    SELECT route_id FROM aguts.route_stop "
        "    WHERE  stop_id = %d) "
        "AND    s.stop_id != %d "
        "AND    rs2.sequence_no > ( "
        "    SELECT sequence_no FROM aguts.route_stop "
        "    WHERE  route_id = r.route_id "
        "    AND    stop_id  = %d "
        "    LIMIT  1) "
        "ORDER  BY s.stop_id",
        oid, from_stop, from_stop, from_stop);

    PGresult *tos = PQexec(conn, qto);
    if (PQresultStatus(tos) != PGRES_TUPLES_OK ||
        PQntuples(tos) == 0) {
        cout << "No reachable stops found.\n";
        PQclear(tos); pause_screen(); return;
    }

    cout << "\n--- Select TO Stop ---\n";
    printf("%-6s %-35s\n", "ID", "Stop Name");
    cout << string(41, '-') << "\n";
    int ntos = PQntuples(tos);
    for (int i = 0; i < ntos; i++)
        printf("%-6s %-35s\n",
               PQgetvalue(tos,i,0),
               PQgetvalue(tos,i,1));
    PQclear(tos);

    cout << "Choice: ";
    int to_stop; cin >> to_stop;

    // Show selected TO stop
    char qtsn[256];
    snprintf(qtsn, sizeof(qtsn),
        "SELECT stop_name FROM aguts.stop "
        "WHERE stop_id = %d", to_stop);
    PGresult *tsn = PQexec(conn, qtsn);
    if (PQresultStatus(tsn) == PGRES_TUPLES_OK &&
        PQntuples(tsn) > 0)
        cout << "TO  : " << PQgetvalue(tsn,0,0) << "\n";
    PQclear(tsn);

    // Step 4: Find route connecting both stops
    char qroute[512];
    snprintf(qroute, sizeof(qroute),
        "SELECT r.route_id, r.route_number, r.route_name "
        "FROM   aguts.route r "
        "WHERE  r.operator_id = %d "
        "AND    r.route_id IN ( "
        "    SELECT route_id FROM aguts.route_stop "
        "    WHERE  stop_id = %d) "
        "AND    r.route_id IN ( "
        "    SELECT route_id FROM aguts.route_stop "
        "    WHERE  stop_id = %d) "
        "LIMIT 1", oid, from_stop, to_stop);

    PGresult *route = PQexec(conn, qroute);
    if (PQresultStatus(route) != PGRES_TUPLES_OK ||
        PQntuples(route) == 0) {
        cout << "No route found connecting these stops.\n";
        PQclear(route); pause_screen(); return;
    }

    int    route_id = atoi(PQgetvalue(route,0,0));
    string route_no = PQgetvalue(route,0,1);
    string route_nm = PQgetvalue(route,0,2);
    PQclear(route);

    // Step 5: Find most recent available trip
    char qtrip[512];
    snprintf(qtrip, sizeof(qtrip),
        "SELECT t.trip_id, "
        "       TO_CHAR(t.trip_date,'YYYY-MM-DD'), "
        "       t.trip_status, "
        "       v.registration_no "
        "FROM   aguts.trip t "
        "JOIN   aguts.vehicle v ON v.vehicle_id = t.vehicle_id "
        "WHERE  t.route_id = %d "
        "AND    t.trip_status != 'Cancelled' "
        "ORDER  BY t.trip_date DESC "
        "LIMIT  1", route_id);

    PGresult *trip = PQexec(conn, qtrip);
    if (PQresultStatus(trip) != PGRES_TUPLES_OK ||
        PQntuples(trip) == 0) {
        cout << "No available trips on this route.\n";
        PQclear(trip); pause_screen(); return;
    }

    int    trip_id   = atoi(PQgetvalue(trip,0,0));
    string trip_date = PQgetvalue(trip,0,1);
    string vehicle   = PQgetvalue(trip,0,3);
    PQclear(trip);

    // Step 6: Get zones for both stops on this route
    char qfz1[256], qfz2[256];
    snprintf(qfz1, sizeof(qfz1),
        "SELECT zone_id FROM aguts.route_stop "
        "WHERE route_id = %d AND stop_id = %d LIMIT 1",
        route_id, from_stop);
    snprintf(qfz2, sizeof(qfz2),
        "SELECT zone_id FROM aguts.route_stop "
        "WHERE route_id = %d AND stop_id = %d LIMIT 1",
        route_id, to_stop);

    PGresult *fz1 = PQexec(conn, qfz1);
    PGresult *fz2 = PQexec(conn, qfz2);

    double fare_amt  = 0.0;
    string from_zone = "N/A";
    string to_zone   = "N/A";

    if (PQresultStatus(fz1) == PGRES_TUPLES_OK &&
        PQntuples(fz1) > 0 &&
        PQresultStatus(fz2) == PGRES_TUPLES_OK &&
        PQntuples(fz2) > 0) {

        int z1 = atoi(PQgetvalue(fz1,0,0));
        int z2 = atoi(PQgetvalue(fz2,0,0));

        // Get passenger concession type
        string concession = "General";
        if (pid > 0) {
            char qconc[256];
            snprintf(qconc, sizeof(qconc),
                "SELECT concession_type "
                "FROM aguts.passenger "
                "WHERE passenger_id = %d", pid);
            PGresult *conc = PQexec(conn, qconc);
            if (PQresultStatus(conc) == PGRES_TUPLES_OK &&
                PQntuples(conc) > 0)
                concession = PQgetvalue(conc,0,0);
            PQclear(conc);
        }

        // Lookup fare for passenger concession type
        char qfare[512];
        snprintf(qfare, sizeof(qfare),
            "SELECT f.fare_amount, "
            "       fz1.zone_name, fz2.zone_name "
            "FROM   aguts.fare f "
            "JOIN   aguts.fare_zone fz1 "
            "       ON fz1.zone_id = f.from_zone_id "
            "JOIN   aguts.fare_zone fz2 "
            "       ON fz2.zone_id = f.to_zone_id "
            "WHERE  f.operator_id     = %d "
            "AND    f.from_zone_id    = %d "
            "AND    f.to_zone_id      = %d "
            "AND    f.concession_type = '%s' "
            "LIMIT  1",
            oid, z1, z2, concession.c_str());

        PGresult *fare = PQexec(conn, qfare);

        if (PQresultStatus(fare) == PGRES_TUPLES_OK &&
            PQntuples(fare) > 0) {
            fare_amt  = atof(PQgetvalue(fare,0,0));
            from_zone = PQgetvalue(fare,0,1);
            to_zone   = PQgetvalue(fare,0,2);
            PQclear(fare);
        } else {
            PQclear(fare);
            // Fallback: General fare
            char qfg[512];
            snprintf(qfg, sizeof(qfg),
                "SELECT f.fare_amount, "
                "       fz1.zone_name, fz2.zone_name "
                "FROM   aguts.fare f "
                "JOIN   aguts.fare_zone fz1 "
                "       ON fz1.zone_id = f.from_zone_id "
                "JOIN   aguts.fare_zone fz2 "
                "       ON fz2.zone_id = f.to_zone_id "
                "WHERE  f.operator_id     = %d "
                "AND    f.from_zone_id    = %d "
                "AND    f.to_zone_id      = %d "
                "AND    f.concession_type = 'General' "
                "LIMIT  1",
                oid, z1, z2);
            PGresult *fg = PQexec(conn, qfg);
            if (PQresultStatus(fg) == PGRES_TUPLES_OK &&
                PQntuples(fg) > 0) {
                fare_amt  = atof(PQgetvalue(fg,0,0));
                from_zone = PQgetvalue(fg,0,1);
                to_zone   = PQgetvalue(fg,0,2);
            }
            PQclear(fg);
        }
    }
    PQclear(fz1);
    PQclear(fz2);

    // Step 7: Get stop names for summary
    char qsn1[256], qsn2[256];
    snprintf(qsn1, sizeof(qsn1),
        "SELECT stop_name FROM aguts.stop "
        "WHERE stop_id = %d", from_stop);
    snprintf(qsn2, sizeof(qsn2),
        "SELECT stop_name FROM aguts.stop "
        "WHERE stop_id = %d", to_stop);

    PGresult *sn1 = PQexec(conn, qsn1);
    PGresult *sn2 = PQexec(conn, qsn2);
    string from_name = "Unknown";
    string to_name   = "Unknown";
    if (PQresultStatus(sn1) == PGRES_TUPLES_OK &&
        PQntuples(sn1) > 0)
        from_name = PQgetvalue(sn1,0,0);
    if (PQresultStatus(sn2) == PGRES_TUPLES_OK &&
        PQntuples(sn2) > 0)
        to_name = PQgetvalue(sn2,0,0);
    PQclear(sn1);
    PQclear(sn2);

    // Show booking summary
    cout << "\n" << string(50, '=') << "\n";
    cout << "         BOOKING SUMMARY\n";
    cout << string(50, '=') << "\n";
    cout << "From      : " << from_name << "\n";
    cout << "To        : " << to_name   << "\n";
    cout << "Route     : " << route_no  << "\n";
    cout << "Trip Date : " << trip_date << "\n";
    cout << "Vehicle   : " << vehicle   << "\n";
    cout << "From Zone : " << from_zone << "\n";
    cout << "To Zone   : " << to_zone   << "\n";
    printf("Fare      : Rs. %.2f\n", fare_amt);
    cout << string(50, '=') << "\n";

    if (fare_amt == 0.0) {
        cout << "\nFare not found for this route combination.\n";
        cout << "Please contact the ticket counter.\n";
        pause_screen(); return;
    }

    // Step 8: Select payment mode
    cout << "\nPayment Mode:\n";
    cout << "  1. Cash\n";
    cout << "  2. UPI\n";
    cout << "  3. Smart Card\n";
    cout << "Choice: ";
    int pc; cin >> pc;
    const char *pmode = (pc==2) ? "UPI"        :
                        (pc==3) ? "Smart Card" : "Cash";
    const char *ttype = (pc==3) ? "Smart Card" : "Token";

    // Step 9: Confirm
    cout << "\nConfirm booking? (y/n): ";
    char confirm; cin >> confirm;
    if (confirm != 'y' && confirm != 'Y') {
        cout << "Booking cancelled.\n";
        pause_screen(); return;
    }

    // Step 10: Call stored procedure
    int booking_pid = (pid > 0) ? pid : 1;

    char query[512];
    snprintf(query, sizeof(query),
        "SELECT aguts.issue_ticket(%d, %d, '%s', "
        "%.2f, '%s', NULL)",
        booking_pid, trip_id, ttype, fare_amt, pmode);

    PGresult *res = PQexec(conn, query);
    if (PQresultStatus(res) == PGRES_TUPLES_OK) {
        cout << "\n" << string(50, '=') << "\n";
        cout << "        TICKET CONFIRMED!\n";
        cout << string(50, '=') << "\n";
        cout << "Transaction ID : "
             << PQgetvalue(res,0,0) << "\n";
        cout << "From           : " << from_name << "\n";
        cout << "To             : " << to_name   << "\n";
        printf("Amount Paid    : Rs. %.2f\n", fare_amt);
        cout << "Payment Mode   : " << pmode     << "\n";
        cout << "Trip Date      : " << trip_date << "\n";
        cout << "Vehicle        : " << vehicle   << "\n";
        cout << string(50, '=') << "\n";
    } else {
        cout << "Booking failed: "
             << PQerrorMessage(conn) << "\n";
    }
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// GUEST — FARE CALCULATOR
// ════════════════════════════════════════════════════════

void fare_calculator() {
    cout << "\n--- Fare Calculator ---\n\n";

    // Select operator
    PGresult *ops = PQexec(conn,
        "SELECT operator_id, operator_name "
        "FROM aguts.transit_operator ORDER BY operator_id");
    if (PQresultStatus(ops) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(ops); return;
    }
    cout << "Select Operator:\n";
    int nops = PQntuples(ops);
    for (int i = 0; i < nops; i++)
        printf("  %s. %s\n",
               PQgetvalue(ops,i,0), PQgetvalue(ops,i,1));
    PQclear(ops);
    cout << "Choice: ";
    int oid; cin >> oid;

    // FROM stop
    char qstops[512];
    snprintf(qstops, sizeof(qstops),
        "SELECT DISTINCT s.stop_id, s.stop_name "
        "FROM aguts.stop s "
        "JOIN aguts.route_stop rs ON rs.stop_id = s.stop_id "
        "JOIN aguts.route r ON r.route_id = rs.route_id "
        "WHERE r.operator_id = %d ORDER BY s.stop_id", oid);
    PGresult *stops = PQexec(conn, qstops);
    if (PQresultStatus(stops) != PGRES_TUPLES_OK) {
        PQclear(stops); return;
    }
    cout << "\nFROM Stop:\n";
    printf("%-6s %-35s\n", "ID", "Stop Name");
    cout << string(41, '-') << "\n";
    for (int i = 0; i < PQntuples(stops); i++)
        printf("%-6s %-35s\n",
               PQgetvalue(stops,i,0), PQgetvalue(stops,i,1));
    PQclear(stops);
    cout << "Choice: ";
    int from_stop; cin >> from_stop;

    // TO stop
    char qto[512];
    snprintf(qto, sizeof(qto),
        "SELECT DISTINCT s.stop_id, s.stop_name "
        "FROM aguts.stop s "
        "JOIN aguts.route_stop rs ON rs.stop_id = s.stop_id "
        "JOIN aguts.route r ON r.route_id = rs.route_id "
        "WHERE r.operator_id = %d AND s.stop_id != %d "
        "ORDER BY s.stop_id", oid, from_stop);
    PGresult *tos = PQexec(conn, qto);
    cout << "\nTO Stop:\n";
    printf("%-6s %-35s\n", "ID", "Stop Name");
    cout << string(41, '-') << "\n";
    for (int i = 0; i < PQntuples(tos); i++)
        printf("%-6s %-35s\n",
               PQgetvalue(tos,i,0), PQgetvalue(tos,i,1));
    PQclear(tos);
    cout << "Choice: ";
    int to_stop; cin >> to_stop;

    // Get route connecting both
    char qr[512];
    snprintf(qr, sizeof(qr),
        "SELECT route_id FROM aguts.route "
        "WHERE operator_id = %d "
        "AND route_id IN (SELECT route_id FROM aguts.route_stop "
        "                 WHERE stop_id = %d) "
        "AND route_id IN (SELECT route_id FROM aguts.route_stop "
        "                 WHERE stop_id = %d) LIMIT 1",
        oid, from_stop, to_stop);
    PGresult *rt = PQexec(conn, qr);
    if (PQresultStatus(rt) != PGRES_TUPLES_OK ||
        PQntuples(rt) == 0) {
        cout << "No route found connecting these stops.\n";
        PQclear(rt); pause_screen(); return;
    }
    int route_id = atoi(PQgetvalue(rt,0,0));
    PQclear(rt);

    // Get zones
    char qz1[256], qz2[256];
    snprintf(qz1, sizeof(qz1),
        "SELECT zone_id FROM aguts.route_stop "
        "WHERE route_id=%d AND stop_id=%d LIMIT 1",
        route_id, from_stop);
    snprintf(qz2, sizeof(qz2),
        "SELECT zone_id FROM aguts.route_stop "
        "WHERE route_id=%d AND stop_id=%d LIMIT 1",
        route_id, to_stop);
    PGresult *z1r = PQexec(conn, qz1);
    PGresult *z2r = PQexec(conn, qz2);

    if (PQresultStatus(z1r) != PGRES_TUPLES_OK ||
        PQntuples(z1r) == 0 ||
        PQresultStatus(z2r) != PGRES_TUPLES_OK ||
        PQntuples(z2r) == 0) {
        cout << "Zone information not available.\n";
        PQclear(z1r); PQclear(z2r);
        pause_screen(); return;
    }
    int z1 = atoi(PQgetvalue(z1r,0,0));
    int z2 = atoi(PQgetvalue(z2r,0,0));
    PQclear(z1r); PQclear(z2r);

    // Get stop names
    char qsn1[256], qsn2[256];
    snprintf(qsn1, sizeof(qsn1),
        "SELECT stop_name FROM aguts.stop WHERE stop_id=%d",
        from_stop);
    snprintf(qsn2, sizeof(qsn2),
        "SELECT stop_name FROM aguts.stop WHERE stop_id=%d",
        to_stop);
    PGresult *sn1 = PQexec(conn, qsn1);
    PGresult *sn2 = PQexec(conn, qsn2);
    string from_name = PQgetvalue(sn1,0,0);
    string to_name   = PQgetvalue(sn2,0,0);
    PQclear(sn1); PQclear(sn2);

    // Show all fares for all concession types
    char qfare[512];
    snprintf(qfare, sizeof(qfare),
        "SELECT f.concession_type, f.fare_amount, "
        "       fz1.zone_name, fz2.zone_name "
        "FROM   aguts.fare f "
        "JOIN   aguts.fare_zone fz1 "
        "       ON fz1.zone_id = f.from_zone_id "
        "JOIN   aguts.fare_zone fz2 "
        "       ON fz2.zone_id = f.to_zone_id "
        "WHERE  f.operator_id  = %d "
        "AND    f.from_zone_id = %d "
        "AND    f.to_zone_id   = %d "
        "ORDER  BY f.fare_amount DESC",
        oid, z1, z2);

    PGresult *fare = PQexec(conn, qfare);

    cout << "\n" << string(50, '=') << "\n";
    cout << "  FARE DETAILS\n";
    cout << string(50, '=') << "\n";
    cout << "From : " << from_name << "\n";
    cout << "To   : " << to_name   << "\n";
    cout << string(50, '-') << "\n";

    if (PQresultStatus(fare) == PGRES_TUPLES_OK &&
        PQntuples(fare) > 0) {
        printf("%-22s %-12s\n",
               "Concession Type", "Fare (Rs.)");
        cout << string(34, '-') << "\n";
        for (int i = 0; i < PQntuples(fare); i++)
            printf("%-22s Rs. %-8s\n",
                   PQgetvalue(fare,i,0),
                   PQgetvalue(fare,i,1));
    } else {
        cout << "Fare not available for this combination.\n";
    }
    cout << string(50, '=') << "\n";
    PQclear(fare);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// PASSENGER — BUY PASS
// ════════════════════════════════════════════════════════

void buy_pass(int pid) {
    cout << "\n--- Buy Pass ---\n\n";

    // Show operators
    PGresult *ops = PQexec(conn,
        "SELECT operator_id, operator_name "
        "FROM aguts.transit_operator ORDER BY operator_id");
    cout << "Select Operator:\n";
    for (int i = 0; i < PQntuples(ops); i++)
        printf("  %s. %s\n",
               PQgetvalue(ops,i,0), PQgetvalue(ops,i,1));
    PQclear(ops);
    cout << "Choice: ";
    int oid; cin >> oid;

    // Pass type
    cout << "\nPass Type:\n";
    cout << "  1. Weekly\n";
    cout << "  2. Monthly\n";
    cout << "Choice: ";
    int pt; cin >> pt;
    const char *ptype = (pt==2) ? "Monthly" : "Weekly";

    // Calculate dates and amount
    // Weekly = 7 days, Monthly = 30 days
    // Prices: Weekly=150, Monthly=600 (GMRC), 300 (AMTS/GSRTC), 100 (BRTS weekly)
    double amount = 0.0;
    if (pt == 1) amount = 100.0;  // Weekly
    else {
        if (oid == 1) amount = 600.0;       // GMRC Monthly
        else if (oid == 2) amount = 200.0;  // BRTS Monthly
        else if (oid == 3) amount = 300.0;  // AMTS Monthly
        else amount = 750.0;                // GSRTC Monthly
    }

    // Get next pass_id
    PGresult *rid = PQexec(conn,
        "SELECT COALESCE(MAX(pass_id),0)+1 "
        "FROM aguts.pass");
    int new_pid_pass = atoi(PQgetvalue(rid,0,0));
    PQclear(rid);

    // valid_from = today, valid_to = today + 7 or 30 days
    int days = (pt == 1) ? 7 : 30;

    cout << "\n" << string(40, '=') << "\n";
    cout << "  PASS SUMMARY\n";
    cout << string(40, '=') << "\n";
    printf("Type       : %s\n", ptype);
    printf("Valid For  : %d days from today\n", days);
    printf("Amount     : Rs. %.2f\n", amount);
    cout << string(40, '=') << "\n";

    cout << "\nConfirm purchase? (y/n): ";
    char confirm; cin >> confirm;
    if (confirm != 'y' && confirm != 'Y') {
        cout << "Cancelled.\n";
        pause_screen(); return;
    }

    char query[512];
    snprintf(query, sizeof(query),
        "INSERT INTO aguts.pass "
        "(pass_id, pass_type, valid_from, valid_to, "
        " amount_paid, passenger_id, operator_id) "
        "VALUES (%d, '%s', CURRENT_DATE, "
        "CURRENT_DATE + INTERVAL '%d days', "
        "%.2f, %d, %d)",
        new_pid_pass, ptype, days, amount, pid, oid);

    PGresult *res = PQexec(conn, query);
    if (PQresultStatus(res) == PGRES_COMMAND_OK) {
        cout << "\nPass purchased successfully!\n";
        cout << "Pass ID   : " << new_pid_pass << "\n";
        printf("Amount    : Rs. %.2f\n", amount);
        cout << "Valid for " << days << " days from today.\n";
    } else {
        cout << "Failed: " << PQerrorMessage(conn) << "\n";
    }
    PQclear(res);
    pause_screen();
}

// PASSENGER — VIEW MY PASSES
void view_my_passes(int pid) {
    cout << "\n--- My Passes ---\n\n";

    char query[512];
    snprintf(query, sizeof(query),
        "SELECT ps.pass_id, ps.pass_type, "
        "       TO_CHAR(ps.valid_from,'YYYY-MM-DD'), "
        "       TO_CHAR(ps.valid_to,'YYYY-MM-DD'), "
        "       ps.amount_paid, o.operator_name, "
        "       CASE WHEN ps.valid_to >= CURRENT_DATE "
        "            THEN 'Active' ELSE 'Expired' END, "
        "       GREATEST(0, ps.valid_to - CURRENT_DATE) "
        "FROM   aguts.pass ps "
        "JOIN   aguts.transit_operator o "
        "       ON o.operator_id = ps.operator_id "
        "WHERE  ps.passenger_id = %d "
        "ORDER  BY ps.valid_to DESC", pid);

    PGresult *res = PQexec(conn, query);
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    if (rows == 0) {
        cout << "You have no passes.\n";
        PQclear(res); pause_screen(); return;
    }

    printf("%-6s %-10s %-12s %-12s %-8s %-16s %-10s %-8s\n",
           "ID", "Type", "From", "To",
           "Amt", "Operator", "Status", "Days Left");
    cout << string(82, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-6s %-10s %-12s %-12s %-8s %-16s %-10s %-8s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3),
               PQgetvalue(res,i,4), PQgetvalue(res,i,5),
               PQgetvalue(res,i,6), PQgetvalue(res,i,7));
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// ADMIN — RESOLVE COMPLAINT
// ════════════════════════════════════════════════════════

void resolve_complaint() {
    cout << "\n--- Resolve a Complaint ---\n\n";

    // Show open and in-progress complaints
    PGresult *res = PQexec(conn,
        "SELECT c.complaint_id, c.category, c.status, "
        "       TO_CHAR(c.filed_date,'YYYY-MM-DD'), "
        "       p.first_name || ' ' || p.last_name, "
        "       LEFT(c.description,40) "
        "FROM   aguts.complaint c "
        "JOIN   aguts.passenger p "
        "       ON p.passenger_id = c.passenger_id "
        "WHERE  c.status IN ('Open','In Progress') "
        "ORDER  BY c.filed_date");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    if (rows == 0) {
        cout << "No open complaints.\n";
        PQclear(res); pause_screen(); return;
    }

    printf("%-5s %-18s %-14s %-12s %-22s %-40s\n",
           "ID", "Category", "Status",
           "Filed", "Passenger", "Description");
    cout << string(111, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-5s %-18s %-14s %-12s %-22s %-40s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3),
               PQgetvalue(res,i,4), PQgetvalue(res,i,5));
    PQclear(res);

    cout << "\nEnter Complaint ID to resolve (0 to cancel): ";
    int cid; cin >> cid;
    if (cid == 0) { pause_screen(); return; }

    // Call stored procedure
    char query[256];
    snprintf(query, sizeof(query),
        "SELECT aguts.resolve_complaint(%d)", cid);

    PGresult *r = PQexec(conn, query);
    if (PQresultStatus(r) == PGRES_TUPLES_OK ||
        PQresultStatus(r) == PGRES_COMMAND_OK) {
        cout << "\nComplaint " << cid
             << " resolved successfully!\n";
    } else {
        cout << "Failed: " << PQerrorMessage(conn) << "\n";
    }
    PQclear(r);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// ADMIN — Q54: REVENUE BY PAYMENT MODE
// ════════════════════════════════════════════════════════

void revenue_by_payment_mode() {
    cout << "\n--- Revenue by Payment Mode (Q54) ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT tt.payment_mode, "
        "       COUNT(tt.txn_id)  AS count, "
        "       SUM(tt.amount)    AS revenue "
        "FROM   aguts.ticket_transaction tt "
        "GROUP  BY tt.payment_mode "
        "ORDER  BY revenue DESC");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    printf("%-16s %-14s %-16s\n",
           "Payment Mode", "Transactions", "Revenue (Rs.)");
    cout << string(46, '-') << "\n";
    for (int i = 0; i < PQntuples(res); i++)
        printf("%-16s %-14s Rs. %-12s\n",
               PQgetvalue(res,i,0),
               PQgetvalue(res,i,1),
               PQgetvalue(res,i,2));
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// ADMIN — Q56: DAILY REVENUE TREND
// ════════════════════════════════════════════════════════

void daily_revenue_trend() {
    cout << "\n--- Daily Revenue Trend (Q56) ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT DATE(tt.txn_datetime) AS txn_date, "
        "       COUNT(tt.txn_id)      AS transactions, "
        "       SUM(tt.amount)        AS revenue "
        "FROM   aguts.ticket_transaction tt "
        "GROUP  BY DATE(tt.txn_datetime) "
        "ORDER  BY txn_date");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    if (rows == 0) {
        cout << "No transaction data.\n";
        PQclear(res); pause_screen(); return;
    }

    printf("%-14s %-14s %-16s\n",
           "Date", "Transactions", "Revenue (Rs.)");
    cout << string(44, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-14s %-14s Rs. %-12s\n",
               PQgetvalue(res,i,0),
               PQgetvalue(res,i,1),
               PQgetvalue(res,i,2));
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// ADMIN — Q101: CERTIFICATIONS EXPIRING IN 180 DAYS
// ════════════════════════════════════════════════════════

void expiring_certifications() {
    cout << "\n--- Certifications Expiring in 180 Days "
         << "(Q101) ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT s.first_name || ' ' || s.last_name, "
        "       s.role, o.operator_name, "
        "       sc.certification, "
        "       TO_CHAR(sc.expiry_date,'YYYY-MM-DD'), "
        "       sc.expiry_date - CURRENT_DATE AS days_left "
        "FROM   aguts.staff s "
        "JOIN   aguts.staff_certification sc "
        "       ON sc.staff_id = s.staff_id "
        "JOIN   aguts.transit_operator o "
        "       ON o.operator_id = s.operator_id "
        "WHERE  sc.expiry_date BETWEEN CURRENT_DATE "
        "       AND CURRENT_DATE + INTERVAL '180 days' "
        "ORDER  BY sc.expiry_date");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    if (rows == 0) {
        cout << "No certifications expiring in 180 days.\n";
        PQclear(res); pause_screen(); return;
    }

    printf("%-22s %-12s %-14s %-32s %-12s %-9s\n",
           "Staff Name", "Role", "Operator",
           "Certification", "Expiry", "Days Left");
    cout << string(101, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-22s %-12s %-14s %-32s %-12s %-9s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3),
               PQgetvalue(res,i,4), PQgetvalue(res,i,5));
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// ADMIN — Q42: TOP 10 FREQUENT TRAVELLERS
// ════════════════════════════════════════════════════════

void top_frequent_travellers() {
    cout << "\n--- Top 10 Frequent Travellers (Q42) ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT p.passenger_id, "
        "       p.first_name || ' ' || p.last_name, "
        "       p.concession_type, "
        "       COUNT(tt.txn_id)  AS total_trips, "
        "       SUM(tt.amount)    AS total_spent "
        "FROM   aguts.passenger p "
        "JOIN   aguts.ticket_transaction tt "
        "       ON tt.passenger_id = p.passenger_id "
        "GROUP  BY p.passenger_id, p.first_name, "
        "          p.last_name, p.concession_type "
        "ORDER  BY total_trips DESC "
        "LIMIT  10");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    printf("%-5s %-22s %-18s %-10s %-14s\n",
           "ID", "Passenger", "Concession",
           "Trips", "Total Spent");
    cout << string(69, '-') << "\n";
    for (int i = 0; i < PQntuples(res); i++)
        printf("%-5s %-22s %-18s %-10s Rs. %-10s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3),
               PQgetvalue(res,i,4));
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// ADMIN — Q24: ROUTES WITH MOST DELAYED TRIPS
// ════════════════════════════════════════════════════════

void routes_most_delays() {
    cout << "\n--- Routes with Most Delayed Trips (Q24) ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT r.route_number, r.route_name, "
        "       o.operator_name, "
        "       COUNT(t.trip_id) AS delayed_trips "
        "FROM   aguts.trip t "
        "JOIN   aguts.route r ON r.route_id = t.route_id "
        "JOIN   aguts.transit_operator o "
        "       ON o.operator_id = r.operator_id "
        "WHERE  t.trip_status = 'Delayed' "
        "GROUP  BY r.route_number, r.route_name, "
        "          o.operator_name "
        "ORDER  BY delayed_trips DESC");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    if (rows == 0) {
        cout << "No delayed trips found.\n";
        PQclear(res); pause_screen(); return;
    }

    printf("%-10s %-45s %-16s %-12s\n",
           "Route No", "Route Name", "Operator", "Delays");
    cout << string(83, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-10s %-45s %-16s %-12s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3));
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// ADMIN — Q62: REVENUE PER ROUTE
// ════════════════════════════════════════════════════════

void revenue_per_route() {
    cout << "\n--- Revenue per Route (Q62) ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT r.route_number, r.route_name, "
        "       o.operator_name, "
        "       COUNT(tt.txn_id) AS transactions, "
        "       SUM(tt.amount)   AS revenue "
        "FROM   aguts.ticket_transaction tt "
        "JOIN   aguts.trip t ON t.trip_id = tt.trip_id "
        "JOIN   aguts.route r ON r.route_id = t.route_id "
        "JOIN   aguts.transit_operator o "
        "       ON o.operator_id = r.operator_id "
        "GROUP  BY r.route_number, r.route_name, "
        "          o.operator_name "
        "ORDER  BY revenue DESC");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    printf("%-10s %-45s %-14s %-12s %-14s\n",
           "Route", "Route Name", "Operator",
           "Txns", "Revenue");
    cout << string(95, '-') << "\n";
    for (int i = 0; i < PQntuples(res); i++)
        printf("%-10s %-45s %-14s %-12s Rs. %-10s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3),
               PQgetvalue(res,i,4));
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// ADMIN — Q74: AC vs NON-AC BUS BREAKDOWN
// ════════════════════════════════════════════════════════

void ac_vs_nonac_fleet() {
    cout << "\n--- AC vs Non-AC Bus Breakdown (Q74) ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT o.operator_name, "
        "       CASE WHEN b.bus_type LIKE '%AC%' "
        "            AND b.bus_type NOT LIKE 'Non-AC%' "
        "            THEN 'AC' ELSE 'Non-AC' END AS ac_type, "
        "       COUNT(b.vehicle_id) AS count "
        "FROM   aguts.bus b "
        "JOIN   aguts.vehicle v ON v.vehicle_id = b.vehicle_id "
        "JOIN   aguts.transit_operator o "
        "       ON o.operator_id = v.operator_id "
        "GROUP  BY o.operator_name, ac_type "
        "ORDER  BY o.operator_name, ac_type");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    printf("%-22s %-10s %-8s\n",
           "Operator", "Type", "Count");
    cout << string(40, '-') << "\n";
    for (int i = 0; i < PQntuples(res); i++)
        printf("%-22s %-10s %-8s\n",
               PQgetvalue(res,i,0),
               PQgetvalue(res,i,1),
               PQgetvalue(res,i,2));
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// ADMIN — Q36: PASSENGERS WITH LOW SMART CARD BALANCE
// ════════════════════════════════════════════════════════

void low_balance_passengers() {
    cout << "\n--- Passengers with Low Balance "
         << "(<Rs.50) (Q36) ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT p.passenger_id, "
        "       p.first_name || ' ' || p.last_name, "
        "       p.concession_type, "
        "       sc.card_id, sc.balance, sc.card_status "
        "FROM   aguts.smart_card sc "
        "JOIN   aguts.passenger p "
        "       ON p.passenger_id = sc.passenger_id "
        "WHERE  sc.balance < 50 "
        "AND    sc.card_status NOT IN ('Blocked','Expired') "
        "ORDER  BY sc.balance");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    if (rows == 0) {
        cout << "No passengers with low balance.\n";
        PQclear(res); pause_screen(); return;
    }

    printf("%-5s %-22s %-18s %-8s %-10s %-12s\n",
           "ID", "Passenger", "Concession",
           "CardID", "Balance", "Status");
    cout << string(75, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-5s %-22s %-18s %-8s Rs.%-7s %-12s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3),
               PQgetvalue(res,i,4), PQgetvalue(res,i,5));
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// ADMIN — Q37: BLOCKED OR EXPIRED SMART CARDS
// ════════════════════════════════════════════════════════

void blocked_expired_cards() {
    cout << "\n--- Blocked / Expired Smart Cards "
         << "(Q37) ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT sc.card_id, sc.card_status, "
        "       p.first_name || ' ' || p.last_name, "
        "       sc.balance, "
        "       TO_CHAR(sc.issue_date,'YYYY-MM-DD'), "
        "       TO_CHAR(sc.expiry_date,'YYYY-MM-DD') "
        "FROM   aguts.smart_card sc "
        "JOIN   aguts.passenger p "
        "       ON p.passenger_id = sc.passenger_id "
        "WHERE  sc.card_status IN ('Blocked','Expired') "
        "ORDER  BY sc.expiry_date");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    if (rows == 0) {
        cout << "No blocked or expired cards.\n";
        PQclear(res); pause_screen(); return;
    }

    printf("%-8s %-12s %-22s %-10s %-12s %-12s\n",
           "CardID", "Status", "Passenger",
           "Balance", "Issued", "Expiry");
    cout << string(76, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-8s %-12s %-22s Rs.%-7s %-12s %-12s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3),
               PQgetvalue(res,i,4), PQgetvalue(res,i,5));
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// ADMIN — Q71: VEHICLES WITH MULTIPLE MAINTENANCE EVENTS
// ════════════════════════════════════════════════════════

void vehicles_multiple_maintenance() {
    cout << "\n--- Vehicles with Multiple Maintenance "
         << "Events (Q71) ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT v.registration_no, o.operator_name, "
        "       COUNT(m.maintenance_id) AS events, "
        "       SUM(m.end_date - m.start_date + 1) "
        "           AS total_downtime_days "
        "FROM   aguts.maintenance m "
        "JOIN   aguts.vehicle v ON v.vehicle_id = m.vehicle_id "
        "JOIN   aguts.transit_operator o "
        "       ON o.operator_id = v.operator_id "
        "GROUP  BY v.registration_no, o.operator_name "
        "HAVING COUNT(m.maintenance_id) > 1 "
        "ORDER  BY events DESC");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    printf("%-22s %-18s %-8s %-14s\n",
           "Vehicle", "Operator", "Events", "Downtime (days)");
    cout << string(62, '-') << "\n";
    for (int i = 0; i < PQntuples(res); i++)
        printf("%-22s %-18s %-8s %-14s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3));
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// ADMIN — Q72: VEHICLES UNDER MAINTENANCE
// ════════════════════════════════════════════════════════

void vehicles_under_maintenance() {
    cout << "\n--- Vehicles Under Maintenance (Q72) ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT v.vehicle_id, v.registration_no, "
        "       v.status, o.operator_name, d.depot_name, "
        "       v.manufacturer_name, v.manufacture_year "
        "FROM   aguts.vehicle v "
        "JOIN   aguts.transit_operator o "
        "       ON o.operator_id = v.operator_id "
        "JOIN   aguts.depot d ON d.depot_id = v.depot_id "
        "WHERE  v.status = 'Under Maintenance' "
        "ORDER  BY o.operator_name");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    int rows = PQntuples(res);
    if (rows == 0) {
        cout << "No vehicles currently under maintenance.\n";
        PQclear(res); pause_screen(); return;
    }

    printf("%-5s %-22s %-18s %-18s %-16s %-6s\n",
           "ID", "Registration", "Operator",
           "Depot", "Manufacturer", "Year");
    cout << string(85, '-') << "\n";
    for (int i = 0; i < rows; i++)
        printf("%-5s %-22s %-18s %-18s %-16s %-6s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,3), PQgetvalue(res,i,4),
               PQgetvalue(res,i,5), PQgetvalue(res,i,6));
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// ADMIN — Q77: METRO TRAINS PER LINE
// ════════════════════════════════════════════════════════

void metro_trains_per_line() {
    cout << "\n--- Metro Trains per Line (Q77) ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT ml.line_name, ml.line_code, "
        "       mt.rake_number, mt.num_coaches, "
        "       v.registration_no, "
        "       v.manufacture_year, v.manufacturer_name, "
        "       d.depot_name "
        "FROM   aguts.metro_train mt "
        "JOIN   aguts.vehicle v ON v.vehicle_id = mt.vehicle_id "
        "JOIN   aguts.depot d ON d.depot_id = v.depot_id "
        "JOIN   aguts.route r ON r.operator_id = v.operator_id "
        "       AND r.line_id IS NOT NULL "
        "JOIN   aguts.metro_line ml ON ml.line_id = r.line_id "
        "GROUP  BY ml.line_name, ml.line_code, "
        "          mt.rake_number, mt.num_coaches, "
        "          v.registration_no, v.manufacture_year, "
        "          v.manufacturer_name, d.depot_name "
        "ORDER  BY ml.line_name, mt.rake_number");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    printf("%-14s %-6s %-12s %-8s %-20s %-6s %-12s %-20s\n",
           "Line", "Code", "Rake No",
           "Coaches", "Registration", "Year",
           "Maker", "Depot");
    cout << string(98, '-') << "\n";
    for (int i = 0; i < PQntuples(res); i++)
        printf("%-14s %-6s %-12s %-8s %-20s %-6s %-12s %-20s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3),
               PQgetvalue(res,i,4), PQgetvalue(res,i,5),
               PQgetvalue(res,i,6), PQgetvalue(res,i,7));
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// ADMIN — Q85: METRO vs BUS TOTAL CAPACITY
// ════════════════════════════════════════════════════════

void metro_vs_bus_capacity() {
    cout << "\n--- Metro vs Bus Total Capacity (Q85) ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT "
        "  SUM(CASE WHEN mt.vehicle_id IS NOT NULL "
        "           THEN v.capacity ELSE 0 END) AS metro_cap, "
        "  SUM(CASE WHEN b.vehicle_id IS NOT NULL "
        "           THEN v.capacity ELSE 0 END) AS bus_cap, "
        "  COUNT(CASE WHEN mt.vehicle_id IS NOT NULL "
        "             THEN 1 END) AS metro_count, "
        "  COUNT(CASE WHEN b.vehicle_id IS NOT NULL "
        "             THEN 1 END) AS bus_count "
        "FROM aguts.vehicle v "
        "LEFT JOIN aguts.metro_train mt "
        "          ON mt.vehicle_id = v.vehicle_id "
        "LEFT JOIN aguts.bus b ON b.vehicle_id = v.vehicle_id");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    cout << "\n" << string(40, '=') << "\n";
    cout << "  FLEET CAPACITY COMPARISON\n";
    cout << string(40, '=') << "\n";
    printf("%-20s %-10s %-12s\n",
           "Type", "Vehicles", "Total Capacity");
    cout << string(42, '-') << "\n";
    printf("%-20s %-10s %-12s\n",
           "Metro Trains",
           PQgetvalue(res,0,2),
           PQgetvalue(res,0,0));
    printf("%-20s %-10s %-12s\n",
           "Buses",
           PQgetvalue(res,0,3),
           PQgetvalue(res,0,1));
    cout << string(40, '=') << "\n";
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// ADMIN — Q89: MOTORMEN WITH LICENSE AND TRIP COUNT
// ════════════════════════════════════════════════════════

void motormen_details() {
    cout << "\n--- Motormen with License & Trips (Q89) ---\n\n";

    PGresult *res = PQexec(conn,
        "SELECT s.first_name || ' ' || s.last_name, "
        "       mm.metro_license_no, "
        "       o.operator_name, "
        "       COUNT(t.trip_id) AS trips_operated "
        "FROM   aguts.staff s "
        "JOIN   aguts.motorman mm ON mm.staff_id = s.staff_id "
        "JOIN   aguts.transit_operator o "
        "       ON o.operator_id = s.operator_id "
        "LEFT JOIN aguts.trip t ON t.staff_id = s.staff_id "
        "GROUP  BY s.first_name, s.last_name, "
        "          mm.metro_license_no, o.operator_name "
        "ORDER  BY trips_operated DESC");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Query failed: " << PQerrorMessage(conn) << "\n";
        PQclear(res); return;
    }

    printf("%-22s %-18s %-14s %-12s\n",
           "Motorman", "Metro License", "Operator", "Trips");
    cout << string(66, '-') << "\n";
    for (int i = 0; i < PQntuples(res); i++)
        printf("%-22s %-18s %-14s %-12s\n",
               PQgetvalue(res,i,0), PQgetvalue(res,i,1),
               PQgetvalue(res,i,2), PQgetvalue(res,i,3));
    PQclear(res);
    pause_screen();
}

// ════════════════════════════════════════════════════════
// MAIN
// ════════════════════════════════════════════════════════

int main() {
    if (!db_connect()) return 1;

    while (true) {
        cout << "\n========================================\n";
        cout << "   AGUTS — Ahmedabad Gandhinagar\n";
        cout << "   Unified Transit System\n";
        cout << "========================================\n";
        cout << "  1. Guest (no login)\n";
        cout << "  2. Login\n";
        cout << "  0. Exit\n";
        cout << "========================================\n";
        cout << "Choice: ";

        char ch; cin >> ch;

        if (ch == '0') {
            db_disconnect();
            cout << "Goodbye!\n";
            return 0;
        }

            if (ch == '1') {
    char sub;
    while (true) {
        cout << "\n--- Guest Menu ---\n";
        cout << "  1. View all operators\n";
        cout << "  2. View stops on a route\n";
        cout << "  3. View interchange points\n";
        cout << "  4. Fare calculator\n";
        cout << "  5. Register as Passenger\n";
        cout << "  6. Request Staff Registration\n";
        cout << "  7. Book a ticket (as guest)\n";
        cout << "  0. Back\n";
        cout << "Choice: "; cin >> sub;
        if      (sub=='1') show_operators();
        else if (sub=='2') show_route_stops();
        else if (sub=='3') show_interchanges();
        else if (sub=='4') fare_calculator();
        else if (sub=='5') register_passenger();
        else if (sub=='6') request_staff_registration();
        else if (sub=='7') book_ticket(-1);
        else if (sub=='0') break;
        else cout << "Invalid choice.\n";
    }
    continue;
}

        if (ch == '2') {
            int ref_id = -1;
            string role = login(ref_id);
            if (role.empty()) continue;

            if (role == "admin") {
                // Admin menu
                char sub;
                while (true) {
                    cout << "\n--- Admin Menu ---\n";
                    cout << "  A. Network & Infrastructure\n";
                    cout << "  B. Trip Operations\n";
                    cout << "  C. Passenger Reports\n";
                    cout << "  D. Ticketing & Revenue\n";
                    cout << "  E. Fleet & Maintenance\n";
                    cout << "  F. Staff & Complaints\n";
                    cout << "  0. Logout\n";
                    cout << "Choice: "; cin >> sub;

                    if (sub == '0') break;
                    else if (sub=='A'||sub=='a') {
                        char s2;
                        while (true) {
                            cout << "\n--- Network ---\n";
                            cout << "  1. View all operators\n";
                            cout << "  2. View stops on route\n";
                            cout << "  3. View interchanges\n";
                            cout << "  0. Back\n";
                            cout << "Choice: "; cin >> s2;
                            if      (s2=='1') show_operators();
                            else if (s2=='2') show_route_stops();
                            else if (s2=='3') show_interchanges();
                            else if (s2=='0') break;
                        }
                    }
                    else if (sub=='B'||sub=='b') {
                        char s2;
                        while (true) {
                            cout << "\n--- Trip Operations ---\n";
                            cout << "  1. Trips by date\n";
                            cout << "  2. Delayed trips\n";
                            cout << "  3. OTP by operator\n";
                            cout << "  0. Back\n";
                            cout << "Choice: "; cin >> s2;
                            if      (s2=='1') view_trips_by_date();
                            else if (s2=='2') view_delayed_trips();
                            else if (s2=='3') view_otp();
                            else if (s2=='0') break;
                        }
                    }
                    else if (sub=='C'||sub=='c') {
                    char s2;
                    while (true) {
                        cout << "\n--- Passenger Reports ---\n";
                        cout << "  1. Smart card balance lookup\n";
                        cout << "  2. Travel history lookup\n";
                        cout << "  3. Register passenger\n";
                        cout << "  4. Top 10 frequent travellers\n";
                        cout << "  5. Low balance passengers\n";
                        cout << "  6. Blocked/expired smart cards\n";
                        cout << "  0. Back\n";
                        cout << "Choice: "; cin >> s2;
                        if      (s2=='1') check_smart_card();
                        else if (s2=='2') view_travel_history();
                        else if (s2=='3') register_passenger();
                        else if (s2=='4') top_frequent_travellers();
                        else if (s2=='5') low_balance_passengers();
                        else if (s2=='6') blocked_expired_cards();
                        else if (s2=='0') break;
                    }
                }
                    else if (sub=='D'||sub=='d') {
    char s2;
    while (true) {
        cout << "\n--- Ticketing & Revenue ---\n";
        cout << "  1. Revenue by operator\n";
        cout << "  2. Issue ticket\n";
        cout << "  3. Revenue by payment mode\n";
        cout << "  4. Daily revenue trend\n";
        cout << "  5. Revenue per route\n";
        cout << "  6. Routes with most delays\n";
        cout << "  0. Back\n";
        cout << "Choice: "; cin >> s2;
        if      (s2=='1') view_revenue();
        else if (s2=='2') issue_ticket();
        else if (s2=='3') revenue_by_payment_mode();
        else if (s2=='4') daily_revenue_trend();
        else if (s2=='5') revenue_per_route();
        else if (s2=='6') routes_most_delays();
        else if (s2=='0') break;
    }
}
                    else if (sub=='E'||sub=='e') {
    char s2;
    while (true) {
        cout << "\n--- Fleet & Maintenance ---\n";
        cout << "  1. Fleet status summary\n";
        cout << "  2. Maintenance history\n";
        cout << "  3. Idle vehicles\n";
        cout << "  4. Vehicles under maintenance\n";
        cout << "  5. Vehicles with multiple maintenance\n";
        cout << "  6. Metro trains per line\n";
        cout << "  7. AC vs Non-AC breakdown\n";
        cout << "  8. Metro vs Bus capacity\n";
        cout << "  0. Back\n";
        cout << "Choice: "; cin >> s2;
        if      (s2=='1') view_fleet_status();
        else if (s2=='2') view_maintenance();
        else if (s2=='3') view_idle_vehicles();
        else if (s2=='4') vehicles_under_maintenance();
        else if (s2=='5') vehicles_multiple_maintenance();
        else if (s2=='6') metro_trains_per_line();
        else if (s2=='7') ac_vs_nonac_fleet();
        else if (s2=='8') metro_vs_bus_capacity();
        else if (s2=='0') break;
    }
}
                   else if (sub=='F'||sub=='f') {
    char s2;
    while (true) {
        cout << "\n--- Staff & Complaints ---\n";
        cout << "  1. View all staff\n";
        cout << "  2. View all complaints\n";
        cout << "  3. Staff performance\n";
        cout << "  4. Approve staff requests\n";
        cout << "  5. Resolve complaint\n";
        cout << "  6. Expiring certifications\n";
        cout << "  7. Motormen details\n";
        cout << "  0. Back\n";
        cout << "Choice: "; cin >> s2;
        if      (s2=='1') view_staff();
        else if (s2=='2') view_complaints();
        else if (s2=='3') view_staff_performance();
        else if (s2=='4') approve_staff_requests();
        else if (s2=='5') resolve_complaint();
        else if (s2=='6') expiring_certifications();
        else if (s2=='7') motormen_details();
        else if (s2=='0') break;
    }
}
                }
            }

            else if (role == "passenger") {
    char sub;
    while (true) {
        cout << "\n--- Passenger Menu ---\n";
        cout << "  1. My smart card balance\n";
        cout << "  2. My travel history\n";
        cout << "  3. Book a ticket\n";
        cout << "  4. File a complaint\n";
        cout << "  5. My complaints\n";
        cout << "  6. Recharge smart card\n";
        cout << "  7. Buy a pass\n";
        cout << "  8. My passes\n";
        cout << "  0. Logout\n";
        cout << "Choice: "; cin >> sub;
        if      (sub=='1') check_smart_card_by_id(ref_id);
        else if (sub=='2') view_travel_history_by_id(ref_id);
        else if (sub=='3') book_ticket(ref_id);
        else if (sub=='4') file_complaint_by_id(ref_id);
        else if (sub=='5') view_my_complaints(ref_id);
        else if (sub=='6') recharge_smart_card(ref_id);
        else if (sub=='7') buy_pass(ref_id);
        else if (sub=='8') view_my_passes(ref_id);
        else if (sub=='0') break;
        else cout << "Invalid choice.\n";
    }
}

                else if (role == "staff") {
                char sub;
                while (true) {
                    cout << "\n--- Staff Menu ---\n";
                    cout << "  1. My assigned trips\n";
                    cout << "  2. My certifications\n";
                    cout << "  0. Logout\n";
                    cout << "Choice: "; cin >> sub;
                    if      (sub=='1') my_trips(ref_id);
                    else if (sub=='2') my_certifications(ref_id);
                    else if (sub=='0') break;
                    else cout << "Invalid choice.\n";
                }
            }
        }
    }
}