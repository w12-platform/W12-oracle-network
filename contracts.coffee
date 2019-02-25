[log, to_fix, get_user, inc_time, CNS, asrt] = require './src/js/lib'
keys = require './keys.js'


Eth = require 'ethjs'


oracle = artifacts.require 'OracleBallot'


ether = (val)->
	Eth.fromWei val, 'ether'


wei = (val)->
	Eth.toWei val, 'ether'


bn = (val)->
	return new Eth.BN val, 10


gas = (val, gas_price)->
	return (bn val).mul(bn '1000000000').mul(bn gas_price).toString()



module.exports = (cb)->

	eth = new Eth web3.currentProvider
	0

#	oracle = await oracle.deployed()
	oracle = await oracle.at '0x0a4869019AfdE941F9C12a57E14604F1A0275909'.toLowerCase()

#	try
#		res = await oracle.setAdmin keys.user3,
#			from: keys.owner
#
#		log res
#
#	catch err
#		log err

	try
		res = await oracle.setOracle keys.user4, 'info4', 1, true,
			from: keys.user3

		log res

	catch err
		log err

	try
		res = await oracle.setOracle keys.user5, 'info5', 1, true,
			from: keys.user3

		log res

	catch err
		log err

	try
		res = await oracle.setOracle keys.user6, 'info6', 1, true,
			from: keys.user3

		log res

	catch err
		log err


	try
		res = await oracle.linkOracle keys.user4, keys.user8,
			from: keys.user3

		log res

	catch err
		log err


	try
		res = await oracle.getOracles 0,
			from: keys.user3

		log res

	catch err
		log err







