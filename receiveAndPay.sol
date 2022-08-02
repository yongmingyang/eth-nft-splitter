// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

abstract contract A { // This doesn't have to match the real contract name. Call it what you like.
   function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public virtual; // No implementation, just the function signature. This is just so Solidity can work out how to call it.
}

// contract YourContract {
//   function doYourThing(address addressOfA) returns(uint) {
//     A my_a = A(addressOfA);
//     return my_a.f1(true, 3);
//   }
// }

contract ReceiveAndPay is ERC1155Holder { // contract addr: 0x4b5Ee26Bd2533bB2Db4Df430496039aD2a9050fb
    address payable public receipientAddr1;
    address payable public receipientAddr2;
    uint256 public receipientAddr1Share;
    uint256 public receipientAddr2Share;
    uint256 public totalShare;
    uint256 public totalReceived;
    address public msgSender;
    bool public callSuccess;
    bytes public dataFromCall;

    constructor() {
        receipientAddr1 = payable(0xCF3F1Ea911CC96c6aE0406ed5087682aB1B3859e);
        receipientAddr2 = payable(0x0090Cd3e5C7805643920a1e6492334Bb2752374F);
        receipientAddr1Share = 50;
        receipientAddr2Share = 50;
        totalShare = 100;

    }

    receive() payable external {
        require(receipientAddr2Share + receipientAddr1Share <= totalShare, "Share more than 100%");
        if (msg.value > 100000000000000000) {
            msgSender = msg.sender;
            // 0x52FF80b0C767Ef546a21C61dE38d79024A0406f3 is the NFT contract address
            // 0xf38754DA0fF7630fC00Cc8A1B51502Ac5BE00efa is my wallet address

            totalReceived += msg.value;
            receipientAddr1.transfer(msg.value * receipientAddr1Share/totalShare);
            receipientAddr2.transfer(msg.value * receipientAddr2Share/totalShare);

            A myContract = A(0x52FF80b0C767Ef546a21C61dE38d79024A0406f3);
            return myContract.safeTransferFrom(address(this), 0xf38754DA0fF7630fC00Cc8A1B51502Ac5BE00efa, 1, 1, bytes('0x0'));
        }
        totalReceived += msg.value;
        receipientAddr1.transfer(msg.value * receipientAddr1Share/totalShare);
        receipientAddr2.transfer(msg.value * receipientAddr2Share/totalShare);
    }

    function changeAddr1Share(uint256 share) public {
        require(share <= totalShare, "share change rejected.");
        receipientAddr1Share = share;
        receipientAddr2Share = totalShare - receipientAddr1Share;
    }

    function changeAddr2Share(uint256 share) public {
        require(share <= totalShare, "share change rejected.");
        receipientAddr2Share = share;
        receipientAddr1Share = totalShare - receipientAddr2Share;
    }

    // function safeTransferFrom(address _contract, address _to) public {
    //     // (bool success, bytes memory data) = _contract.call(
    //         // abi.encodeWithSignature("safeTransferFrom(address, address, uint256, uint256, bytes)", address(this), _to, 1, 1, 0)
    //     // );

    //     A myContract = A(_contract);
    //     return myContract.safeTransferFrom(address(this), _to, 1, 1, bytes('0x0'));

    // }
}

