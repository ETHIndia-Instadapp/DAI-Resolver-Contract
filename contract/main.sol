pragma solidity ^0.4.24;

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

interface token {
    // function transfer(address receiver, uint amount) external returns(bool);
    // function balanceOf(address who) external returns(uint256);
    function approve(address spender, uint256 value) external returns (bool);
}

interface CDPoperation {
    function open() external returns (bytes32 cup);
    function join(uint wad) external; // Join PETH
    function give(bytes32 cup, address guy) external;
    function lock(bytes32 cup, uint wad) external;
    function free(bytes32 cup, uint wad) external;
    function draw(bytes32 cup, uint wad) external;
    function wipe(bytes32 cup, uint wad) external;
    function shut(bytes32 cup) external;
    function bite(bytes32 cup) external;
}

contract ContractCDP {

    address public admin;
    address public CDPAddr = 0xa71937147b55Deb8a530C7229C442Fd3F31b7db2;
    CDPoperation DAILoanMaster = CDPoperation(0xa71937147b55Deb8a530C7229C442Fd3F31b7db2);

    struct Loan {
        address Borrower; // customer
        uint Collateral; // locked ETH
        uint Withdrawn; // withdrawn DAI
    }

    mapping (address => Loan) public Loans;
    uint public TotalLocked; // ETH

    constructor(bytes32 bCode) public {
        admin = msg.sender;
    }

    bytes32 public CDPByteCode;
    function setCDPBytes(bytes32 bCode) public onlyAdmin { // with 0x as prefice
        CDPByteCode = bCode;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Permission Denied");
        _;
    }

    function openCDP() public {
        DAILoanMaster.open();
    }

    // send ether to contract address to lock ether
    function() public payable {
        Loan memory l = Loans[msg.sender];
        0xd0A1E359811322d97991E03f863a0C30C2cF029C.transfer(msg.value); // ETH to WETH
        DAILoanMaster.join(msg.value); // WETH to PETH
        DAILoanMaster.lock(CDPByteCode, msg.value); // Lock PETH in CDP Contract
        l.Collateral += msg.value;
    }

    // allowing WETH, PETH, MKR, DAI
    // WETH - 0xd0A1E359811322d97991E03f863a0C30C2cF029C
    // PETH - 0xf4d791139cE033Ad35DB2B2201435fAd668B1b64
    // MKR - 0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD
    // DAI - 0xC4375B7De8af5a38a93548eb8453a498222C4fF2
    function ApproveERC20(address tokenAddress) public {
        token tokenFunctions = token(tokenAddress);
        tokenFunctions.approve(CDPAddr, 2**256 - 1);
    }

}

//// Improvements
// instead of open CDP create CDP from individual address and give CDP
// add a give CDP option to transfer the CDP to another address