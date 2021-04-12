pragma solidity ^0.5.9 < 0.7.0;

interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
	
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    
 
}

library Address {
  
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract LPTokenWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public y ; //Token

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
	
	constructor (IERC20 ierc20) internal {
	    y = ierc20;
	}
	
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) public {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        y.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        y.safeTransfer(msg.sender, amount);
    }
}

contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract PoolReward is LPTokenWrapper,owned{
	uint256 public constant oneday = 1 days;
    IERC20 public rewardtoken = IERC20(0); 
    uint256[] public durations;
    uint256[] public initrewards;
	uint256[] public durationRewards;
    uint256 public starttime = 0; 
    uint256 public endtime = 0;
    uint256[] public durationEndtimes ;
	uint256 public lastUpdateTime = 0;
    uint256 public rewardPerTokenStored = 0;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
	address private ecoAddr = 0x000000000000000000000000000000000000dEaD;
	address private teamAddr = 0x000000000000000000000000000000000000dEaD;
	address private destroyAddr = 0x000000000000000000000000000000000000dEaD;
	uint256 private destroyRatio = 10;
	uint256 private ecoRatio = 10;
	uint256 private teamRatio = 5;
    event Staked(address indexed addr, uint256 amount);
    event Withdrawn(address indexed addr, uint256 amount);
    event UserRewardPaid(address indexed addr, uint256 reward);
	event EcoRewardPaid(address indexed addr, uint256 reward);
	event TeamRewardPaid(address indexed addr, uint256 reward);
	event DestroyRewardPaid(address indexed addr, uint256 reward);

	constructor(address _ecoAddr,address _teamAddr,address _lptoken,address _rewardtoken,uint256 _starttime,uint256[] memory _initrewards,uint256[] memory _durations) LPTokenWrapper(IERC20(_lptoken)) public{
	    require (_initrewards.length > 0 &&_initrewards.length == _durations.length,"length not match");
		ecoAddr = _ecoAddr;
		teamAddr = _teamAddr;
		rewardtoken = IERC20(_rewardtoken);
	    starttime = _starttime;
		lastUpdateTime = starttime;
		endtime = starttime;
		for(uint256 i = 0; i < _initrewards.length;i++){
			initrewards.push(_initrewards[i]);
			durations.push(_durations[i].mul(oneday));
			durationRewards.push(initrewards[i].div(durations[i]));
			durationEndtimes.push(endtime.add(durations[i]));
			endtime = durationEndtimes[i];
	    }	
	}
	
	function setAddrs(address _ecoAddr,address _teamAddr) onlyOwner public {
		require(_ecoAddr!=address(0)&&_teamAddr!=address(0));
		ecoAddr = _ecoAddr;
		teamAddr = _teamAddr;
    }
	
	modifier updateReward(address account) {
		if(lastTimeRewardApplicable() > starttime && totalSupply() != 0){
			rewardPerTokenStored = rewardPerToken();
			lastUpdateTime = lastTimeRewardApplicable();
			if (account != address(0)) {
				rewards[account] = earned(account);
				userRewardPerTokenPaid[account] = rewardPerTokenStored;
			}
		}
        _;
    }
	
	
    function lastTimeRewardApplicable() public view returns (uint256) {
	
        return Math.min(block.timestamp, endtime);
    }
	
	function rewardPerToken() public view returns (uint256) {
        uint256 i = 0;
		uint256 j = 0;
		uint256 rewardPerTokenTmp = rewardPerTokenStored;
		uint256 blockLastTime = lastTimeRewardApplicable();
		if ((blockLastTime < starttime) || (totalSupply() == 0) ) {
            return rewardPerTokenTmp;
        }
		
		for( i = 0 ;i < durationEndtimes.length;i++){
			if( blockLastTime <= durationEndtimes[i])
				break;
		}
		
		for( j = 0 ;j < durationEndtimes.length;j++){
			if(lastUpdateTime <= durationEndtimes[j])
				break;
		}
		
		if(j == i){
			return rewardPerTokenTmp.add(
				blockLastTime
				.sub(lastUpdateTime)
				.mul(durationRewards[i])
				.mul(1e18)
				.div(totalSupply())
			);
		}else{
			
			rewardPerTokenTmp = rewardPerTokenTmp.add(
						durationEndtimes[j]
						.sub(lastUpdateTime)
						.mul(durationRewards[j])
						.mul(1e18)
						.div(totalSupply())
				);
			for(uint256 k = j+1; k < i; k++){
				rewardPerTokenTmp = rewardPerTokenTmp.add(
						durationEndtimes[k]
						.sub(durationEndtimes[k-1])
						.mul(durationRewards[k])
						.mul(1e18)
						.div(totalSupply()));
			}
			return rewardPerTokenTmp.add(
						blockLastTime
						.sub(durationEndtimes[i-1])
						.mul(durationRewards[i])
						.mul(1e18)
						.div(totalSupply())
				);	
		}
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function stake(uint256 amount) public updateReward(msg.sender) { 
        require(amount > 0, "Cannot stake 0");
        super.stake(amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public  updateReward(msg.sender)  {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
			uint256 userReward = reward.mul(100-destroyRatio-ecoRatio-teamRatio).div(100);
			uint256 destroyReward = reward.mul(destroyRatio).div(100);
			uint256 ecoReward = reward.mul(ecoRatio).div(100);
			uint256 teamReward = reward.mul(teamRatio).div(100);
            rewardtoken.safeTransfer(msg.sender, userReward);
			rewardtoken.safeTransfer(destroyAddr, destroyReward);
			rewardtoken.safeTransfer(ecoAddr,ecoReward);
			rewardtoken.safeTransfer(teamAddr, teamReward);
            emit UserRewardPaid(msg.sender, userReward);
			emit DestroyRewardPaid(destroyAddr, destroyReward);
			emit EcoRewardPaid(ecoAddr, ecoReward);
			emit TeamRewardPaid(teamAddr, teamReward);
        }
    }
}