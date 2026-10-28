# Faculty of Engineering, University of Ruhuna
## Smart Energy Monitoring and Analytics System (Spring Boot + MongoDB)

An enterprise-grade campus energy monitoring, power quality analysis, electrical anomaly detection, and energy audit reporting platform designed for the **Faculty of Engineering, University of Ruhuna**, Hapugala, Galle, Sri Lanka.

Built with **Java 25**, **Spring Boot 3.3.5**, **MongoDB 7.0**, and clean, high-performance vanilla web technologies.

---

## 1. System Architecture & Technology Stack

* **Backend Framework**: Java 25 & Spring Boot 3.3.5
  * **Spring Security 6**: Session-based authentication with `JSESSIONID`, Role-Based Access Control (`Administrator` / `Viewer`), and double-submit `X-CSRF-TOKEN` protection.
  * **Spring Data MongoDB**: High-throughput document mapping, aggregation pipelines, and schema-safe persistence.
  * **Spring Scheduling**: Non-overlapping, thread-safe background execution coordinating electrical simulation cycles.
* **Database**: MongoDB 7.0 Community Edition
  * Strict schema validation, compound indices on timestamps and building references, and collection isolation (`ruhuna_energy_spring`).
* **Frontend Architecture**: Pure Semantic HTML5, Modular CSS3 Dark Theme, and Vanilla JavaScript (ES6+)
  * Zero heavyweight framework dependencies (no React/Angular/Vue bloat).
  * Fast page rendering, zero static-asset bypass vulnerabilities, and responsive desktop/tablet layouts.
* **Telemetry Simulator**: Three-Phase Electrical Simulator
  * Physics-grounded three-phase AC power calculations: active power ($P$), apparent power ($S$), reactive power ($Q$), line voltage ($V_L$), phase current ($I_L$), and power factor ($\cos\phi$).
  * Asia/Colombo (`UTC+05:30`) time-of-day operational curves (academic hours vs. night standby).

---

## 2. Core Application Modules

The system provides five dedicated functional sections accessible via authenticated navigation:

### 1. Live Telemetry Monitoring (`/dashboard`)
* Real-time campus-wide electrical overview across all Faculty of Engineering facilities:
  * **CEE**: Civil and Environmental Engineering
  * **EIE**: Electrical and Information Engineering
  * **MME**: Mechanical and Manufacturing Engineering
  * **MENA**: Marine Engineering and Naval Architecture
  * **ADMIN**: Faculty Administration Building
  * **AUDI**: Faculty Auditorium
* Live active power gauges, dynamic load factor calculations, power factor health indicators, and phase voltage stability monitoring.
* Full Administrator Building Management: Add new facility meters, update transformer ratings, and perform simulated building deletions.

### 2. Historical Energy Analytics (`/analytics`)
* Multi-range time series visualization (Today, 24 Hours, 7 Days, 30 Days, 90 Days, 1 Year, and Custom Date Ranges).
* Aggregated cumulative energy ($E$ in kWh), peak active demand ($P_{peak}$ in kW), average apparent power ($S_{avg}$ in kVA), and average power factor ($PF_{avg}$).
* Cross-departmental comparative charts and diurnal consumption profiles.

### 3. Electrical Alerts & Anomaly Detection (`/alerts`)
* Automated power quality inspection evaluating incoming telemetry against IEEE/IEC standards:
  * **Voltage Sags & Swells**: Detection of phase voltage deviations outside nominal limits ($400\text{ V} \pm 6\%$).
  * **Low Power Factor**: Identification of reactive power penalties ($PF < 0.85$).
  * **Building Overload**: Alerts triggered when demand exceeds transformer rated capacity ($P > P_{rated}$).
  * **Abnormal Off-Peak Consumption**: Detection of unauthorized baseline loads during after-hours.
* Automated alert lifecycle: Deduplication guard prevents redundant rows while conditions persist; automatic timestamped clearing when readings normalize.
* Role-enforced alert acknowledgment for Faculty Administrators.

### 4. Cost & Efficiency Analysis (`/cost-efficiency`)
* Institutional demonstration tariff engine computing three-part billing breakdowns:
  * **Energy Charge**: Pro-rated kWh consumption charge.
  * **Maximum Demand Charge**: Peak active demand charge (kVA/kW) scaled to billing period.
  * **Fixed Customer Charge**: Pro-rated monthly service fee.
* Working-Hours ($08:00\text{--}17:00$) vs. After-Hours/Weekend energy split analysis.
* Faculty departmental efficiency rankings (#1 to #6) based on energy intensity ($\text{kWh}/\text{m}^2$) and power factor discipline.

### 5. Energy Audit Reports & Exports (`/reports` & `/reports/printable`)
* **16-Metric Audit Summary**: Energy total, peak/avg/min active power, apparent power, reactive power, power factor distribution, voltage stability bounds, frequency, load factor, and estimated billing costs.
* **Campus Breakdown Table**: Per-building breakdown with active meters, energy shares, and peak demand timestamps.
* **RFC 4180 CSV Export**: Complete 14-column telemetry dataset download (`ruhuna_energy_telemetry_<building>.csv`) supporting up to 50,000 records.
* **Printable Energy Audit Report (`/reports/printable`)**: Clean, publication-ready audit document designed for browser **Save as PDF** or physical printing with University of Ruhuna crest, metadata header, KPI summary matrix, and signature blocks.

---

## 3. Security, Authentication & RBAC

* **Role-Based Access Control**:
  * **Administrator**: Full privileges to mutate facility records, acknowledge electrical alerts, modify tariff parameters, and generate reports.
  * **Viewer**: Read-only access across all monitoring dashboards, analytics, alerts, cost views, and reports.
* **Session Management**: Secure HTTP-only cookies (`JSESSIONID`) with 30-minute inactivity timeouts and `SameSite=Lax` controls.
* **CSRF Protection**: Synchronizer Token Pattern enforced on all state-changing `POST`, `PUT`, and `DELETE` requests via custom header `X-CSRF-TOKEN`.
* **Static Asset Bypass Defense**: Direct unauthorized access to internal `.html` files in `/static/` is strictly intercepted by Spring Security and redirected to `/login`.
* **Zero Secret Commitment**: No passwords, private keys, or API tokens are hardcoded into version control.

---

## 4. Prerequisites

* **Java Development Kit (JDK)**: Java 25 (or Java 21 LTS) installed and configured on your system `PATH`.
* **MongoDB**: MongoDB 7.0 Community Edition listening locally or over network.
* **Build Tool**: Apache Maven 3.9+ (or use the bundled `mvnw` / `mvnw.cmd` wrapper).

---

## 5. Local Setup & Startup Guide

### Step 1: Start MongoDB 7.0
Start a MongoDB 7 instance on port `27018` (or default port `27017`):
```powershell
mongod --port 27018 --dbpath "D:\MongoDB7\data" --bind_ip 127.0.0.1
```

### Step 2: Configure Environment Variables
Set your local environment configuration:
```powershell
# Point to Java 25
$env:JAVA_HOME = "C:\Program Files\Java\jdk-25"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

# Optional: Set initial development account passwords for first-time provisioning
$env:APP_DEV_ADMIN_PASSWORD = "YourSecureAdminPassword"
$env:APP_DEV_VIEWER_PASSWORD = "YourSecureViewerPassword"

# Enable the Three-Phase Energy Simulator (optional for live data generation)
$env:SIMULATOR_ENABLED = "true"
```

*(On Linux / macOS bash)*:
```bash
export JAVA_HOME="/usr/lib/jvm/java-25"
export PATH="$JAVA_HOME/bin:$PATH"
export APP_DEV_ADMIN_PASSWORD="YourSecureAdminPassword"
export APP_DEV_VIEWER_PASSWORD="YourSecureViewerPassword"
export SIMULATOR_ENABLED="true"
```

### Step 3: Run the Spring Boot Application
Navigate to the `spring_backend` directory and run using the Maven wrapper:
```powershell
cd spring_backend
.\mvnw.cmd spring-boot:run
```

*(On Linux / macOS)*:
```bash
cd spring_backend
./mvnw spring-boot:run
```

The application will start on **`http://localhost:5001`**.

---

## 6. Application Configuration Reference

Configuration properties are located in [`spring_backend/src/main/resources/application.properties`](file:///spring_backend/src/main/resources/application.properties):

| Property | Default Value | Description |
| :--- | :--- | :--- |
| `server.port` | `5001` | HTTP web server port |
| `spring.data.mongodb.uri` | `mongodb://127.0.0.1:27018/ruhuna_energy_spring` | MongoDB connection URI |
| `server.servlet.session.timeout` | `30m` | Session expiration duration |
| `simulator.enabled` | `false` | Automatic simulation scheduler toggle (`true`/`false`) |
| `simulator.interval.ms` | `15000` | Telemetry cycle interval (15 seconds) |
| `simulator.initial-delay.ms` | `5000` | Simulator boot delay (5 seconds) |

---

## 7. Automated Test Suite

The project includes an extensive suite of **35+ automated Spring Boot integration tests** covering controllers, services, repositories, security rules, and page rendering.

To execute all tests using an isolated test database:
```powershell
cd spring_backend
.\mvnw.cmd test
```

---

## 8. Disclaimers

### Academic Prototype Disclaimer
This system has been developed as an academic engineering project (**EE4207: Smart Energy Systems**) for the Faculty of Engineering, University of Ruhuna, Sri Lanka. It serves as an advanced functional prototype demonstrating modern IoT energy architecture, three-phase telemetry analysis, and enterprise software engineering principles.

### Demonstration Tariff Disclaimer
All electricity billing estimates, demand charges, fixed charges, and cost calculations generated by the system utilize a configurable demonstration model based on Sri Lankan industrial/institutional tariff structures. **These calculations are intended strictly for academic study and energy conservation estimation and do NOT constitute an official bill from the Ceylon Electricity Board (CEB) or LECO.**

---

## 9. License

This project is licensed under the MIT License — see the repository for details.

Developed for the **Department of Electrical and Information Engineering**, Faculty of Engineering, University of Ruhuna.
