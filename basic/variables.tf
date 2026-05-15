variable "file_content" {
  default     = "Conteúdo Default"
  description = "Essa variável representa o valor a ser salvo no arquivo"
  type        = string
}

variable "var_bool" {
  default = false
  type    = bool
}

variable "fruits" {
  default = ["apple", "banana", "cherry"]
  type    = set(string)
}

variable "person_map" {
  type = map(string)
  default = {
    "name" = "Fernando"
    "age"  = "42"
  }
}

variable "person_tuple" {
  type    = tuple([string, number])
  default = ["Fernando", 42]
}

variable "person" {
  type = object({
    name = string
    age  = number
  })
  default = {
    name = "Fernando"
    age  = 28
  }
}




