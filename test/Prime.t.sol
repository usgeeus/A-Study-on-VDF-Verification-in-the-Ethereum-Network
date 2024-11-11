// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./shared/BaseTest.t.sol";
import {console2} from "forge-std/Test.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {PrimeNumbers} from "./shared/PrimeNumbers.sol";
import {BailliePSW, MillerRabin} from "../src/Prime.sol";

contract PrimeTest is BaseTest, PrimeNumbers {
    MillerRabin public millerRabin;
    BailliePSW public bailliePSW;
    uint256 msb = 1 << 255;

    function setUp() public override {
        BaseTest.setUp();
        millerRabin = new MillerRabin();
        bailliePSW = new BailliePSW();
    }

    function testMillerRabin() public view {
        for (uint256 i = 0; i < fixturePrimeNumber.length; i++) {
            bool isPrimeNumber = millerRabin.millerRabinTest(
                fixturePrimeNumber[i]
            );
            if (!isPrimeNumber) {
                console2.log("miller rabin failed", fixturePrimeNumber[i]);
            }
            assertTrue(isPrimeNumber, "Should be a prime number");
        }
    }

    function testBailliePSW() public view {
        for (uint256 i = 0; i < fixturePrimeNumber.length; i++) {
            bool isPrimeNumber = bailliePSW.bailliePSW(fixturePrimeNumber[i]);
            if (!isPrimeNumber) {
                console2.log("miller rabin failed", fixturePrimeNumber[i]);
            }
            assertTrue(isPrimeNumber, "Should be a prime number");
        }
    }

    // function testBailliePSWTestExpectToFail() public view {
    //     uint256 length = fixturePrimeNumber.length - 1;
    //     for (uint256 i = 0; i < length; i++) {
    //         uint256 notPrimeNumber = fixturePrimeNumber[i] + 2;
    //         if (notPrimeNumber == fixturePrimeNumber[i + 1]) continue;
    //         bool isPrimeNumber = bailliePSW.bailliePSW(notPrimeNumber);
    //         if (isPrimeNumber) {
    //             console2.log("miller rabin failed", notPrimeNumber);
    //         }
    //         assertFalse(isPrimeNumber, "Should not be a prime number");
    //     }
    // }
}
