resource "aws_security_group_rule" "workers_to_es" {
  count                    = var.enable_elasticsearch-fluentd ? 1 : 0
  description              = "Allow workers to connect to ES"
  protocol                 = "tcp"
  security_group_id        = var.es_sg
  source_security_group_id = aws_security_group.workers.id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

data "helm_repository" "elastichsearch-fluentd" {
  count = var.enable_elasticsearch-fluentd ? 1 : 0
  name  = "elasticsearch-fluentd"
  url   = "https://kiwigrid.github.io"
}

resource "helm_release" "elasticsearch-fluentd" {
  depends_on = [aws_autoscaling_group.workers]
  count      = var.enable_elasticsearch-fluentd ? 1 : 0
  name       = "fluentd-elasticsearch"
  namespace  = "kube-system"
  repository = data.helm_repository.elastichsearch-fluentd[0].url
  chart      = "fluentd-elasticsearch"

  /*set {
        name = "awsSigningSidecar.enabled"
        value = fa
    }*/

  set {
    name  = "elasticsearch.host"
    value = var.elasticsearch_host
  }

  set {
    name  = "elasticsearch.port"
    value = "443"
  }

  set {
    name  = "elasticsearch.scheme"
    value = "https"
  }
}
