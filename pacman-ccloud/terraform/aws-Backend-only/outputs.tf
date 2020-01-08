###########################################
################# Outputs #################
###########################################

output "ksqlDB" {
  value = "http://${aws_alb.ksqldb_server.dns_name}"
}

output "pacman_website" {
  value = "${data.aws_s3_bucket.pacman.website_endpoint}"
}

output "event_handler_api" {
  value = "${aws_api_gateway_deployment.event_handler_v1.invoke_url}${aws_api_gateway_resource.event_handler_resource.path}"
}

