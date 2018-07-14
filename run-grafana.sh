ADMIN_PASSWORD="secret"
NAME="grafana"
docker volume create grafana-storage 
docker run -d -p 80:3000 -e "GF_SECURITY_ADMIN_PASSWORD=${ADMIN_PASSWORD}" --name="${NAME}" -v grafana-storage:/var/lib/grafana  grafana/grafana
