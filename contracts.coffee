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

	oracle = await oracle.deployed()

#	try
#		res = await oracle.addAdmin keys.user3,
#			from: keys.owner
#
#		log res
#
#	catch err
#		log err
#
#
#	try
#		res = await oracle.addAdmin keys.user4,
#			from: keys.owner
#
#		log res
#
#	catch err
#		log err
#
#
#
#	try
#		res = await oracle.addEditVoter keys.user5, 'info1', 1, true,
#			from: keys.user3
#
#		log res
#
#	catch err
#		log err
#
#
#	try
#		res = await oracle.addEditVoter keys.user6, 'info1', 1, true,
#			from: keys.user3
#
#		log res
#
#	catch err
#		log err
#
#
#	try
#		res = await oracle.addEditVoter keys.user7, 'info1', 1, true,
#			from: keys.user3
#
#		log res
#
#	catch err
#		log err
#
#
#	try
#		res = await oracle.linkVoter keys.user8, keys.user6,
#			from: keys.user3
#
#		log res
#
#	catch err
#		log err
#
#
#	try
#		res = await oracle.linkVoter keys.user8, keys.user7,
#			from: keys.user3
#
#		log res
#
#	catch err
#		log err


	try
		res = await oracle.getVoters keys.user8, 0,
			from: keys.user3

		log res

	catch err
		log err







