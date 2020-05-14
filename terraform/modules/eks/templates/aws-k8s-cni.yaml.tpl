---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: aws-node
rules:
  - apiGroups:
      - crd.k8s.amazonaws.com
    resources:
      - "*"
      - namespaces
    verbs:
      - "*"
  - apiGroups: [""]
    resources:
      - pods
      - nodes
      - namespaces
    verbs: ["list", "watch", "get"]
  - apiGroups: ["extensions"]
    resources:
      - daemonsets
    verbs: ["list", "watch"]

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aws-node
  namespace: kube-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: aws-node
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: aws-node
subjects:
  - kind: ServiceAccount
    name: aws-node
    namespace: kube-system

---
kind: DaemonSet
apiVersion: apps/v1
metadata:
  name: aws-node
  namespace: kube-system
  labels:
    k8s-app: aws-node
spec:
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: "10%"
  selector:
    matchLabels:
      k8s-app: aws-node
  template:
    metadata:
      labels:
        k8s-app: aws-node
    spec:
      priorityClassName: system-node-critical
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: "beta.kubernetes.io/os"
                    operator: In
                    values:
                      - linux
                  - key: "beta.kubernetes.io/arch"
                    operator: In
                    values:
                      - amd64
                  - key: eks.amazonaws.com/compute-type
                    operator: NotIn
                    values:
                      - fargate
      serviceAccountName: aws-node
      hostNetwork: true
      tolerations:
        - operator: Exists
      containers:
        - image: 602401143452.dkr.ecr.us-west-2.amazonaws.com/amazon-k8s-cni:v1.6.0
          imagePullPolicy: Always
          ports:
            - containerPort: 61678
              name: metrics
          name: aws-node
          readinessProbe:
            exec:
              command: ["/app/grpc-health-probe", "-addr=:50051"]
            initialDelaySeconds: 35
          livenessProbe:
            exec:
              command: ["/app/grpc-health-probe", "-addr=:50051"]
            initialDelaySeconds: 35
          env:
%{ for k,v in environment ~}
            - name: "${k}"
              value: "${v}"
%{ endfor }
            - name: MY_NODE_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
          resources:
            requests:
              cpu: 10m
          securityContext:
            privileged: true
          volumeMounts:
            - mountPath: /host/opt/cni/bin
              name: cni-bin-dir
            - mountPath: /host/etc/cni/net.d
              name: cni-net-dir
            - mountPath: /host/var/log
              name: log-dir
            - mountPath: /var/run/docker.sock
              name: dockersock
            - mountPath: /var/run/dockershim.sock
              name: dockershim
      volumes:
        - name: cni-bin-dir
          hostPath:
            path: /opt/cni/bin
        - name: cni-net-dir
          hostPath:
            path: /etc/cni/net.d
        - name: log-dir
          hostPath:
            path: /var/log
        - name: dockersock
          hostPath:
            path: /var/run/docker.sock
        - name: dockershim
          hostPath:
            path: /var/run/dockershim.sock

---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: eniconfigs.crd.k8s.amazonaws.com
spec:
  scope: Cluster
  group: crd.k8s.amazonaws.com
  versions:
    - name: v1alpha1
      served: true
      storage: true
  names:
    plural: eniconfigs
    singular: eniconfig
    kind: ENIConfig