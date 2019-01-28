import os
import sys

f = open('./keys.js')
data = f.read()
seed = (data.split("seed: '"))[1].split("',")[0]

if len(sys.argv) > 1:
	if sys.argv[1] == 'ropsten':
		os.system('truffle migrate --reset --network ropsten')
	if sys.argv[1] == 'mainnet':
		os.system('truffle migrate --reset --network mainnet')
else:
	os.system('pm2 stop all')
	os.system('pm2 start ganache-cli -- --mnemonic ' + seed)
	os.system('truffle migrate --reset')
