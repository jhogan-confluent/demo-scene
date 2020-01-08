###########################################
########## Variables JS file ##############
###########################################

data "template_file" "variables_js" {
  template = file("../../pacman/game/js/variables.js")
  vars = {
    event_handler_api = "${aws_api_gateway_deployment.event_handler_v1.invoke_url}${aws_api_gateway_resource.event_handler_resource.path}"
    cloud_provider = "AWS"
    ksqldb_url = "http://${aws_alb.ksqldb_server.dns_name}"
  }
}

resource "aws_s3_bucket_object" "variables_js" {
  bucket = data.aws_s3_bucket.pacman.bucket
  key = "game/js/variables.js"
  content_type = "text/javascript"
  content = data.template_file.variables_js.rendered
}
