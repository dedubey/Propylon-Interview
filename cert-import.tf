resource "tls_private_key" "certificate" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "certificate" {
 # key_algorithm   = "RSA"
  private_key_pem = tls_private_key.certificate.private_key_pem

  subject {
    common_name  = var.common_name
    organization = "Deepak Industries"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "certificate" {
  private_key      = tls_private_key.certificate.private_key_pem
  certificate_body = tls_self_signed_cert.certificate.cert_pem
}