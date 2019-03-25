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
	uint MAX_INFO = 512;
	uint MAX_TYPE = 5;

	struct Oracle
	{
		string info;
		uint8 oracle_type;
		bool status;
		address addr;
	}

	address public master;
	mapping(address => bool) public admins;

	Oracle[] public oracles;
	mapping(address => uint) public oracles_index;

	mapping(address => address[]) public proj_oracles;
	mapping(address => mapping(address => uint)) public proj_oracles_index;


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

		bytes memory str_b = bytes(info);

		require(str_b.length <= MAX_INFO);

		require(oracle_type <= MAX_TYPE);

		if(oracles_index[addr] == 0)
		{
			Oracle memory oracle = Oracle(info, oracle_type, status, addr);

			oracles_index[addr] = oracles.push(oracle);
		}
		else
		{
			uint index = oracles_index[addr] - 1;

			oracles[index].info = info;
			oracles[index].oracle_type = oracle_type;
			oracles[index].status = status;
		}
	}


	function linkOracle(address addr, address proj) public
	{
		require(admins[msg.sender]);

		require(addr != address(0));

		uint index = oracles_index[addr];

		require(index != 0);

		require(proj != address(0));

		uint p_index = proj_oracles_index[proj][addr];

		if(p_index == 0)
		{
			proj_oracles_index[proj][addr] = proj_oracles[proj].push(addr);
		}

	}


	function unlinkOracle(address addr, address proj) public
	{
		require(admins[msg.sender]);

		require(addr != address(0));

		uint index = oracles_index[addr];

		require(index != 0);

		require(proj != address(0));

		uint p_index = proj_oracles_index[proj][addr];

		require(p_index != 0);

		p_index = p_index - 1;

		proj_oracles[proj][p_index] = proj_oracles[proj][proj_oracles[proj].length - 1];

		proj_oracles[proj].length--;

		proj_oracles_index[proj][addr] = 0;
	}


	function getProjOracles(address proj, uint page) external view returns (address[] memory data, uint8[] memory types, bool[] memory statuses)
	{
		data = new address[](PAGE_SIZE);
		types = new uint8[](PAGE_SIZE);
		statuses = new bool[](PAGE_SIZE);

		uint256 start = page * PAGE_SIZE;

		uint index;

		for(uint256 i = 0; i < PAGE_SIZE; i++)
		{
			if(start + i < proj_oracles[proj].length)
			{
				data[i] = proj_oracles[proj][start + i];
				index = oracles_index[data[i]];
				require(index != 0);

				types[i] = oracles[index].oracle_type;
				statuses[i] = oracles[index].status;
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
				data[i] = oracles[start + i].addr;
				types[i] = oracles[start + i].oracle_type;
				statuses[i] = oracles[start + i].status;
			}
		}
	}


	function getOracle(uint index) external view returns (string memory info, uint8 oracle_type, bool status)
	{
		require(index < oracles.length);
		require(index > 0);

		info = oracles[index].info;
		oracle_type = oracles[index].oracle_type;
		status = oracles[index].status;
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