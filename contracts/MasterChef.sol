pragma solidity ^0.8.0;

import './math/SafeMath.sol';
import './token/BEP20/IBEP20.sol';
import './token/BEP20/SafeBEP20.sol';
import './access/Ownable.sol';

import "./WagyuToken.sol";
import "./SauceBar.sol";

interface IMigratorChef {
    function migrate(IBEP20 token) external returns (IBEP20);
}

contract MasterChef is Ownable {

    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of WAGYUes
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accWagyuPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accWagyuPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. WAGYUes to distribute per block.
        uint256 lastRewardBlock;  // Last block number that WAGYUes distribution occurs.
        uint256 accWagyuPerShare; // Accumulated WAGYUes per share, times 1e12. See below.
    }

    // The WAGYU TOKEN!
    WagyuToken public wagyu;
    // The SAUCE TOKEN!
    SauceBar public sauce;
    // Dev address.
    address public devaddr;
    // WAGYU tokens created per block.
    uint256 public wagyuPerBlock;
    // Bonus muliplier for early wagyu makers.
    uint256 public BONUS_MULTIPLIER = 1;
    // The migrator contract. It has a lot of power. Can only be set through governance (owner).
    IMigratorChef public migrator;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when WAGYU mining starts.
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        WagyuToken _wagyu,
        SauceBar _sauce,
        address _devaddr,
        uint256 _wagyuPerBlock,
        uint256 _startBlock
    ) {
        wagyu = _wagyu;
        sauce = _sauce;
        devaddr = _devaddr;
        wagyuPerBlock = _wagyuPerBlock;
        startBlock = _startBlock;

        // staking pool
        poolInfo.push(PoolInfo({
        lpToken : _wagyu,
        allocPoint : 1000,
        lastRewardBlock : startBlock,
        accWagyuPerShare : 0
        }));

        totalAllocPoint = 1000;

    }

    function updateMultiplier(uint256 multiplierNumber) public onlyOwner {
        BONUS_MULTIPLIER = multiplierNumber;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IBEP20 _lpToken, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
        lpToken : _lpToken,
        allocPoint : _allocPoint,
        lastRewardBlock : lastRewardBlock,
        accWagyuPerShare : 0
        }));
        updateStakingPool();
    }

    // Update the given pool's WAGYU allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint.sub(prevAllocPoint).add(_allocPoint);
            updateStakingPool();
        }
    }

    function updateStakingPool() internal {
        uint256 length = poolInfo.length;
        uint256 points = 0;
        for (uint256 pid = 1; pid < length; ++pid) {
            points = points.add(poolInfo[pid].allocPoint);
        }
        if (points != 0) {
            points = points.div(3);
            totalAllocPoint = totalAllocPoint.sub(poolInfo[0].allocPoint).add(points);
            poolInfo[0].allocPoint = points;
        }
    }

    // Set the migrator contract. Can only be called by the owner.
    function setMigrator(IMigratorChef _migrator) public onlyOwner {
        migrator = _migrator;
    }

    // Migrate lp token to another lp contract. Can be called by anyone. We trust that migrator contract is good.
    function migrate(uint256 _pid) public {
        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IBEP20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IBEP20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending WAGYUes on frontend.
    function pendingWagyu(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accWagyuPerShare = pool.accWagyuPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 wagyuReward = multiplier.mul(wagyuPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accWagyuPerShare = accWagyuPerShare.add(wagyuReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accWagyuPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 wagyuReward = multiplier.mul(wagyuPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        wagyu.mint(devaddr, wagyuReward.div(10));
        wagyu.mint(address(sauce), wagyuReward);
        pool.accWagyuPerShare = pool.accWagyuPerShare.add(wagyuReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterChef for WAGYU allocation.
    function deposit(uint256 _pid, uint256 _amount) public {

        require(_pid != 0, 'deposit WAGYU by staking');

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accWagyuPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                safeWagyuTransfer(_msgSender(), pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(_msgSender()), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accWagyuPerShare).div(1e12);
        emit Deposit(_msgSender(), _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {

        require(_pid != 0, 'withdraw WAGYU by unstaking');
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        require(user.amount >= _amount, 'withdraw: not good');

        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accWagyuPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            safeWagyuTransfer(_msgSender(), pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(_msgSender()), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accWagyuPerShare).div(1e12);
        emit Withdraw(_msgSender(), _pid, _amount);
    }

    // Stake WAGYU tokens to MasterChef
    function enterStaking(uint256 _amount) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][_msgSender()];
        updatePool(0);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accWagyuPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                safeWagyuTransfer(_msgSender(), pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(_msgSender()), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accWagyuPerShare).div(1e12);

        sauce.mint(_msgSender(), _amount);
        emit Deposit(_msgSender(), 0, _amount);
    }

    // Withdraw WAGYU tokens from STAKING.
    function leaveStaking(uint256 _amount) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][_msgSender()];
        require(user.amount >= _amount, 'withdraw: not good');
        updatePool(0);
        uint256 pending = user.amount.mul(pool.accWagyuPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            safeWagyuTransfer(_msgSender(), pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(_msgSender()), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accWagyuPerShare).div(1e12);

        sauce.burn(_msgSender(), _amount);
        emit Withdraw(_msgSender(), 0, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        pool.lpToken.safeTransfer(address(_msgSender()), user.amount);
        emit EmergencyWithdraw(_msgSender(), _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    // Safe wagyu transfer function, just in case if rounding error causes pool to not have enough WAGYUes.
    function safeWagyuTransfer(address _to, uint256 _amount) internal {
        sauce.safeWagyuTransfer(_to, _amount);
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(_msgSender() == devaddr, 'dev: wut?');
        devaddr = _devaddr;
    }
}
