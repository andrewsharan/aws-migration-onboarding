# Module 2: Application Routing, Compute Fleets & Auto Scaling Tiers

This module provisions the application runtime and edge-routing ingress architectures for Project Andrew, pulling network definitions dynamically from the upstream S3 Remote State bucket.

## Infrastructure Components Engineered

*   **Application Load Balancer (ALB):** Public-facing (`internet-facing`) layer-7 application load balancer utilizing multi-AZ network mappings for high-availability traffic routing.
*   **Target Group & Active Health Monitoring:** Manages routing target instances on application port `8080`, tracking runtime stability via periodic internal `/health` endpoints.
*   **Launch Templates & Application Bootstrap Engine:** Provisions launch definitions running Amazon Linux 2023. Embeds automatic `user_data` shell wrappers to bootstrap a highly available Python/Flask API runtime out-of-the-box.
*   **Auto Scaling Group (ASG):** Establishes an elastic, multi-AZ computer tier handling automatic recovery, rolling cluster replacements via `Rolling` instance refreshes, and an integrated `ELB` check type to drop failed machines.
*   **Target Tracking Scaling Policy:** Dynamically expands and contracts instances based on a real-time cluster target utilization of 60% CPU consumption.

## Data Interconnect Layer (`data.tf`)

This module uses loose coupling via `data.tf` to remain network-independent. It queries upstream network infrastructure states dynamically at runtime:

```hcl
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "andrew-prod-remote-state-storage"
    key    = "networking/v1/terraform.tfstate"
    region = "ap-south-1"
  }
}
