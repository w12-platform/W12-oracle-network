pragma solidity ^0.5.3;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';


contract OracleBallot is Ownable
{

	struct Voter
	{
		uint weight;
		bool voted;
		address addr;
		uint vote;

	}


	struct StageBallot
	{
		address project_addr;
		uint stage_index;
		uint voteCount;
	}

	address public master;

	mapping(address => Voter) public voters;


	StageBallot[] public proposals;


	constructor(bytes32[] memory proposalNames) public
	{

		master = msg.sender;
		voters[master].weight = 1;

		for (uint i = 0; i < proposalNames.length; i++)
		{
			proposals.push(StageBallot(
				{
					name : proposalNames[i],
					voteCount : 0
				}));
		}
	}

	function vote(uint proposal) public
	{
		Voter storage sender = voters[msg.sender];
		require(sender.weight != 0, "Has no right to vote");
		require(!sender.voted, "Already voted.");
		sender.voted = true;
		sender.vote = proposal;

		proposals[proposal].voteCount += sender.weight;
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
		winnerName_ = proposals[winningProposal()].name;
	}

	function set_master(address new_master) public onlyOwner
	{
		require(new_master != address(0));
		emit MastershipTransferred(master, new_master);
		master = new_master;
	}
}