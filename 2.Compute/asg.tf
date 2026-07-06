# Launch Template 
resource "aws_launch_template" "app_template" {
  name_prefix   = "andrew-prod-template-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false 
    security_groups             = [data.terraform_remote_state.network.outputs.app_sg_id]
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" 
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = false 
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  # Application User Data
  user_data = base64encode(<<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y python3 python3-pip

              mkdir -p /opt/andrew-app
              cd /opt/andrew-app

              cat << 'PY_EOF' > app.py
              from flask import Flask, jsonify
              import socket

              app = Flask(__name__)

              @app.route('/health', methods=['GET'])
              def health_check():
                  return jsonify({"status": "healthy", "service": "andrew-core-api"}), 200

              @app.route('/', methods=['GET'])
              def index():
                  hostname = socket.gethostname()
                  return jsonify({
                      "project": "andrew",
                      "message": "Production Engine Operational under the hood",
                      "served_by_node": hostname
                  }), 200

              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=8080)
              PY_EOF

              pip3 install flask
              nohup python3 app.py > app.log 2>&1 &
              EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group 
resource "aws_autoscaling_group" "app_asg" {
  name_prefix         = "andrew-prod-asg-"
  vpc_zone_identifier = data.terraform_remote_state.network.outputs.private_app_subnet_ids
  target_group_arns   = [aws_lb_target_group.app_tg.arn] 

  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }

  min_size                  = 2 
  max_size                  = 6
  desired_capacity          = 2
  health_check_type         = "ELB"
  health_check_grace_period = 180

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group Policy
resource "aws_autoscaling_policy" "cpu_tracking" {
  name                   = "andrew-prod-cpu-tracking-policy"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}
