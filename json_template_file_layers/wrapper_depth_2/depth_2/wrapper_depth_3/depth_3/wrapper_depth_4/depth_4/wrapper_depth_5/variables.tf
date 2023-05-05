
variable "folder_path" {
  type        = string
  nullable    = false
  description = "(Required) Folder path to all subfiles to be processed."
}

variable "file_filter" {
  type        = string
  nullable    = false
  description = "(Required) File Filter in the subpath."
}

variable "injection_type" {
  type        = string
  nullable    = false
  description = "(Required) Type of how the files will be merged to the parent."

  validation {
    condition     = can(regex("AsMap|AsList|AsSingle", var.injection_type))
    error_message = "Must be one of 'AsMap' or 'AsList' or 'AsSingle'"
  }
}
