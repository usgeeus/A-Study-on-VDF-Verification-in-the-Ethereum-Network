// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./shared/BaseTest.t.sol";
import {Vm} from "forge-std/Test.sol";
import {Pietrzak} from "../src/Pietrzak.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import "../src/BigNumbers.sol";
import {DecodeJsonBigNumber} from "./shared/DecodeJsonBigNumber.sol";

contract Pietrzak2048 is BaseTest, DecodeJsonBigNumber {
    Pietrzak public pietrzak;

    function setUp() public override {
        BaseTest.setUp();
        pietrzak = new Pietrzak();
    }

    function testPietrzak2048() public {
        BigNumber[] memory v;
        BigNumber memory x;
        BigNumber memory y;
        BigNumber memory n;
        uint256 T;
        uint256 numOfEachTestCase = 5;
        uint256[6] memory taus = [uint256(20), 21, 22, 23, 24, 25];
        uint256 bit = 2048;
        string memory output;
        for (uint256 j = 0; j < taus.length; j++) {
            uint256[] memory gasUseds = new uint256[](numOfEachTestCase);
            for (uint256 k = 1; k <= numOfEachTestCase; k++) {
                (v, x, y, n, T) = returnParsed(bit, k, taus[j]);
                bool result = pietrzak.verifyPietrzak(v, x, y, n, T);
                gasUseds[k - 1] = vm.lastCallGas().gasTotalUsed;
                assertTrue(result);
            }
            vm.serializeUint("object", "tau", taus[j]);
            string memory resultJson = vm.serializeUint(
                "object",
                "gasUseds",
                gasUseds
            );
            string memory key = string.concat(Strings.toString(taus[j]), "tau");
            output = vm.serializeString("Tau", key, resultJson);
        }
        vm.writeJson(output, "Pietrzak2048GasUsed.json");
    }
}

contract Pietrzak3072 is BaseTest, DecodeJsonBigNumber {
    Pietrzak public pietrzak;

    function setUp() public override {
        BaseTest.setUp();
        pietrzak = new Pietrzak();
    }

    function testPietrzak3072() public {
        BigNumber[] memory v;
        BigNumber memory x;
        BigNumber memory y;
        BigNumber memory n;
        uint256 T;
        uint256 numOfEachTestCase = 5;
        uint256[6] memory taus = [uint256(20), 21, 22, 23, 24, 25];
        uint256 bit = 3072;
        string memory output;
        for (uint256 j = 0; j < taus.length; j++) {
            uint256[] memory gasUseds = new uint256[](numOfEachTestCase);
            for (uint256 k = 1; k <= numOfEachTestCase; k++) {
                (v, x, y, n, T) = returnParsed(bit, k, taus[j]);
                bool result = pietrzak.verifyPietrzak(v, x, y, n, T);
                gasUseds[k - 1] = vm.lastCallGas().gasTotalUsed;
                assertTrue(result);
            }
            vm.serializeUint("object", "tau", taus[j]);
            string memory resultJson = vm.serializeUint(
                "object",
                "gasUseds",
                gasUseds
            );
            string memory key = string.concat(Strings.toString(taus[j]), "tau");
            output = vm.serializeString("Tau", key, resultJson);
        }
        vm.writeJson(output, "Pietrzak3072GasUsed.json");
    }
}

contract PietrzakProofLength_CalldataLength_IntrinsicGas is
    BaseTest,
    DecodeJsonBigNumber
{
    Pietrzak pietrzak;

    function setUp() public override {
        BaseTest.setUp();
        pietrzak = new Pietrzak();
    }

    function getIntrinsicGas(bytes memory _data) public pure returns (uint256) {
        uint256 total = 21000; //txBase
        for (uint256 i = 0; i < _data.length; i++) {
            if (_data[i] == 0) {
                total += 4;
            } else {
                total += 16;
            }
        }
        return total;
    }

    function getAverage(uint256[] memory array) private pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < array.length; i++) {
            sum += array[i];
        }
        return sum / array.length;
    }

    function testCalldataCost() public {
        BigNumber[] memory v;
        BigNumber memory x;
        BigNumber memory y;
        BigNumber memory n;
        uint256 T;
        uint256 numOfEachTestCase = 5;
        uint256[6] memory taus = [uint256(20), 21, 22, 23, 24, 25];
        uint256[2] memory bits = [uint256(2048), 3072];
        string memory output;
        for (uint256 bitIndex = 0; bitIndex < bits.length; bitIndex++) {
            for (uint256 t = 0; t < taus.length; t++) {
                uint256[] memory intrinsicGass = new uint256[](
                    numOfEachTestCase
                );
                uint256[] memory calldataLengths = new uint256[](
                    numOfEachTestCase
                );
                for (uint256 k = 1; k <= numOfEachTestCase; k++) {
                    (v, x, y, n, T) = returnParsed(bits[bitIndex], k, taus[t]);
                    bytes memory calldataBytes = abi.encodeWithSelector(
                        pietrzak.verifyPietrzak.selector,
                        v,
                        x,
                        y,
                        n,
                        T
                    );
                    calldataLengths[k - 1] = calldataBytes.length;
                    intrinsicGass[k - 1] = getIntrinsicGas(calldataBytes);
                }
                uint256 proofLength = taus[t];
                string memory object = "object";
                vm.serializeUint(object, "bits", bits[bitIndex]);
                vm.serializeUint(object, "tau", taus[t]);
                vm.serializeUint(object, "calldataLength", calldataLengths);

                string memory key = string.concat(
                    Strings.toString(proofLength),
                    "tau"
                );
                output = vm.serializeString(
                    "bits",
                    string.concat(Strings.toString(bits[bitIndex]), "bits"),
                    vm.serializeString(
                        "proofLength",
                        key,
                        vm.serializeUint(object, "intrinsicGas", intrinsicGass)
                    )
                );
            }
        }
        vm.writeJson(output, "PietrzakCalldataLength_IntrinsicGas.json");
    }
}
