echo "Removing key from key store..."

rm -rf ./hfc-key-store


# Remove chaincode docker image
docker rmi -f dev-peer0.org1.example.com-mycc-1.0-384f11f484b9302df90b453200cfb25174305fce8f53f4e94d45ee3b6cab0ce9


cd ../basic-network
./start.sh

# Now launch the CLI container in order to install, instantiate chaincode
# and prime the ledger with our 10 cars
docker-compose -f ./docker-compose.yml up -d cli
docker ps -a



echo 'Installing chaincode..'
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode install -n mycc -v 1.0 -p "/opt/gopath/src/github.com/newcc" -l "node"

echo 'Instantiating chaincode..'
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode instantiate -o orderer.example.com:7050 -C mychannel -n mycc -l "node" -v 1.0 -c '{"Args":[""]}' -P "OR ('Org1MSP.member','Org2MSP.member')"
echo 'Getting things ready for chaincode calls..'

sleep 10

echo 'Initializing ledger..'
docker exec -e “CORE_PEER_LOCALMSPID=Org1MSP” -e “CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp” cli peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n mycc -c '{"function":"initLedger","Args":[]}'

sleep 3
echo 'Querying All Products..'

docker exec -e “CORE_PEER_LOCALMSPID=Org1MSP” -e “CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp” cli peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n mycc -c '{"function":"queryAllProducts","Args":[]}'

echo 'Buying Product..'

docker exec -e “CORE_PEER_LOCALMSPID=Org1MSP” -e “CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp” cli peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n mycc -c '{"function":"buyProduct","Args":["Item0","Salman","2"]}'

sleep 5
echo ' Querying Placed Order Status..'

docker exec -e “CORE_PEER_LOCALMSPID=Org1MSP” -e “CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp” cli peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n mycc -c '{"function":"myOrder","Args":["Ord1"]}'


echo 'Changing Order Status..'

docker exec -e “CORE_PEER_LOCALMSPID=Org1MSP” -e “CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp” cli peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n mycc -c '{"function":"changeOrderStatus","Args":["Ord1","Delivered"]}'

sleep 3
echo 'Querying All Orders Again to see Result..'

docker exec -e “CORE_PEER_LOCALMSPID=Org1MSP” -e “CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp” cli peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n mycc -c '{"function":"allOrders","Args":[]}'

echo 'Adding Product..'

docker exec -e “CORE_PEER_LOCALMSPID=Org1MSP” -e “CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp” cli peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n mycc -c '{"function":"addProduct","Args":["Item5","Laptops","G8-45","Microsoft Surface Pro3","3800","24"]}'

# Starting docker logs of chaincode container

docker logs -f dev-peer0.org1.example.com-mycc-1.0


