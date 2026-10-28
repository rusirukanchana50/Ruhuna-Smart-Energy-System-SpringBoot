# Faculty of Engineering, University of Ruhuna
## Deployment Guide: Render & MongoDB Atlas Cloud Architecture

This guide describes how to deploy the **Ruhuna Smart Energy Monitoring and Analytics System** (Spring Boot 3.3.5 + MongoDB 7.0) to **Render** as a containerized web service connecting to **MongoDB Atlas**.

---

## 1. Architectural Overview

```
                                      +------------------------------------+
                                      |         Render Web Service         |
                                      |  (Spring Boot 3.3.5 / Java 21)     |
                                      |                                    |
[ User Browser ] â”€â”€HTTPS (Single)â”€â”€â”€> |  - /login, /dashboard, /reports... |
                                      |  - Embedded HTML/CSS/JS Assets     |
                                      |  - REST APIs & Security Filters    |
                                      |  - 3-Phase Electrical Simulator    |
                                      +-----------------+------------------+
                                                        |
                                            TLS / Encrypted URI
                                                        |
                                                        v
                                      +-----------------+------------------+
                                      |       MongoDB Atlas Cloud          |
                                      |   Database: ruhuna_energy_cloud    |
                                      |   - buildings, energy_readings     |
                                      |   - electrical_alerts, users...    |
                                      +------------------------------------+
```

* **Zero Frontend/Backend Disconnect**: Frontend assets (`frontend/`) are compiled directly into the Spring Boot executable JAR at build time. Everything serves from the same domain with native `JSESSIONID` cookies and CSRF protection.
* **Database Isolation**: The cloud database (`ruhuna_energy_cloud`) is 100% distinct from local development (`ruhuna_energy_spring`) and legacy databases (`ruhuna_energy`).

---

## 2. Step 1: Provision MongoDB Atlas Cloud Database

1. Sign in to your [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) account.
2. Create a new cluster (e.g. Free Tier **M0 Sandbox** in AWS or Google Cloud).
3. Under **Security > Database Access**:
   * Click **Add New Database User**.
   * Authentication Method: **Password**.
   * Set a strong password (e.g., `CloudDbAdmin2026!`).
   * Database User Privileges: `Read and write to any database`.
4. Under **Security > Network Access**:
   * Click **Add IP Address**.
   * Select **Allow Access from Anywhere** (`0.0.0.0/0`) because Render utilizes dynamic cloud IP pools.
5. Under **Database > Clusters**:
   * Click **Connect** $\rightarrow$ **Drivers** (Java 4.3 or later).
   * Copy the connection string format:
     ```
     mongodb+srv://<username>:<password>@cluster0.xxxx.mongodb.net/ruhuna_energy_cloud?retryWrites=true&w=majority
     ```
   * Replace `<username>` and `<password>` with your credentials, and ensure the target database path is `/ruhuna_energy_cloud`.

---

## 3. Step 2: Create Render Web Service

1. Sign in to [Render](https://dashboard.render.com).
2. Click **New +** $\rightarrow$ **Web Service**.
3. Select **Build and deploy from a Git repository**.
4. Connect your GitHub repository:
   * URL: `https://github.com/rusirukanchana50/Ruhuna-Smart-Energy-System-SpringBoot.git`
5. Configure the service settings:
   * **Name**: `ruhuna-smart-energy-system` (or your preferred service name)
   * **Region**: Nearest to your users (e.g., *Singapore* or *Frankfurt*)
   * **Branch**: `main`
   * **Runtime**: **Docker** *(Render will automatically detect the root `Dockerfile`)*
   * **Instance Type**: **Free**

---

## 4. Step 3: Configure Environment Variables

Under the **Environment** tab on Render, add the following environment variables:

| Variable Name | Example / Recommended Value | Description |
| :--- | :--- | :--- |
| `SPRING_DATA_MONGODB_URI` | `mongodb+srv://dbuser:pass@cluster.mongodb.net/ruhuna_energy_cloud?retryWrites=true&w=majority` | Full MongoDB Atlas connection URI with credentials |
| `APP_INIT_CORE_BUILDINGS` | `true` | Automatically provisions the 6 canonical campus buildings on first startup |
| `APP_DEV_ADMIN_PASSWORD` | `YourSecureAdminPassword123!` | Initial password for `admin@eng.ruh.ac.lk` (Administrator role) |
| `APP_DEV_VIEWER_PASSWORD` | `YourSecureViewerPassword123!` | Initial password for `viewer@eng.ruh.ac.lk` (Viewer role) |
| `SIMULATOR_ENABLED` | `true` | Enables automatic continuous 3-phase telemetry generation (every 15s) |
| `COOKIE_SECURE` | `true` | Enforces `Secure` flag on `JSESSIONID` cookies over Render's HTTPS |

> [!NOTE]
> Render automatically injects the `PORT` environment variable (e.g., `PORT=10000`). Spring Boot binds to `0.0.0.0:${PORT}` automatically.

---

## 5. Step 4: Configure Health Check Path

In the Render Web Service settings under **Advanced**:
* **Health Check Path**: `/api/health`

Render will poll `/api/health` during deployment to verify container health before routing traffic to the new instance.

---

## 6. Step 5: Deploy & Verification Checklist

1. Click **Create Web Service**. Render will execute the multi-stage build:
   * Compiles Java 21 backend and packages frontend assets with Maven.
   * Creates a minimal, secure `eclipse-temurin:21-jre-jammy` container running as non-root user `spring`.
2. Once the deploy status reports **Live**, navigate to `https://<your-service>.onrender.com/login`:
   * **Health Check**: Visit `https://<your-service>.onrender.com/api/health` and verify `status: "UP"`, with masked `mongoUri` (`mongodb+srv://****:****@...`).
   * **Authentication**: Log in with `admin@eng.ruh.ac.lk` and your configured `APP_DEV_ADMIN_PASSWORD`.
   * **Live Telemetry**: Verify active power gauges on the Dashboard updating via the 15-second simulation cycles.
   * **Analytics & Alerts**: Confirm charts, electrical alert tables, and department cost rankings function correctly.
   * **Audit Reports**: Test generating an energy audit report, downloading the RFC 4180 CSV, and opening the printable PDF audit.

---

## 7. Render Free Tier Considerations

* **Spin-Down on Idle**: Render's free tier services automatically spin down after 15 minutes of inactivity. When a new request arrives, wakeup takes approximately 30â€“50 seconds.
* **Persistent Data**: Because data is stored in **MongoDB Atlas** rather than local container storage, all campus buildings, readings, and alerts are fully preserved across spin-downs and container restarts.
