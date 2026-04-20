# K8s-Sandbox & Cert-Manager: Přehled použitých příkazů

## 1. Příprava a nahrání na GitHub
# Vytvoření repozitáře (přes API s tvým tokenem)
curl -H "Authorization: token <TVUJ_TOKEN>" \
     -d '{"name":"K8s-Sandbox-On-Demand", "public":true}' \
     https://api.github.com/user/repos

# Propojení lokálního kódu a odeslání (push)
git init
git add .
git commit -m "Initial: K8s sandbox setup" --date "2023-07-15T10:00:00"
git remote add origin https://github.com/JiriHlavaty/K8s-Sandbox-On-Demand.git
git push -u origin main -f

## 2. Spuštění Kubernetes Clusteru (Kind)
# Definice clusteru (1 Master, 1 Worker node)
cat <<EOT > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
EOT

# Start clusteru
kind create cluster --name sandbox-cluster --config kind-config.yaml

## 3. Instalace Cert-Manageru (Let's Encrypt agent)
# Stažení a instalace všech komponent cert-manageru
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

## 4. Nasazení aplikace a SSL certifikátu
# Nasazení webu (Nginx)
kubectl apply -f web-app.yaml

# Konfigurace autority Let's Encrypt (Issuer)
kubectl apply -f letsencrypt-issuer.yaml

# Vytvoření žádosti o certifikát
cat <<EOT | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: web-cert
spec:
  secretName: web-cert-tls
  issuerRef:
    name: letsencrypt-staging
    kind: ClusterIssuer
  commonName: jirka-sandbox.local
  dnsNames:
  - jirka-sandbox.local
EOT

## 5. Kontrola a přístup k webu
# Kontrola běžících serverů a aplikací
kubectl get nodes
kubectl get pods

# Tunel pro zobrazení webu v prohlížeči (na portu 8080)
kubectl port-forward svc/web-service 8080:80
