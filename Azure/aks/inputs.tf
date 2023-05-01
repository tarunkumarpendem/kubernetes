variable "resource_group_details" {
    type = object({
        resource_group_name = string
        location = string
        resource_group_tags = list(string)
    })
    description = "Declaring resource group details" 
}

variable "network_details" {
    type = object({
        vnet_name = string
        vnet_address_space = string
        vnet_tags =  list(string)
        


    })
  
}