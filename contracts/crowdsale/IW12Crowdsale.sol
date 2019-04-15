pragma solidity ^0.5.0;

import "../token/IWToken.sol";


interface IW12Crowdsale {
    function setParameters(uint price) external;

    // TODO: this should be external
    // See https://github.com/ethereum/solidity/issues/4832
    function setup(
        uint[6][] calldata parametersOfStages,
        uint[] calldata bonusConditionsOfStages,
        uint[4][] calldata parametersOfMilestones,
        uint32[] calldata nameAndDescriptionsOffsetOfMilestones,
        bytes calldata nameAndDescriptionsOfMilestones,
        bytes32[] calldata paymentMethodsList
    ) external;

    function getWToken() external view returns(IWToken);

    function getMilestone(uint index) external view returns (uint32, uint, uint32, uint32, bytes memory , bytes memory);

    function getStage(uint index) external view returns (uint32, uint32, uint, uint32, uint[] memory, uint[] memory);

    function getCurrentMilestoneIndex() external view returns (uint, bool);

    function getLastMilestoneIndex() external view returns (uint index, bool found);

    function milestonesLength() external view returns (uint);

    function getCurrentStageIndex() external view returns (uint index, bool found);

    function getSaleVolumeBonus(uint value) external view returns (uint bonus);

    function isEnded() external view returns (bool);

    function isSaleActive() external view returns (bool);

    function buyTokens(bytes32 method, uint amount) payable external;

    function transferPrimary(address _address) external;
}
