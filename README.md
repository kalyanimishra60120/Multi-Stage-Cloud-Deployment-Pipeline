## Cloud Deployment Pipeline (Staging + Production Auto-Deploy on AWS EC2)
This project demonstrates a real-world CI/CD pipeline using GitLab, AWS EC2, secure SSH-based deployments, and environment-specific application behavior (Staging vs Production).

## The pipeline automatically:
1.Builds
2.Runs tests (PyTest)
3.Deploys automatically to STAGING (port 5000)
4.Deploys manually to PRODUCTION (port 8080)
  A lightweight Flask app is deployed on both environments with clearly separated configurations.

## Project Structure
cloud-deployment-pipeline/
│
├── app/
│   ├── main.py
│   └── templates/
│       └── index.html
│
├── tests/
│   └── test_app.py
│
├── deploy_staging.sh
├── deploy_prod.sh
├── requirements.txt
└── .gitlab-ci.yml

## Application Behavior
     Staging
Port: 5000
ENV variable: APP_ENV=staging
URL example:
http://<EC2-IPv4>:5000/
Output:
Hello from Staging environment!

    Production
Port: 8080
ENV variable: APP_ENV=production
URL example:
http://<EC2-IPv4>:8080/
Output:
Hello from Production environment!

## Flask App (main.py)
Supports dynamic port:
port = int(os.getenv("APP_PORT", "0"))
if port == 0 and "--port" in sys.argv:
    port = int(sys.argv[sys.argv.index("--port") + 1])
if port == 0:
    port = 5000

## GitLab CI/CD Pipeline (.gitlab-ci.yml)
## Key stages:
build → test → deploy_staging → deploy_production
---------- deploy_staging-------------
Runs automatically on every push to main.
-----------deploy_production-------------
Manual trigger (safe for production releases).
Pipeline also:
-Installs dependencies
-Loads private SSH key from GitLab CI variables
-Runs deployment scripts
-Tests before deploying

## Deployment Scripts
--deploy_staging.sh
Adds private key inside EC2
Git clones/updates repo
Installs requirements
Starts Flask on 5000
--deploy_prod.sh
Same flow, but:
Starts on 8080
APP_ENV=production APP_PORT=8080
--AWS Setup
EC2 Instance
AMI - Ubuntu 22.04
Open inbound ports:22 (SSH) , 5000 (Staging) , 8080 (Production)
--Network ACL Rules
Allow inbound + outbound for:5000 , 8080

## How to Trigger Deployments
Staging (Auto)
Push to main branch → staging deploys automatically.
Production (Manual)
In GitLab → Pipelines → Deploy Production → Run.

--Testing
pytest validates the health endpoint:
response = client.get("/health")
assert response.json["status"] == "ok"
If tests fail → no deployment happens.

## Once deployed 
Staging:
http://<EC2_PUBLIC_IP>:5000

Production:
http://<EC2_PUBLIC_IP>:8080

## Author
Kalyani Mishra

