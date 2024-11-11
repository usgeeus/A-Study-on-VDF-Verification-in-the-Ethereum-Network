// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./shared/BaseTest.t.sol";
import {Wesolowski} from "../src/Wesolowski.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import "../src/BigNumbers.sol";
import {DecodeJsonBigNumber} from "./shared/DecodeJsonBigNumber.sol";

contract MinimalWesolowskiTest is BaseTest, DecodeJsonBigNumber {
    struct SmallJsonBigNumber {
        uint256 bitlen;
        bytes32 val;
    }
    Wesolowski public wesolowski;

    string public constant outputPath = "./Wesolowski2048And3072.json";

    function setUp() public override {
        BaseTest.setUp();
        wesolowski = new Wesolowski();
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

    function decodeShortBigNumber(
        bytes memory jsonBytes
    ) public pure returns (BigNumber memory) {
        SmallJsonBigNumber memory xJsonBigNumber = abi.decode(
            jsonBytes,
            (SmallJsonBigNumber)
        );
        BigNumber memory x = BigNumber(
            abi.encode(xJsonBigNumber.val),
            xJsonBigNumber.bitlen
        );
        return x;
    }

    function returnParsedWesolowski(
        uint256 bits,
        uint256 i,
        uint256 tau
    )
        public
        view
        returns (
            BigNumber memory x,
            BigNumber memory y,
            BigNumber memory n,
            BigNumber memory t,
            BigNumber memory pi,
            BigNumber memory l
        )
    {
        string memory root = vm.projectRoot();
        string memory path = string(
            abi.encodePacked(
                root,
                "/test/shared/wesolowskiTestCases/",
                Strings.toString(bits),
                "/T",
                Strings.toString(tau),
                "/",
                Strings.toString(i),
                ".json"
            )
        );
        string memory json = vm.readFile(path);
        t = decodeShortBigNumber(vm.parseJson(json, ".T"));
        l = decodeShortBigNumber(vm.parseJson(json, ".l"));
        x = decodeBigNumber(vm.parseJson(json, ".x"));
        y = decodeBigNumber(vm.parseJson(json, ".y"));
        n = decodeBigNumber(vm.parseJson(json, ".n"));
        pi = decodeBigNumber(vm.parseJson(json, ".pi"));
    }

    function getAverage(uint256[] memory array) private pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < array.length; i++) {
            sum += array[i];
        }
        return sum / array.length;
    }

    function testWesolowskiAllTestCases() public {
        BigNumber memory x;
        BigNumber memory y;
        BigNumber memory n;
        BigNumber memory T;
        BigNumber memory pi;
        BigNumber memory l;
        uint256 numOfEachTestCase = 5;
        uint256[6] memory taus = [uint256(20), 21, 22, 23, 24, 25];
        uint256[2] memory bits = [uint256(2048), 3072];
        string memory output;
        for (uint256 i = 0; i < bits.length; i++) {
            for (uint256 j = 0; j < taus.length; j++) {
                uint256[] memory gasUseds = new uint256[](numOfEachTestCase);
                uint256[] memory calldataSizes = new uint256[](
                    numOfEachTestCase
                );
                uint256[] memory intrinsicGas = new uint256[](
                    numOfEachTestCase
                );
                for (uint256 k = 1; k <= numOfEachTestCase; k++) {
                    (x, y, n, T, pi, l) = returnParsedWesolowski(
                        bits[i],
                        k,
                        taus[j]
                    );
                    bool result = wesolowski.verifyWesolowski(x, n, T, pi, l);
                    gasUseds[k - 1] = vm.lastCallGas().gasTotalUsed;
                    assertTrue(result);
                    bytes memory calldataBytes = abi.encodeWithSelector(
                        wesolowski.verifyWesolowski.selector,
                        x,
                        n,
                        T,
                        pi,
                        l
                    );
                    calldataSizes[k - 1] = calldataBytes.length;
                    intrinsicGas[k - 1] = getIntrinsicGas(calldataBytes);
                }
                /// Write the results to a json file
                string memory object = "object";
                vm.serializeUint(object, "bits", bits[i]);
                vm.serializeUint(object, "tau", taus[j]);
                vm.serializeUint(object, "gasUseds", gasUseds);
                vm.serializeUint(object, "calldataSizesInBytes", calldataSizes);

                output = vm.serializeString(
                    "bits",
                    string.concat(Strings.toString(bits[i]), "bits"),
                    vm.serializeString(
                        "tau",
                        string.concat(Strings.toString(taus[j]), "tau"),
                        vm.serializeUint(object, "intrinsicGas", intrinsicGas)
                    )
                );
            }
        }
        vm.writeJson(output, outputPath);
    }

    function testWesolowski2048() public view {
        BigNumber memory x;
        BigNumber memory y;
        BigNumber memory n;
        BigNumber memory T;
        BigNumber memory pi;
        BigNumber memory l;
        uint256 numOfEachTestCase = 5;
        uint256[6] memory taus = [uint256(20), 21, 22, 23, 24, 25];
        uint256 bit = 2048;
        for (uint256 j = 0; j < taus.length; j++) {
            for (uint256 k = 1; k <= numOfEachTestCase; k++) {
                (x, y, n, T, pi, l) = returnParsedWesolowski(bit, k, taus[j]);
                bool result = wesolowski.verifyWesolowski(x, n, T, pi, l);
                assertTrue(result);
            }
        }
    }

    function testWesolowski3072() public view {
        BigNumber memory x;
        BigNumber memory y;
        BigNumber memory n;
        BigNumber memory T;
        BigNumber memory pi;
        BigNumber memory l;
        uint256 numOfEachTestCase = 5;
        uint256[6] memory taus = [uint256(20), 21, 22, 23, 24, 25];
        uint256 bit = 3072;
        for (uint256 j = 0; j < taus.length; j++) {
            for (uint256 k = 1; k <= numOfEachTestCase; k++) {
                (x, y, n, T, pi, l) = returnParsedWesolowski(bit, k, taus[j]);
                bool result = wesolowski.verifyWesolowski(x, n, T, pi, l);
                assertTrue(result);
            }
        }
    }
}
