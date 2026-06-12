\# DevSecOps Secure Deployment on Google Cloud



\## Overview

This project demonstrates a secure CI/CD pipeline for deploying a containerized Node.js application on Google Cloud Run using Terraform and DevSecOps principles.



\---



\## Live Application

https://devops-node-app-687812793546.asia-south1.run.app



\---



\## Architecture



\- Node.js REST API containerized using Docker  

\- Deployed on Google Cloud Run  

\- Cloud SQL (PostgreSQL) used for database  

\- Custom VPC with Serverless VPC Access Connector  

\- Secrets managed via Google Secret Manager  

\- Infrastructure provisioned using Terraform  



\---



\## Infrastructure Components



\### Cloud Run

\- Serverless deployment

\- Auto scaling enabled



\### Cloud SQL

\- PostgreSQL database provisioned using Terraform



\### VPC

\- Custom VPC with connector for Cloud Run



\### Secret Manager

\- Secure storage for credentials



\---



\## CI/CD Pipeline



\- GitHub Actions used for automation

\- Terraform validation and deployment

\- Docker image build and push

\- Cloud Run deployment



\---



\## Security Practices



\- Least privilege IAM roles

\- Secrets stored in Secret Manager

\- Network isolation using VPC

\- Container-based deployment



\---



\## Output



Live URL:

https://devops-node-app-687812793546.asia-south1.run.app



\---



\## Conclusion

This project demonstrates a complete DevSecOps workflow on Google Cloud with CI/CD automation and infrastructure as code.

