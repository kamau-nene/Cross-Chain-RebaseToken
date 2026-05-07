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

    uint256 private constant PRECISIONFACTOR = 1e18;
    uint256 private s_interestRate = 5e18;
    mapping (address => uint256) private  s_userInterestRate;
    mapping (address => uint256) private s_userLastUpdatedTimestamp

    event InterestRateSet(uint256 newInterestRate);

    constructor()ERC20 ("RebaseToken", "RBT") {
        function setInterestRate(uint256 _newInterestRate) external {
            if(_newInterestRate < s_interestRate){
                revert RebaseToken__InterestRateCanOnlyDecrease(s_interestRate, _newInterestRate);
            }
            s_interestRate= _newInterestRate;
            emit InterestRateSet(_newInterestRate);
        }
        function principleBalanceOf (address _user) external view returns (uint256){
            return super.balanceOf(_user);
        }
        function mint(address _to, uint256 _amount) external {
            _mintAccuruedInterest(_to);
            s_userInterestRate[_to]= s_interestRate;
            s_userLastUpdatedTimestamp[_to] = block.timestamp;
            _mint(_to, _amount);
        }
        function burn(address _from, uint256 _amount) external {
            if(_amount == type(uint256).max){
                _amount = balanceOf(_from);
            }
            _mintAccruedInterest(_from);
            _burn(_from, _amount);
        }
        function balanceOf(address _user) public view returns(uint256){
            return super.balanceOf(_user) * _calculateUserAccumulatedInterestSinceLastUpdate(_user) / PRECISIONFACTOR;

        }
        function transfer(address _recipient, uint256 _amount ) public override returns (bool){
           _mintAccruedInterest(msg.sender);
           _mintAccruedInterest(_recipient);
           if(_amount == type(uint256).max){
                _amount = balanceOf(msg.sender);
           }
           if(balanceOf(_recipient) == 0){
            s_userIntersetRate[_recipient] = s_interestRate;
           }
           return super.transfer(_recipient, _amount);
        }
        function transferFrom(address _sender, address _recipient, uint256 _amount) public override returns (bool){
            _mintAccruedInterest(_sender);
            _mintAccruedInterest(_recipient);
            if(_amount == type(uint256).max){
                _amount = balanceOf(_sender);
            }
            if(balanceOf(_recipient) == 0){
                s_userIntersetRate[_recipient] = s_interestRate[_sender];
            }
            return super.transferFrom(_sender, _recipient, _amount);
        }
            
        function _calculateUserAccumulatedInterestSinceLastUpdate(address _user) internal view returns (uint256 linearInterest){
            uint256 timeElapsed = block.timestamp - s_userLastUpdatedTimestamp[_user];
            uint256 linearInterest = PRECISIONFACTOR + (s_userInterestRate[_user] * timeElapsed);
        }
        function _mintAccruedInterest(address _user) internal{
            uint256 PreviousPrincipleBalance = super.balanceOf(_user);
            uint256 currentBalance = balanceOf(_user);
            uint256 balanceIncrease = currentBalance - previousPrincipleBalance;

            s_userLastUpdatedTimestamp[_user] = block.timestamp;
            _mint (_user, balanceIncrease);

        }
        function getIntersetRate() external view returns (uint256){
            return s_interestRate;
        }

        function getUserInterestRate(address _user) external view returns (uint256){
            return s_userInterestRate[_user];
        }
    }
  }