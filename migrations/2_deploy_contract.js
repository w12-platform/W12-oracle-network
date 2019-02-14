var OracleBallot = artifacts.require("OracleBallot");

var keys = require('../keys');


module.exports = function(deployer)
{
	deployer.deploy(OracleBallot, {gas: 3000000, from: keys.owner});
}


