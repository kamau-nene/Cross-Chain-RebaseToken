// SPDX-License-Identifier:MIT
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity  solidity ^0.8.18;

import {IRebaseToken} from "./interfaces/IRebaseToken.sol";

contract Vault{

    IRebaseToken private immutable i_rebaseToken;

    event Deposit(address indexed user, uint256 amount);
    event Redeem(address indexed user, uint256 amount);
    error VAULT__REDEEMFAILED(address user, uint256 amount);

    constructor(IRebaseToken _rebaseToken){
        i_rebaseToken = _rebaseToken;
    }

    receive() external payable {
        // Allow the contract to receive Ether
    }
    /**
     * @notice This function allows users to deposit Ether into the vault and receive rebase tokens in return.
     */
    function deposit() external payable {
        i_rebaseToken.mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }
    /**
     * @notice This function allows users to redeem their rebase tokens for Ether. The user must have enough rebase tokens to redeem the specified amount of Ether.
     * @param _amount The amount of Ether to redeem.
     */
    function redeem(uint256 _amount) external{
        i_rebaseToken.burn(msg.sender, _amount);
        (bool success) = payable(msg.sender).call{value: _amount}("");
        if(!success){
            revert VAULT__REDEEMFAILED(msg.sender, _amount);
        }
        emit Redeem(msg.sender, _amount);
    }

    function getRebaseTokenAddress() external view returns (address){
        return address(i_rebaseToken);

    }
}