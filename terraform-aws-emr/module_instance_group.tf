module "emr" {
  source = "./modules/main.tf"

  name = "Demo-instance-group"

  release_label = "emr-6.9.0"
  applications  = ["spark", "trino"]
  auto_termination_policy = {
    idle_timeout = 3600
  }

  # bootstrap_action = {
  #   example = {
  #     name = "Just an example",
  #     path = "file:/bin/echo",
  #     args = ["Hello World!"]
  #   }
  # }

  # configurations_json = jsonencode([
  #   {
  #     "Classification" : "spark-env",
  #     "Configurations" : [
  #       {
  #         "Classification" : "export",
  #         "Properties" : {
  #           "JAVA_HOME" : "/usr/lib/jvm/java-1.8.0"
  #         }
  #       }
  #     ],
  #     "Properties" : {}
  #   }
  # ])

  master_instance_group = {
    name           = "master-group"
    instance_count = 1
    instance_type  = "m5.xlarge"
  }

  core_instance_group = {
    name           = "core-group"
    instance_count = 2
    instance_type  = "c4.large"
  }

  task_instance_group = {
    name           = "task-group"
    instance_count = 2
    instance_type  = "c5.xlarge"
    bid_price      = "0.1"

    ebs_config = [{
      size                 = 256
      type                 = "gp3"
      volumes_per_instance = 1
    }]
    ebs_optimized = true
  }

  ebs_root_volume_size = 64
  ec2_attributes = {
    # Instance groups only support one Subnet/AZ
    # Subnets should be private subnets and tagged with
    # { "for-use-with-amazon-emr-managed-policies" = true }
    subnet_id = "subnet-081a9c02f5550f085"
  }
  vpc_id = "vpc-042fdfc7b9667f1ba"

  list_steps_states  = ["PENDING", "RUNNING", "FAILED", "INTERRUPTED"]
  log_uri            = "s3://my-demo-emr-bucket/"

  scale_down_behavior    = "TERMINATE_AT_TASK_COMPLETION"
  step_concurrency_level = 3
  termination_protection = false
  visible_to_all_users   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
