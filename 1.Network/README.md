# Module 1: Foundational Network Fabric & Firewall Perimeter

This module provisions the foundational multi-Availability Zone (AZ) network architecture for project Andrew, serving as the secure baseline for all downstream application and data resources.

## Infrastructure Components Engineered

*   **Custom Virtual Private Cloud (VPC):** Provisions a dedicated, isolated networking boundary spanning the `ap-south-1` region.
*   **Decoupled Subnet Tiering:** Splits resources across redundant Public (Ingress), Private (Compute Execution), and Isolated (Data Tier) subnets across distinct availability zones.
*   **Asymmetric Gateway Routing:** Deploys Internet Gateways for public edge ingress and NAT Gateways for private compute outbound routing.
*   **Production-Grade Security Group Rule Chaining:** Implements decoupled `aws_security_group` containers with standalone `aws_security_group_rule` resources to guarantee zero-downtime firewall adjustments and mitigate state lockups.

## Firewall Configurations & Port Specifications

Security Groups use dynamic `name_prefix` patterns to allow rolling `create_before_destroy` updates.

### 1. Load Balancer Security Group (`andrew-prod-alb-sg`)
Controls perimeter entry points from the public internet:
*   **Inbound HTTP (Port 80):** Open to `0.0.0.0/0` for public web traffic routing.
*   **Inbound HTTPS (Port 443):** Open to `0.0.0.0/0` for secure web traffic routing.
*   **Outbound:** Unrestricted (`-1`) to backend application environments.

### 2. Application Security Group (`andrew-prod-app-sg`)
Protects compute instances inside the private subnet layers:
*   **Inbound App Traffic (Port 8080):** Strict rule chaining; explicitly locked down to accept traffic **only** from the source `andrew-prod-alb-sg` ID.

### 3. Database Security Group (`andrew-prod-db-sg`)
Air-gaps backend databases from the internet:
*   **Inbound Engine Traffic (Port 5432):** Locked down to accept traffic exclusively from the `andrew-prod-app-sg` and dedicated administration Bastion components.

## Exported S3 Architecture Outputs

The following variables are written out to the remote S3 state storage bucket (`networking/v1/terraform.tfstate`) to be consumed by downstream application modules:
*   `vpc_id` - The base AWS network identifier string.
*   `public_subnet_ids` - List of ingress-routable public subnet blocks.
*   `private_app_subnet_ids` - List of shielded application layer subnet blocks.
*   `alb_sg_id` - Security firewall ID for load balancer attachment.
*   `app_sg_id` - Security firewall ID for compute fleet attachment.
