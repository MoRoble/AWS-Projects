host_os = "linux"

access_ip   = "0.0.0.0/0"
bucketnames = "devops-general-roble"
# tags = "devenv"

##----ec2-vars----

file_path = {
  user_data        = "./compute/userdata_wp.tpl"
  onprem_user_data = "./compute/wordpress_install.sh"
  key-file         = "~/Documents/Dev/keys/devenv.pub"

}


#--db vars --
db = {
  name = "arday_db"
  user = "arday_user"
  password = "p3rsonalPlu5"
  rootpassword = "p3rsonalPlu5"
}

dbname         = "barxada"
dbuser         = "loki"
dbpassword     = "h0d4nF!l35"
dbrootpassword = "p3rsonalPlu5"
devtags = {
  environment  = "Development"
  BusinessUnit = "Tech" #to be confirmed
  Department   = "DevOps"
}

peer_owner_id = "775314516687"
