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
          "type": "address"
        }
      ],
      "name": "proj_oracles_index",
      "outputs": [
        {
          "name": "",
          "type": "uint256"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function",
      "signature": "0xd98696a2"
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
      "name": "unlinkOracle",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function",
      "signature": "0x02bd0be3"
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

var ORACLE_ADDR = '0x575001e6c0bd92af5f96c4cee2f7969c2c87f821';

export {ORACLE, ORACLE_ADDR};


