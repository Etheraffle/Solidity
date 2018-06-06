pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/etheraffleFreeLOT.sol";

// Note this file name can't have hyphens or underscores in it.
// Attempt to rewrite these entire tests in JS too...

contract TestEtheraffleFreeLOT {

    /* Truffle's account[0] */
    address public owner = 0x627306090abaB3A6e1400e9345bC60c78a8BEf57;
    /* Truffle's account[1] */
    address public acc2  = 0xf17f52151EbEF6C7334FAD080c5704D77216b732;
    /* Truffle's account[2] */
    address public acc3  = 0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef;

    function testOwner() public {
        EtheraffleFreeLOT freeLOT = EtheraffleFreeLOT(DeployedAddresses.EtheraffleFreeLOT());
        Assert.equal(freeLOT.etheraffle(), owner, "Owner should be addr: '0x627...bef57'");
    }

    function testInitialBalance() public {
        EtheraffleFreeLOT freeLOT = EtheraffleFreeLOT(DeployedAddresses.EtheraffleFreeLOT());
        uint expected = 100;
        Assert.equal(freeLOT.balanceOf(owner), expected, "Owner should have intial balance of 100");
    }

    function testOwnerIsMinter() public {
        EtheraffleFreeLOT freeLOT = EtheraffleFreeLOT(DeployedAddresses.EtheraffleFreeLOT());
        bool expected = true;
        Assert.equal(freeLOT.isMinter(owner), expected, "Owner should be a minter!");
    }

    function testOwnerIsDestroyer() public {
        EtheraffleFreeLOT freeLOT = EtheraffleFreeLOT(DeployedAddresses.EtheraffleFreeLOT());
        bool expected = true;
        Assert.equal(freeLOT.isDestroyer(owner), expected, "Owner should be a destroyer!");
    }

    function testInitAmountEqualToTotalSupply() public {
        EtheraffleFreeLOT freeLOT = EtheraffleFreeLOT(DeployedAddresses.EtheraffleFreeLOT());
        Assert.equal(freeLOT.totalSupply(), freeLOT.balanceOf(owner), "Total supply should equal initial supply!");
    }

    // function testCanMint() public {
   
    // }

    // function testSecondAccountHas5() public {

    // }

    // function testCanDestroy() public {

    // }

    // function testSecondAccountHas2() public {

    // }

    // function testAddMinter() public {

    // }

    // function testIsNewMinter() public {
        
    // }

    // function testRemoveMinter() public {
        
    // }

    // function testIsNoLongerMinter() public {
        
    // }


    // function testNonOwnerCantAddMinter() public {
  
    // }

    // function testNonOwnerCantAddDestroyer() public {

    // }

    // function testCantMint() public {

    // }

    // function testCantDestroy() public {

    // }

}