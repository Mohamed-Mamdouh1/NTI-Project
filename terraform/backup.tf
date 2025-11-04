resource "aws_backup_vault" "jenkins_vault" {
  name = "jenkins-backup-vault"
}

resource "aws_backup_plan" "jenkins_backup" {
  name = "jenkins-daily"
  rule {
    rule_name         = "daily"
    target_vault_name = aws_backup_vault.jenkins_vault.name
    schedule          = "cron(0 2 * * ? *)" # every day at 2 AM UTC
  }
}