variable "ami_owner_id" {
  type        = string
  description = "The AMI owner ID"
}

variable "ami_version_pattern" {
  type        = string
  description = "The pattern to use when filtering for AMI version by name"
  default     = "*"
}

variable "application_subnet_pattern" {
  type        = string
  description = "The pattern to use when filtering for application subnets by 'Name' tag"
  default     = "sub-application-*"
}

variable "web_subnet_pattern" {
  type        = string
  description = "The pattern to use when filtering for web subnets by 'Name' tag"
  default     = "sub-web-*"
}

variable "dns_zone_suffix" {
  type        = string
  description = "The common DNS hosted zone suffix used across accounts"
  default     = "heritage.aws.internal"
}

variable "environment" {
  type        = string
  description = "The environment name to be used when creating AWS resources"
}

variable "instance_count" {
  type        = number
  description = "The number of instances to create"
  default     = 1
}

variable "instance_type" {
  type        = string
  description = "The instance type to use"
  default     = "t3.micro"
}

variable "lb_deletion_protection" {
  type        = bool
  description = "A boolean value representing whether to enable load balancer deletion protection"
  default     = false
}

variable "lvm_block_devices" {
  type = list(object({
    aws_volume_size_gb: string,
    filesystem_resize_tool: string,
    lvm_logical_volume_device_node: string,
    lvm_physical_volume_device_node: string,
  }))
  description = "A list of objects representing LVM block devices; each LVM volume group is assumed to contain a single physical volume and each logical volume is assumed to belong to a single volume group; the filesystem for each logical volume will be expanded to use all available space within the volume group using the filesystem resize tool specified; block device configuration applies only on resource creation. Set the 'filesystem_resize_tool' and 'lvm_logical_volume_device_node' fields to empty strings if the block device contains no filesystem and should be excluded from the automatic filesystem resizing, such as when the block device represents a swap volume"
  default = []
}

variable "region" {
  type        = string
  description = "The AWS region in which resources will be administered"
}

variable "root_volume_size" {
  type        = number
  description = "The size of the root volume in gibibytes (GiB)"
  default     = 20
}

variable "service" {
  type        = string
  description = "The service name to be used when creating AWS resources"
  default     = "tuxedo"
}

variable "service_subtype" {
  type        = string
  description = "The service subtype name to be used when creating AWS resources"
  default     = "frontend"
}

variable "tuxedo_services" {
  type        = map(map(number))
  description = "A map whose keys represent server-side tuxedo server groups with nested maps representing individual services by name key and port number value"
  default = {
    ceu = {
      ch  = 5000,
      img = 5001,
      orc = 5002,
    },
    chd = {
      ch  = 4000,
      img = 4001,
      orc = 4002,
    },
    ewf = {
      ois    = 2000,
      search = 2001,
      chips  = 2002,
      ef     = 2003,
      ixbrl  = 2004
      tnep   = 2005,
      trans  = 2006,
      gen    = 2007,
    },
    xml = {
      ois    = 3000,
      search = 3001,
      chips  = 3002,
      ef     = 3003,
      ixbrl  = 3004
      tnep   = 3005,
      trans  = 3006,
      gen    = 3007,
    },
  }
}

# TODO read from Vault
variable "ssh_cidrs" {
  type        = list(string)
  description = "A list of strings representing CIDR ranges from which SSH connections are permitted to EC2 instances"
}

variable "ssh_master_public_key" {
  type        = string
  description = "The SSH master public key; EC2 instance connect should be used for regular connectivity"
}

variable "team" {
  type        = string
  description = "The team name for ownership of this service"
  default     = "Platform"
}

variable "user_data_merge_strategy" {
  default     = "list(append)+dict(recurse_array)+str()"
  description = "Merge strategy to apply to user-data sections for cloud-init"
}