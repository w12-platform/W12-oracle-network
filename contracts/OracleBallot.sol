pragma solidity ^0.5.0;




/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


contract OracleBallot is Ownable
{

	uint PAGE_SIZE = 10;

	struct Oracle
	{
		string info;
		uint8 oracle_type;
		bool status;
		bool setted;
		address addr;
	}

	address public master;
	mapping(address => bool) public admins;

	Oracle[] public oracles;
	mapping(address => uint) public oracles_index;

	mapping(address => address[]) public proj_oracles;
	mapping(address => address[]) public oracle_projs;

//	mapping(address => mapping(address => uint)) public proj_voters_index;


	struct StageBallot
	{
		address project_addr;
		uint stage_index;
		uint voteCount;
	}


	StageBallot[] public proposals;

	constructor() public
	{
		master = msg.sender;
	}


	function setAdmin(address admin_addr) public
	{
		if(msg.sender != owner)
		{
			require(msg.sender == master);
		}

		admins[admin_addr] = true;
	}

	function removeAdmin(address admin_addr) public
	{
		if(msg.sender != owner)
		{
			require(msg.sender == master);
		}

		admins[admin_addr] = false;
	}

	function setOracle(address addr, string memory info, uint8 oracle_type, bool status) public
	{
		require(admins[msg.sender]);

		require(addr != address(0));

		Oracle memory oracle = Oracle(info, oracle_type, status, true, addr);

		uint index = oracles.push(oracle);

		oracles_index[addr] = index;

//		voters_proj[addr] = address[];
	}


	function linkOracle(address addr, address proj) public
	{
		require(admins[msg.sender]);

		require(addr != address(0));

		require(proj != address(0));

//		require(voters[addr].setted);

//		if(!proj_voters[proj])
//		{
//			proj_voters[proj] =
//		}

		proj_oracles[proj].push(addr);
//		voter_projs[addr].push(addr);
	}


	function getProjOracles(address proj, uint page) external view returns (address[] memory data)
	{
		data = new address[](PAGE_SIZE);

		uint256 start = page * PAGE_SIZE;

		for(uint256 i = 0; i < PAGE_SIZE; i++)
		{
			if(start + i < proj_oracles[proj].length)
			{
				data[i] = proj_oracles[proj][i];
			}
		}
	}


	function getOracles(uint page) external view returns (address[] memory data, uint8[] memory types, bool[] memory statuses)
	{
		data = new address[](PAGE_SIZE);
		types = new uint8[](PAGE_SIZE);
		statuses = new bool[](PAGE_SIZE);

		uint256 start = page * PAGE_SIZE;

		for(uint256 i = 0; i < PAGE_SIZE; i++)
		{
			if(start + i < oracles.length)
			{
				data[i] = oracles[i].addr;
				types[i] = oracles[i].oracle_type;
				statuses[i] = oracles[i].status;
			}
		}
	}


	function vote(uint proposal) public
	{
//		Voter storage sender = voters[msg.sender];
//		require(sender.weight != 0, "Has no right to vote");
//		require(!sender.voted, "Already voted.");
//		sender.voted = true;
//		sender.vote = proposal;

//		proposals[proposal].voteCount += sender.weight;
	}

	function winningProposal() public view
	returns (uint winningProposal_)
	{
		uint winningVoteCount = 0;
		for (uint p = 0; p < proposals.length; p++)
		{
			if (proposals[p].voteCount > winningVoteCount)
			{
				winningVoteCount = proposals[p].voteCount;

				winningProposal_ = p;
			}
		}
	}

	function winnerName() public view
	returns (bytes32 winnerName_)
	{
//		winnerName_ = proposals[winningProposal()].name;
	}

	function set_master(address new_master) public onlyOwner
	{
		require(new_master != address(0));
//		emit MastershipTransferred(master, new_master);
		master = new_master;
	}
}