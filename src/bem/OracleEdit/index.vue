<template>

	<section class="container">
		<h2 class="content__heading sb30">{{ $t('OracleEdit') }}</h2>

		<div class="OracleTable buefy">
			<b-table
					:data="voters"
					:mobile-cards="true"
					paginated
					per-page="10"
					pagination-simple
					:selected.sync="selected_oracle"
					@click="table_click"
					:row-class="(row, index) => selected_oracle && row.addr === selected_oracle.addr && 'is-info'"
					detailed>

				<template slot-scope="props">

					<b-table-column field="date" :label="$t('OracleTableAddress')" :title="props.row.addr">
						<span class="tag is-success">{{ props.row.addr | shortAddress }}</span>
					</b-table-column>

					<b-table-column field="date" :label="$t('OracleTableType')">
						{{ props.row.type }}
					</b-table-column>

					<b-table-column field="date" :label="$t('OracleTableStatus')" centered>
						{{ props.row.status }}
					</b-table-column>

				</template>


				<template slot="detail" slot-scope="props">
					<div class="WhiteListTable__detail">
					<span>
						{{props.row.addr}}
					</span>
					</div>
				</template>
			</b-table>

		</div>

		<div class="form-group sb30">
			<label>{{ $t('OracleAddress') }}</label>
			<b-field>
				<input :value="current_addr" type="text" class="form-control"/>
			</b-field>
		</div>

		<div class="form-group sb30 sb2">
			<label>{{ $t('OracleInfo') }}</label>
			<b-field>
				<textarea v-model="current_info" type="text" class="form-control"/>
			</b-field>
		</div>

		<p>{{$t('OracleSelectStatus')}}</p>

		<select class="sb2" v-model="current_status" @input="input55">
			<option :value="false">Disabled</option>
			<option :value="true">Enabled</option>
		</select>

		<p>{{$t('OracleSelectType')}}</p>

		<select class="sb2" v-model="current_oracle_type" @input="input55">
			<option :value="0">0</option>
			<option :value="1">1</option>
			<option :value="2">2</option>
			<option :value="3">3</option>
			<option :value="4">4</option>
		</select>

		<div>
			<button
				class="btn sb100 btn-primary py-2 my-2"
				:disabled="false"
				@click="set_oracle">
				{{$t('OracleSubmit')}}
			</button>
		</div>

	</section>
</template>

<script lang="coffee">

import './default.scss'
import Eth from 'ethjs'
import EthContract from 'ethjs-contract'

window.log = console.log

```
var ORACLE = [
    {
      "constant": true,
      "inputs": [
        {
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "proposals",
      "outputs": [
        {
          "name": "project_addr",
          "type": "address"
        },
        {
          "name": "stage_index",
          "type": "uint256"
        },
        {
          "name": "voteCount",
          "type": "uint256"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function",
      "signature": "0x013cf08b"
    },
    {
      "constant": true,
      "inputs": [
        {
          "name": "",
          "type": "address"
        }
      ],
      "name": "admins",
      "outputs": [
        {
          "name": "",
          "type": "bool"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function",
      "signature": "0x429b62e5"
    },
    {
      "constant": true,
      "inputs": [
        {
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "oracles",
      "outputs": [
        {
          "name": "info",
          "type": "string"
        },
        {
          "name": "oracle_type",
          "type": "uint8"
        },
        {
          "name": "status",
          "type": "bool"
        },
        {
          "name": "setted",
          "type": "bool"
        },
        {
          "name": "addr",
          "type": "address"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function",
      "signature": "0x5b69a7d8"
    },
    {
      "constant": false,
      "inputs": [],
      "name": "renounceOwnership",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function",
      "signature": "0x715018a6"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "owner",
      "outputs": [
        {
          "name": "",
          "type": "address"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function",
      "signature": "0x8da5cb5b"
    },
    {
      "constant": true,
      "inputs": [
        {
          "name": "",
          "type": "address"
        },
        {
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "proj_oracles",
      "outputs": [
        {
          "name": "",
          "type": "address"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function",
      "signature": "0xb687e38e"
    },
    {
      "constant": true,
      "inputs": [
        {
          "name": "",
          "type": "address"
        },
        {
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "oracle_projs",
      "outputs": [
        {
          "name": "",
          "type": "address"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function",
      "signature": "0xde2fd9d2"
    },
    {
      "constant": true,
      "inputs": [
        {
          "name": "",
          "type": "address"
        }
      ],
      "name": "oracles_index",
      "outputs": [
        {
          "name": "",
          "type": "uint256"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function",
      "signature": "0xeac0dc8b"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "master",
      "outputs": [
        {
          "name": "",
          "type": "address"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function",
      "signature": "0xee97f7f3"
    },
    {
      "constant": false,
      "inputs": [
        {
          "name": "_newOwner",
          "type": "address"
        }
      ],
      "name": "transferOwnership",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function",
      "signature": "0xf2fde38b"
    },
    {
      "inputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "constructor",
      "signature": "constructor"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "name": "previousOwner",
          "type": "address"
        }
      ],
      "name": "OwnershipRenounced",
      "type": "event",
      "signature": "0xf8df31144d9c2f0f6b59d69b8b98abd5459d07f2742c4df920b25aae33c64820"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "name": "previousOwner",
          "type": "address"
        },
        {
          "indexed": true,
          "name": "newOwner",
          "type": "address"
        }
      ],
      "name": "OwnershipTransferred",
      "type": "event",
      "signature": "0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0"
    },
    {
      "constant": false,
      "inputs": [
        {
          "name": "admin_addr",
          "type": "address"
        }
      ],
      "name": "setAdmin",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function",
      "signature": "0x704b6c02"
    },
    {
      "constant": false,
      "inputs": [
        {
          "name": "admin_addr",
          "type": "address"
        }
      ],
      "name": "removeAdmin",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function",
      "signature": "0x1785f53c"
    },
    {
      "constant": false,
      "inputs": [
        {
          "name": "addr",
          "type": "address"
        },
        {
          "name": "info",
          "type": "string"
        },
        {
          "name": "oracle_type",
          "type": "uint8"
        },
        {
          "name": "status",
          "type": "bool"
        }
      ],
      "name": "setOracle",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function",
      "signature": "0xf2faa6c1"
    },
    {
      "constant": false,
      "inputs": [
        {
          "name": "addr",
          "type": "address"
        },
        {
          "name": "proj",
          "type": "address"
        }
      ],
      "name": "linkOracle",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function",
      "signature": "0xcfb7f5ed"
    },
    {
      "constant": true,
      "inputs": [
        {
          "name": "proj",
          "type": "address"
        },
        {
          "name": "page",
          "type": "uint256"
        }
      ],
      "name": "getProjOracles",
      "outputs": [
        {
          "name": "data",
          "type": "address[]"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function",
      "signature": "0x1405c17c"
    },
    {
      "constant": true,
      "inputs": [
        {
          "name": "page",
          "type": "uint256"
        }
      ],
      "name": "getOracles",
      "outputs": [
        {
          "name": "data",
          "type": "address[]"
        },
        {
          "name": "types",
          "type": "uint8[]"
        },
        {
          "name": "statuses",
          "type": "bool[]"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function",
      "signature": "0x29f4e89d"
    },
    {
      "constant": true,
      "inputs": [
        {
          "name": "index",
          "type": "uint256"
        }
      ],
      "name": "getOracle",
      "outputs": [
        {
          "name": "info",
          "type": "string"
        },
        {
          "name": "oracle_type",
          "type": "uint8"
        },
        {
          "name": "status",
          "type": "bool"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function",
      "signature": "0x10a9de60"
    },
    {
      "constant": false,
      "inputs": [
        {
          "name": "proposal",
          "type": "uint256"
        }
      ],
      "name": "vote",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function",
      "signature": "0x0121b93f"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "winningProposal",
      "outputs": [
        {
          "name": "winningProposal_",
          "type": "uint256"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function",
      "signature": "0x609ff1bd"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "winnerName",
      "outputs": [
        {
          "name": "winnerName_",
          "type": "bytes32"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function",
      "signature": "0xe2ba53f0"
    },
    {
      "constant": false,
      "inputs": [
        {
          "name": "new_master",
          "type": "address"
        }
      ],
      "name": "set_master",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function",
      "signature": "0x86795e8d"
    }
  ];
```
ORACLE_ADDR = '0x6D1595e6b18ceEB5e3D5Eee7CE35bB74484383C7'

PAGE_SIZE = 10


export default

	data: ->
		voters: []
		page: 0
		selected_oracle: null
		current_addr: ''
		current_info: ''
		current_oracle_type: '0'
		current_status: 'false'


	filters:
		shortAddress: (value)->
			length = value.length
			value.slice(0, 8) + " ... " + value.slice(length - 8, length)

		percentFractional: (value)->
			value / 100


	watch:
		'selected_oracle': (to, from)->

			@current_addr = to.addr

			if login.oracle
				res = await login.oracle.getOracle to.index
				@current_info = res.info
				@current_oracle_type = res.oracle_type.toString()
				@current_status = res.status
			return


	methods:
		input55: ->
			return


		set_oracle: ->

			log @current_addr

			if login.oracle
				log @current_info
				res = await login.oracle.setOracle @current_addr, @current_info, @current_oracle_type, @current_status,
					from: login.account
				@scan false
			return


		table_click: ->
			return


		scan: (scan_flag)->
			if window.login is undefined or window.login.eth is undefined
				window.login = {}
				if typeof(web3) is 'undefined'
					window.addEventListener 'message', ({data}) =>
						if data and data.type and data.type is 'ETHEREUM_PROVIDER_SUCCESS'
							window.login.eth = new Eth 'ethereum'
					window.postMessage {type: 'ETHEREUM_PROVIDER_REQUEST'}, '*'

				else
					window.login.eth = new Eth web3.currentProvider

			if login.eth
				try
					arr = await login.eth.accounts()
					if arr.length > 0
						login.account = arr[0]
					else
						login.account = null
				catch err
					login.account = null
				contract = new EthContract login.eth
				login.oracle = (contract(ORACLE)).at ORACLE_ADDR

			if login.oracle
				res = await login.oracle.getOracles @page
				voters = []
				if res["0"]
					addrs = res['0']
					types = res['1']
					statuses = res['2']
					str = ((if v is true then 'Enabled' else 'Disabled') for v in statuses)
					for addr, i in addrs
						if addr isnt '0x0000000000000000000000000000000000000000'
							voters.push {addr, type: types[i].toString(), status: str[i], index: @page * PAGE_SIZE + i}

					for voter, i in voters
						if @voters[i]
							if @voters[i].addr isnt voter.addr
								@voters[i] = voter
							else
								if @voters[i].type isnt voter.type
									@voters[i].type = voter.type
								if @voters[i].status isnt voter.status
									@voters[i].status = voter.status
						else
							@voters.push voter



			if scan_flag
				setTimeout =>
					@scan scan_flag
				, 10000

				return

			return

	mounted: ->
		@scan true
		return

</script>
