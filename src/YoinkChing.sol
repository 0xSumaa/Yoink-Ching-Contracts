// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract YoinkChing {
    uint256 public constant HODL_TIME_TO_WIN = 86400; // 24 hours
    uint256 public constant YOINK_COST = 10 ether; // 10 MOXIE
    uint256 public constant MIN_START_SIZE = 50000 ether; // 50,000 MOXIE
    address public moxieAddress;
    uint256 public lastYoinked;
    address public lastYoinker;
    // includes the game in progress
    uint256 public gamesPlayed;
    uint256 public numberOfYoinks;

    event GameStarted(address indexed starter, uint256 blockTimestamp);
    event GameWon(address indexed winner, uint256 prize);
    event Yoinked(address indexed yoinker, uint256 blockTimestamp);

    constructor(address _moxieAddress) {
        require(_moxieAddress != address(0), "invalid moxie address");
        moxieAddress = _moxieAddress;
    }

    function startGame(uint256 _initBalance) external {
        require(
            _initBalance >= MIN_START_SIZE,
            "must start with at least 10 MOXIE"
        );
        require(
            lastYoinked == 0 && lastYoinker == address(0),
            "game already started"
        );
        IERC20(moxieAddress).transferFrom(
            msg.sender,
            address(this),
            _initBalance
        );
        _setStartGameState();
    }

    function yoink() external {
        require(
            lastYoinked != 0 && lastYoinker != address(0),
            "game not started"
        );
        if (_checkIfWon()) {
            address winner = lastYoinker;
            _setEndGameState();
            uint256 winnings = IERC20(moxieAddress).balanceOf(address(this));
            IERC20(moxieAddress).transfer(winner, winnings);
            return;
        }
        _setYoinkState();
        IERC20(moxieAddress).transferFrom(
            msg.sender,
            address(this),
            YOINK_COST
        );
    }

    function _checkIfWon() internal view returns (bool) {
        return lastYoinked + HODL_TIME_TO_WIN <= block.timestamp;
    }

    function _setStartGameState() internal {
        lastYoinked = block.timestamp;
        lastYoinker = msg.sender;
        gamesPlayed++;
        emit GameStarted(msg.sender, block.timestamp);
    }

    function _setEndGameState() internal {
        lastYoinked = 0;
        lastYoinker = address(0);
        numberOfYoinks = 0;
        emit GameWon(lastYoinker, block.timestamp);
    }

    function _setYoinkState() internal {
        lastYoinked = block.timestamp;
        lastYoinker = msg.sender;
        numberOfYoinks++;
        emit Yoinked(msg.sender, block.timestamp);
    }
}
