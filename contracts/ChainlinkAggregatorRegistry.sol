// SPDX-License-Identifier: MIT

pragma solidity 0.8.2;

import "OpenZeppelin/openzeppelin-contracts@4.1.0/contracts/access/AccessControl.sol";

/// @title Chainlink Adapter Registry
/// @author Sawit Trisirisatayawong (@tansawit)
contract ChainlinkAggregatorRegistry is AccessControl {
    enum AggregatorType {
        USD,
        Native
    }

    AggregatorType public constant nativeType = AggregatorType.Native;
    AggregatorType public constant usdType = AggregatorType.USD;

    bytes32 public constant MAPPER_ROLE = keccak256("MAPPER_ROLE");

    mapping(address => address) addressToUSDAggregator;
    mapping(address => address) addressToNativeAggregator;

    constructor() public {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MAPPER_ROLE, msg.sender);
    }

    /// @notice Set an aggregator address for a given token address and Aggregator type
    /// @dev aggregatorType can either be Native (ETH for Ethereum, BNB for BSC, etc.) or USD
    /// @param aggregatorType type of aggregator to set. Either USD (1), or Native (0)
    /// @param tokenAddress token contract address to set mapping for
    /// @param aggregatorAddress Chainlink aggregator contract that corresponds to the token address and aggregator type
    function setAggregator(
        address tokenAddress,
        address aggregatorAddress,
        AggregatorType aggregatorType
    ) external {
        require(hasRole(MAPPER_ROLE, msg.sender), "NOT_A_MAPPER");
        if (aggregatorType == nativeType) {
            addressToNativeAggregator[tokenAddress] = aggregatorAddress;
        } else {
            addressToUSDAggregator[tokenAddress] = aggregatorAddress;
        }
    }

    /// @notice get the Chainlink aggregator contract address for a given token address and aggregator type
    /// @dev aggregatorType can either be Native (ETH for Ethereum, BNB for BSC, etc.) or USD
    /// @param aggregatorType type of aggregator to query for. type of aggregator to set. Either USD (1), or Native (0)
    /// @param tokenAddress token contract address to query the aggregator address for
    function getAggregator(address tokenAddress, AggregatorType aggregatorType)
        external
        view
        returns (address aggregatorAddress)
    {
        if (aggregatorType == nativeType) {
            aggregatorAddress = addressToNativeAggregator[tokenAddress];
        } else {
            aggregatorAddress = addressToUSDAggregator[tokenAddress];
        }

        require(aggregatorAddress != address(0), "token-not-supported");
        return aggregatorAddress;
    }
}
