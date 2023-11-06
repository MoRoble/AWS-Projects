#### -- main/database

/* using maria DB to migrate between onprem to aws

MariaDB is a community-developed, commercially supported fork of the MySQL relational database management system, intended to remain free and open-source software under the GNU General Public License.
*/

# data "aws_db_snapshot" "latest_db_snapshot" {
#   db_snapshot_identifier = var.snapshot_identifier
#   most_recent            = true
#   snapshot_type          = manual # there's error on this
# }

resource "aws_db_instance" "arday_db" {
  allocated_storage      = 10
  engine                 = "mariadb"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  db_name                = var.dbname
  username               = var.dbuser
  password               = var.dbpassword
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  identifier             = var.db_identifier
  # snapshot_identifier    = data.aws_db_snapshot.latest_db_snapshot.id
  skip_final_snapshot = var.skip_db_snapshot
  tags = {
    Name = "arday-dev-db"
  }
}