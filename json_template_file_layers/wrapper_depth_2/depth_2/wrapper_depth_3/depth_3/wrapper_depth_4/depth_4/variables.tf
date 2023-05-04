

variable "json_template_file_path" {
  description = "(Required) The Filepath to the JSON-Template File from the terraform Root-Folder."
  nullable    = false
  type        = string
}


variable "allow_recursion" {
  description = "value"
  type        = bool
  default     = true
}
