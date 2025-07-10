// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {DeployOurToken} from "script/DeployOurToken.s.sol";
import {OurToken} from "src/OurToken.sol";
// It's good practice to import the specific contract you're testing against.
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title OurTokenTest
/// @notice This contract contains a comprehensive suite of tests for the OurToken ERC20 contract.
/// It covers initial state, transfers, approvals, allowances, and various failure conditions.
contract OurTokenTest is Test {
    // --- Events ---
    // Define the events the test contract will be listening for.
    // This makes the `emit` keyword work with `vm.expectEmit`.
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // --- Errors ---
    // Define the custom errors from the ERC20 contract to make their selectors available for `vm.expectRevert`.
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    // --- State Variables ---
    OurToken public ourToken;
    DeployOurToken public deployer;

    // --- Users ---
    address internal deployerAddress;
    address internal bob = makeAddr("bob");
    address internal alice = makeAddr("alice");
    address internal charlie = makeAddr("charlie");

    // --- Constants ---
    // NOTE: We assume your `DeployOurToken.s.sol` script deploys the contract with this initial supply.
    // If your script uses a different value, please update this constant accordingly.
    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether;
    uint256 public constant STARTING_BALANCE_BOB = 100 ether;
    uint256 public constant SUPPLY = 1000 ether;

    /// @notice Sets up the testing environment before each test case.
    function setUp() public {
        // 1. Deploy the token contract
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        // In Foundry tests, `msg.sender` defaults to `address(this)`.
        // The `OurToken` constructor mints the `INITIAL_SUPPLY` to its `msg.sender`.
        // Therefore, the test contract itself is the initial owner of all tokens.
        deployerAddress = msg.sender;

        // 2. Fund Bob's account for testing purposes
        // We must prank the deployer to authorize the transfer.
        vm.prank(deployerAddress);
        ourToken.transfer(bob, STARTING_BALANCE_BOB);
    }

    // =========================================
    //      CONSTRUCTOR & METADATA TESTS
    // =========================================

    /// @notice Tests if the contract was deployed with the correct initial state.
    function testInitialState() public view {
        assertEq(ourToken.totalSupply(), SUPPLY, "Incorrect total supply");
        assertEq(string(ourToken.name()), "OurToken", "Incorrect token name");
        assertEq(string(ourToken.symbol()), "OT", "Incorrect token symbol");
        assertEq(ourToken.decimals(), 18, "Incorrect token decimals");
        assertEq(
            ourToken.balanceOf(deployerAddress),
            SUPPLY - STARTING_BALANCE_BOB,
            "Deployer should have the initial supply minus the amount sent to Bob"
        );
    }

    // =========================================
    //            TRANSFER TESTS
    // =========================================

    /// @notice Tests a successful token transfer.
    function testTransfer_Succeeds() public {
        uint256 amount = 10 ether;

        uint256 bobInitialBalance = ourToken.balanceOf(bob);
        uint256 aliceInitialBalance = ourToken.balanceOf(alice);

        vm.prank(bob);
        ourToken.transfer(alice, amount);

        assertEq(ourToken.balanceOf(bob), bobInitialBalance - amount, "Bob's balance should decrease");
        assertEq(ourToken.balanceOf(alice), aliceInitialBalance + amount, "Alice's balance should increase");
    }

    /// @notice Tests that a `Transfer` event is emitted on successful transfer.
    function testTransfer_EmitsTransferEvent() public {
        uint256 amount = 10 ether;
        vm.prank(bob);
        vm.expectEmit(true, true, true, true);
        emit Transfer(bob, alice, amount);
        ourToken.transfer(alice, amount);
    }

    /// @notice Tests that a transfer reverts if the sender has an insufficient balance.
    function testRevertIf_Transfer_InsufficientBalance() public {
        uint256 amount = STARTING_BALANCE_BOB + 1;
        vm.prank(bob);

        // The error is now defined in this contract.
        vm.expectRevert(abi.encodeWithSelector(ERC20InsufficientBalance.selector, bob, STARTING_BALANCE_BOB, amount));
        ourToken.transfer(alice, amount);
    }

    /// @notice Tests that a transfer to the zero address reverts.
    function testRevertIf_Transfer_ToZeroAddress() public {
        vm.prank(bob);
        // The error is now defined in this contract.
        vm.expectRevert(abi.encodeWithSelector(ERC20InvalidReceiver.selector, address(0)));
        ourToken.transfer(address(0), 1 ether);
    }

    // =========================================
    //      APPROVAL & ALLOWANCE TESTS
    // =========================================

    /// @notice Tests that `approve` correctly sets an allowance and emits an `Approval` event.
    function testApprove_SetsAllowanceAndEmitsEvent() public {
        uint256 amount = 1000;
        vm.prank(bob);

        vm.expectEmit(true, true, true, true);
        emit Approval(bob, alice, amount);
        ourToken.approve(alice, amount);

        assertEq(ourToken.allowance(bob, alice), amount, "Allowance was not set correctly");
    }

    /// @notice Tests that calling `approve` again correctly updates the allowance.
    function testApprove_CanUpdateAllowance() public {
        uint256 initialAllowance = 100;
        uint256 increasedAllowance = 150;
        uint256 decreasedAllowance = 70;

        // 1. Bob approves Alice for an initial amount.
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);
        assertEq(ourToken.allowance(bob, alice), initialAllowance, "Initial allowance is incorrect");

        // 2. Bob increases the allowance by calling approve again with a larger amount.
        vm.prank(bob);
        ourToken.approve(alice, increasedAllowance);
        assertEq(ourToken.allowance(bob, alice), increasedAllowance, "Allowance after increase is incorrect");

        // 3. Bob decreases the allowance by calling approve again with a smaller amount.
        vm.prank(bob);
        ourToken.approve(alice, decreasedAllowance);
        assertEq(ourToken.allowance(bob, alice), decreasedAllowance, "Allowance after decrease is incorrect");
    }

    // =========================================
    //          TRANSFERFROM TESTS
    // =========================================

    /// @notice Tests a successful `transferFrom` call.
    function testTransferFrom_Succeeds() public {
        uint256 allowance = 1000;
        uint256 transferAmount = 500;

        uint256 bobInitialBalance = ourToken.balanceOf(bob);
        uint256 aliceInitialBalance = ourToken.balanceOf(alice);

        // Bob approves Alice to spend tokens on his behalf.
        vm.prank(bob);
        ourToken.approve(alice, allowance);

        // Alice uses her allowance to transfer tokens from Bob to herself.
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        // Check balances
        assertEq(ourToken.balanceOf(bob), bobInitialBalance - transferAmount, "Bob's balance should decrease");
        assertEq(ourToken.balanceOf(alice), aliceInitialBalance + transferAmount, "Alice's balance should increase");

        // Check allowance
        assertEq(ourToken.allowance(bob, alice), allowance - transferAmount, "Alice's allowance should decrease");
    }

    /// @notice Tests that a spender can transfer tokens from a token holder to a third party.
    function testTransferFrom_ToThirdPartySucceeds() public {
        uint256 allowance = 1000;
        uint256 transferAmount = 500;

        // Bob approves Alice.
        vm.prank(bob);
        ourToken.approve(alice, allowance);

        // Alice transfers tokens from Bob to Charlie.
        vm.prank(alice);
        ourToken.transferFrom(bob, charlie, transferAmount);

        // Check balances
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE_BOB - transferAmount, "Bob's balance should be reduced");
        assertEq(ourToken.balanceOf(charlie), transferAmount, "Charlie's balance should be the transfer amount");
        assertEq(ourToken.balanceOf(alice), 0, "Alice's balance should be unchanged");

        // Check allowance
        assertEq(ourToken.allowance(bob, alice), allowance - transferAmount, "Alice's allowance should be reduced");
    }

    /// @notice Tests that `transferFrom` reverts if the spender has an insufficient allowance.
    function testRevertIf_TransferFrom_InsufficientAllowance() public {
        uint256 allowance = 100;
        uint256 amountToTransfer = 200;

        // Bob gives Alice a small allowance
        vm.prank(bob);
        ourToken.approve(alice, allowance);

        // Alice tries to transfer more than her allowance
        vm.prank(alice);
        // The error is now defined in this contract.
        vm.expectRevert(abi.encodeWithSelector(ERC20InsufficientAllowance.selector, alice, allowance, amountToTransfer));
        ourToken.transferFrom(bob, alice, amountToTransfer);
    }

    /// @notice Tests that `transferFrom` reverts if the token holder has an insufficient balance,
    /// even if the allowance is sufficient.
    function testRevertIf_TransferFrom_InsufficientBalance() public {
        uint256 allowance = STARTING_BALANCE_BOB + 100 ether;
        uint256 amountToTransfer = STARTING_BALANCE_BOB + 1 ether;

        // Bob gives Alice a huge allowance
        vm.prank(bob);
        ourToken.approve(alice, allowance);

        // Alice tries to transfer more than Bob has
        vm.prank(alice);
        // This should fail due to Bob's balance, not the allowance.
        // The error is now defined in this contract.
        vm.expectRevert(
            abi.encodeWithSelector(ERC20InsufficientBalance.selector, bob, STARTING_BALANCE_BOB, amountToTransfer)
        );
        ourToken.transferFrom(bob, alice, amountToTransfer);
    }
}
