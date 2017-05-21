< /dev/urandom tr -dc a-f0-9 | head -c${1:-12} > /vagrant/dtr-replica-id
export UCP_IPADDR=$(cat /vagrant/ucp-node1-ipaddr)
export DTR_IPADDR=$(cat /vagrant/dtr-node1-ipaddr)
export UCP_PASSWORD=$(cat /vagrant/ucp_password)
export DTR_REPLICA_ID=$(cat /vagrant/dtr-replica-id)

# Install DTR
curl -k https://ucp.local/ca > ucp-ca.pem
docker run --rm docker/dtr:2.2.4 install --ucp-url https://${UCP_IPADDR} --ucp-node dtr-node1.local --replica-id ${DTR_REPLICA_ID} --dtr-external-url https://dtr.local --ucp-username admin --ucp-password ${UCP_PASSWORD} --ucp-ca "$(cat ucp-ca.pem)"
# Run backup of DTR
docker run --rm docker/dtr:2.2.4 backup --ucp-url https://${UCP_IPADDR} --existing-replica-id ${DTR_REPLICA_ID} --ucp-username admin --ucp-password ${UCP_PASSWORD} --ucp-ca "$(cat ucp-ca.pem)" > /tmp/backup.tar

# Trust self-signed DTR CA
sudo curl -k https://dtr.local/ca -o /etc/pki/ca-trust/source/anchors/dtr.local.crt
sudo update-ca-trust
sudo /bin/systemctl restart docker.service
