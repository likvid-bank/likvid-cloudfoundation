
# meshfed_service service account
resource "kubernetes_service_account" "meshfed_service" {
  metadata {
    name      = "meshfed-service"
    namespace = var.namespace
    annotations = {
      "io.meshcloud/meshstack.replicator-kubernetes.version" = "1.0"
    }
  }
  secret {
    name = kubernetes_secret.meshfed_service_secret.metadata.0.name
  }
}

# meshfed_service secret
resource "kubernetes_secret" "meshfed_service_secret" {
  metadata {
    name = "meshfed-service"
  }
}


###
# meshfed_service cluster role
resource "kubernetes_cluster_role" "meshfed-service" {
  metadata {
    name = "meshfed-service"
    annotations = {
      "io.meshcloud/meshstack.replicator-kubernetes.version" = "1.0"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get", "list", "watch", "create", "delete", "update"]

  }
  rule {
    api_groups = [""]
    resources  = ["resourcequotas", "resourcequotas/status"]
    verbs      = ["get", "list", "watch", "create", "delete", "deletecollection", "patch", "update"]

  }
  rule {
    api_groups = [""]
    resources  = ["appliedclusterresourcequotas", "clusterresourcequotas", "clusterresourcequotas/status"]
    verbs      = ["get", "list", "watch", "create", "delete", "deletecollection", "patch", "update"]

  }
  rule {
    api_groups = ["", "rbac.authorization.k8s.io"]
    resources  = ["roles", "rolebindings", "clusterroles", "clusterrolebindings"]
    verbs      = ["get", "list", "watch"]

  }
  rule {
    api_groups = ["", "rbac.authorization.k8s.io"]
    resources  = ["rolebindings"]
    verbs      = ["create", "delete", "update"]

  }
  rule {
    api_groups     = ["", "rbac.authorization.k8s.io"]
    resources      = ["clusterroles"]
    verbs          = ["bind"]
    resource_names = ["admin", "edit", "view"]
  }
}

# meshfed_service role binding
resource "kubernetes_cluster_role_binding" "meshfed-service" {
  subject {
    kind      = "ServiceAccount"
    name      = "meshfed-service"
    namespace = var.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "meshfed-service"
  }
  metadata {
    name = "meshfed-service"
    annotations = {
      "io.meshcloud/meshstack.replicator-kubernetes.version" = "1.0"
    }
  }
}