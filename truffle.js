var HDWalletProvider = require('truffle-hdwallet-provider');

var keys = require('./keys');

module.exports =
{
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
	networks:
	{
		development:
		{
			host: "localhost",
			port: 8545,
			network_id: "*"
		},
		ropsten:
		{
			provider: function()
			{
				return new HDWalletProvider(keys.seed, 'https://ropsten.infura.io/' + keys.infura, keys.key_index)
			},
			network_id: 3,
			gas: 1000000,
			gasPrice: 10
		}
	}
};
