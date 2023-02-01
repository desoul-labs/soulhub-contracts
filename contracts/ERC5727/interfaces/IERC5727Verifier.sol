//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../../ERC5484/interfaces/IERC5484.sol";

interface IERC5727Verifier {
    function verify(
        address owner,
        uint256 value,
        uint256 slot,
        address issuer,
        address verifier,
        IERC5484.BurnAuth burnAuth
    ) external view returns (bool);
}
