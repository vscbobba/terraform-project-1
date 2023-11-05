variable "vpc_cidr" {
    type = map(string)
    default = {
        "dev" = "10.0.0.0/16"
        "prod" = "20.0.0.0/16"
    }
}
variable "subnet_public_cidr" {
    type = map(string)
    default = {
        "dev" = "10.0.1.0/24"
        "prod" = "20.0.1.0/24"
    }
}
variable "subnet_private_cidr" {
    type = map(string)
    default = {
        "dev" = "10.0.2.0/24"
        "prod" = "20.0.2.0/24"
    }
}
variable "port" {
    type = list(number)
    default = [22,8080,8081,9000]

}
variable "ami" {
    type = list(string)
    default = ["ami-053b0d53c279acc90","ami-0453898e98046c639"]
}
variable "instance_type" {
    type = list(string)
    default = ["t2.micro","t2.small"]
}
