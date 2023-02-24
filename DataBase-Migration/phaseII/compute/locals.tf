# locals {
#   env_name = var.devtags["environment"]
#   tmp = { #? Trying out somethign I saw somewhere!! Don't ask me at this stage
#     dev_generic_name = {
#       dev = replace(
#         replace(
#           "${local.env_name}",
#           "/[^a-zA-Z0-9-]/", "-"
#         ),
#         "[-]{2,}", "-"
#       )
#     }
#     ssmp_placeholder_default_value = "__REPLACE_ME__"
#   }
# }