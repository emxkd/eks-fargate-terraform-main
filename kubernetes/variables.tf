variable "request_storage" {
  description = "storage for your jenkins installation"
  default     = "5Gi"
}

variable "accessmode" {
  description = "access mode for jenkins persistent volume claim"
  default     = "ReadWriteOnce"
}

variable "name" {
  description = "name of your jenkins application, will be used as prefix for all manifests"
  default     = "jenkins"
}

variable "namespace" {
  description = "namespace where all the jenkins resources will be created"
  default     = "jenkins"
}

variable "storageclass" {
  description = "storageclass to use for creating persistent volume claim, defaults to standard of gce"
  default     = "standard"
}

variable "create_namespace" {
  description = "to create the namespace or not"
  type        = bool
}

variable "jenkins_image" {
  description = "docker image with the tag"
  default     = "jenkins/jenkins:latest"
}

variable "replicas" {
  description = "no. of replicas you want"
  default     = "1"
}
variable "service_type" {
  description = "type of kubernetes service for jenkins"
  type        = string
  default     = "NodePort"
}