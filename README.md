# Secure Cloud Run Microservices Demo

This project demonstrates how to set up a secure microservices architecture using Google Cloud Run, with a public frontend and a private backend, all managed by Terraform.

## Prerequisites

- Google Cloud Platform account
- gcloud CLI
- Terraform
- Docker

## Quick Start

1. Clone the repository:

`git clone git@github.com:finnng/demo-cloud-run-vpc.git`

`cd demo-cloud-run-vpc`

2. Set up your GCP project:

`export PROJECT_ID=your-project-id`

`gcloud config set project $PROJECT_ID`

3. Enable necessary APIs:

`gcloud services enable run.googleapis.com artifactregistry.googleapis.com compute.googleapis.com`

4. Create an Artifact Registry repository:

`gcloud artifacts repositories create cloud-run-demo --repository-format=docker --location=us-central1`

5. Build and push Docker images:

Backend

```
cd backend
docker build -t us-central1-docker.pkg.dev/$PROJECT_ID/cloud-run-demo/backend:v1 .
docker push us-central1-docker.pkg.dev/$PROJECT_ID/cloud-run-demo/backend:v1
cd ..
```

Frontend
```
cd frontend
docker build -t us-central1-docker.pkg.dev/$PROJECT_ID/cloud-run-demo/frontend:v1 .
docker push us-central1-docker.pkg.dev/$PROJECT_ID/cloud-run-demo/frontend:v1
cd ..
```

6. Configure Terraform:

- Update `terraform.tfvars` with your project details.

7. Deploy with Terraform:

`terraform init`

`terraform apply`

8. Test the deployment:

- Access the frontend URL output by Terraform.
- Verify that the backend is not publicly accessible.

9. Clean up:

`terraform destroy`

## Project Structure

- `backend/`: Backend service code and Dockerfile
- `frontend/`: Frontend service code and Dockerfile
- `main.tf`: Main Terraform configuration
- `variables.tf`: Terraform variables
- `outputs.tf`: Terraform outputs
- `terraform.tfvars`: Terraform variable values

## Notes

- The backend is configured to be private and accessible only through the VPC.
- The frontend can communicate with the backend securely.
- Ensure to destroy resources after testing to avoid unnecessary charges.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
