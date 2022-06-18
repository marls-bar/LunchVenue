// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.8.00 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/LunchVenue.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract LunchVenueTest is LunchVenue {

    address acc0;
    address acc1;

    function beforeAll() public {
        acc0 = TestsAccounts.getAccount(0);
        acc1 = TestsAccounts.getAccount(1);
    }

    function managerTest() public {
        Assert.equal(manager, acc0, 'Manager should be acc0');
    }

    function setLunchVenue() public {
        Assert.equal(addVenue('Courtyard Cafe'), 1, 'Should be equal to 1');
        Assert.equal(addVenue('Uni Cafe'), 2, 'Should be equal to 2');
    }

    /// #sender: account-1
    function setLunchVenueFailure () public {
        try this.addVenue('Atomic Cafe') returns ( uint v) {
            Assert.ok(false, 'Mblah');
        } catch Error(string memory reason) {
            Assert.equal(reason, 'blah1', 'blah');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'Failed blah');
        }
    } 


}
    