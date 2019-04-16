pragma solidity ^0.5.0;


import "../openzeppelin-solidity/contracts/ownership/Secondary.sol";
import "../openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "../openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "../openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "./crowdsale/IW12Crowdsale.sol";
import "./crowdsale/IW12Fund.sol";
import "./rates/IRates.sol";
import "./libs/Percent.sol";
import "./libs/PaymentMethods.sol";
import "./libs/PurchaseProcessing.sol";
import "./libs/Crowdsale.sol";
import "./versioning/Versionable.sol";
import "./token/IWToken.sol";



contract W12Crowdsale
{
    using SafeMath for uint;
    using SafeMath for uint8;
    using Percent for uint;
    using PaymentMethods for PaymentMethods.Methods;

    IWToken public token;
    IERC20 public originToken;
    IW12Fund public fund;
    IRates public rates;
    uint public price;
    uint public serviceFee;
    uint public WTokenSaleFeePercent;
    address public serviceWallet;
    address public swap;

    PaymentMethods.Methods paymentMethods;

    Crowdsale.Stage[] public stages;
    Crowdsale.Milestone[] public milestones;

    event TokenPurchase(address indexed buyer, uint tokensBought, uint cost, uint change);
    event StagesUpdated();
    event StageUpdated(uint index);
    event MilestonesUpdated();
    event CrowdsaleSetUpDone();
    event UnsoldTokenReturned(address indexed owner, uint amount);

    function stagesLength() external view returns (uint);
    function milestonesLength() external view returns (uint);
    function getMilestone(uint) public view returns (uint32, uint, uint32, uint32, bytes memory, bytes memory);
    function getStage(uint) public view returns (uint32, uint32, uint, uint32, uint[] memory, uint[] memory);
    function getEndDate() external view returns (uint32);
    function getCurrentMilestoneIndex() public view returns (uint, bool);
    function getLastMilestoneIndex() public view returns (uint, bool);
    function __setParameters(uint, address) internal;
    function setParameters(uint) external;
    function setup(uint[6][] calldata, uint[] calldata, uint[4][] calldata, uint32[] calldata, bytes calldata, bytes32[] calldata) external;
    function _setStages(uint[6][] memory, uint[] memory) internal;
    function _setMilestones(uint[4][] memory, uint32[] memory, bytes memory) internal;
    function buyTokens(bytes32 method, uint amount) payable public;
    function _transferFee(uint[2] memory, bytes32) internal;
    function _transferPurchase(uint[5] memory, uint[2] memory, uint32, bytes32) internal;
    function _recordPurchase(uint[5] memory, uint[2] memory, bytes32) internal;
    function getWToken() external view returns(IWToken);
    function getFund() external view returns(IW12Fund);
    function getPaymentMethodsList() external view returns(bytes32[] memory);
    function isPaymentMethodAllowed(bytes32) external view returns (bool);
    function getInvoice(bytes32, uint) public view returns (uint[5] memory);
    function _getInvoiceLastArguments(bytes32) internal view returns(uint[5] memory);
    function getInvoiceByTokenAmount(bytes32, uint) public view returns (uint[4] memory);
    function _getInvoiceByTokenAmountLastArguments(bytes32) internal view returns (uint[5] memory);
    function getFee(uint, uint) public view returns(uint [2] memory);
    function getSaleVolumeBonus(uint value) public view returns(uint);
    function getCurrentStageIndex() public view returns (uint, bool);
    function claimRemainingTokens() external;
    function isEnded() public view returns (bool);
    function isSaleActive() public view returns (bool);
}


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

	struct Vote
	{
		address voter;
		bool vote_y;
	}

	address public master;
	mapping(address => bool) public admins;

	Oracle[] public oracles;
	mapping(address => uint) public oracles_index;

	mapping(address => address[]) public proj_oracles;
	mapping(address => mapping(address => uint)) public proj_oracles_index;

	mapping(address => mapping(uint => Vote[])) public vote_data;


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

	event Log(address from, uint len);


	function linkOracle(address addr, address proj) public
	{
		require(admins[msg.sender]);

		require(addr != address(0));

		uint index = oracles_index[addr];


		require(index != 0);

		require(proj != address(0));

		uint p_index = proj_oracles_index[proj][addr];

		emit Log(proj, p_index);

		if(p_index == 0)
		{
			proj_oracles_index[proj][addr] = proj_oracles[proj].push(addr);

			emit Log(proj, proj_oracles_index[proj][addr]);
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

		uint start = page * PAGE_SIZE;

		uint index;

		for(uint i = 0; i < PAGE_SIZE; i++)
		{
			if(start + i < proj_oracles[proj].length)
			{
				data[i] = proj_oracles[proj][start + i];
				index = oracles_index[data[i]];
				if(index != 0)
				{
					types[i] = oracles[index - 1].oracle_type;
					statuses[i] = oracles[index - 1].status;
				}
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

	event Log(address from);

	function vote(address crowdsale_addr, uint milestone_index, bool vote_y) public
	{
		bytes memory name;
		bytes memory desc;
		uint32 end_date;
		uint percent;
		uint32 vote_end;
		uint32 withdrawal;

		W12Crowdsale sale = W12Crowdsale(crowdsale_addr);

		address token = address(sale.getWToken());

		require(proj_oracles_index[token][msg.sender] != 0);

		uint index = oracles_index[msg.sender];

		require(oracles[index].status);

		bool vote_flag = false;

		for(uint i = 0; i < vote_data[token][milestone_index].length; i++)
		{
			if(vote_data[token][milestone_index][i].voter == msg.sender)
			{
				vote_flag = true;
			}
		}

		require(!vote_flag);

		(end_date, percent, vote_end, withdrawal, name, desc) = sale.getMilestone(milestone_index);

//		require(now > end_date);
//		require(now <= vote_end);

		vote_data[token][milestone_index].push(Vote(msg.sender, vote_y));

//		emit Log(token);
	}


	function get_vote_result(address crowdsale_addr, uint milestone_index) public view returns(uint vote_y, uint vote_n, uint vote_all)
	{
		W12Crowdsale sale = W12Crowdsale(crowdsale_addr);

		address token = address(sale.getWToken());

		for(uint i = 0; i < vote_data[token][milestone_index].length; i++)
		{
			if(vote_data[token][milestone_index][i].vote_y)
			{
				vote_y++;
			}
			else
			{
				vote_n++;
			}
		}

		vote_all = proj_oracles[token].length;
	}




	function set_master(address new_master) public onlyOwner
	{
		require(new_master != address(0));
//		emit MastershipTransferred(master, new_master);
		master = new_master;
	}
}