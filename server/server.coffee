[log, to_fix] = require '../src/js/lib'
express = require 'express'

keys = require '../keys.js'

FFFF = '0x10000000000'
MAX_BATCH = 128


config =
	chainId: keys.CHAIN_ID
	keyProvider: [keys.ACTIVE_PRV]
	httpEndpoint: keys.NODE
	expireInSeconds: 60
	broadcast: true
	verbose: false
	sign: true


eos = Eos(config)

app = express()

app.use express.static '../'
app.use express.static '../src'
app.use express.static '../dist'
app.use express.json()

app.use (req, res, next)->
	res.header 'Access-Control-Allow-Origin', '*'
	res.header 'Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept'
	next()


app.use (req, res, next)->
	res.status 404
	res.send 'Not found'
	return


app.use (err, req, res, next)->
	log (new Date).getTime(), err
	res.status err.status || 500
	res.send 'Internal error'
	return


app.listen 8080, ->
	log (new Date).getTime(), 'Express server listening on port 8080'
	return



