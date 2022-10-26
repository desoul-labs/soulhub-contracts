// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC5727/ERC5727.sol";
import "../ERC5727/ERC5727Registrant.sol";

contract ERC5727RegistrantExample is ERC5727Registrant {
    constructor(string memory name, string memory symbol)
        ERC5727Registrant(name, symbol)
    {}
}
