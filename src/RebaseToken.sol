//SPDX-License-Identifier: MIT
 pragma solidity ^0.8.18;

 import{ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

 /*
 * @title Rebase Token
 * @author David Nene
 * @notice This is a cross-chain rebase token that incentivises users to deposit into a vault and earn interest in rewards.
 * @notice The interest rate in the contract can only decrease 
 * @notice Each user will have  their own interest rate that is determined by the time they deposited into the vault 
  */  
 contract RebaseToken is ERC20{
    error RebaseToken__InterestRateCanOnlyDecrease(uint256 oldInterestRate, uint256 newInterestRate);

    uint256 private s_interestRate = 5e18;
    mapping (address => uint256) private  s_userInterestRate;

    event InterestRateSet(uint256 newInterestRate);

    constructor()ERC20 ("RebaseToken", "RBT") {
        function setInterestRate(uint256 _newInterestRate) external {
            if(_newInterestRate < s_interestRate){
                revert RebaseToken__InterestRateCanOnlyDecrease(s_interestRate, _newInterestRate);
            }
            s_interestRate= _newInterestRate;
            emit InterestRateSet(_newInterestRate);
        }
        function mint(address _to, uint256 _amount) external {
            _mint(_to, _amount);
        }
        function getUserInterestRate(address _user) external view returns (uint256){
            return s_userInterestRate[_user];
        }
    }
  }