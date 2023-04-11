// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";

import "../ERC721/ERC721EnumerableUpgradeable.sol";
import "../proxy/BeaconProxy.sol";
import "../proxy/UpgradeableBeacon.sol";

contract SoulHubUpgradeable is ERC721EnumerableUpgradeable {
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.AddressToUintMap;

    event OrganizationCreated(
        address indexed creator,
        address indexed organization
    );
    event MemberAdded(address indexed organization, address indexed member);
    event MemberRemoved(address indexed organization, address indexed member);

    mapping(uint256 => address) private _organizations;
    mapping(address => EnumerableMapUpgradeable.AddressToUintMap)
        private _members;

    UpgradeableBeacon private _beacon;

    function __SoulHub_init(address beacon) public initializer {
        __ERC721_init_unchained("SoulHub", "SOUL");
        __SoulHub_init_unchained(beacon);
    }

    function __SoulHub_init_unchained(
        address beacon
    ) internal onlyInitializing {
        _beacon = UpgradeableBeacon(beacon);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "https://soulhub.dev/";
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    "contracts/",
                    organizationOf(tokenId)
                )
            );
    }

    function createOrganization(
        string memory name
    ) external payable returns (address) {
        bytes memory data = abi.encodeWithSignature(
            "__ERC5727SBT_init(string,string,address,string,string)",
            name,
            name,
            _msgSender(),
            _baseURI(),
            "v1"
        );
        BeaconProxy proxy = new BeaconProxy(address(_beacon), data);

        emit OrganizationCreated(_msgSender(), address(proxy));

        uint256 nextId = totalSupply() + 1;
        _organizations[nextId] = address(proxy);
        _members[address(proxy)].set(_msgSender(), nextId);
        _safeMint(_msgSender(), nextId);

        return address(proxy);
    }

    function organizationOf(uint256 tokenId) public view returns (address) {
        _requireMinted(tokenId);

        return _organizations[tokenId];
    }

    function isMemberOf(
        address organization,
        address member
    ) public view returns (bool) {
        return _members[organization].get(member) > 0;
    }

    function tokenOfMember(
        address organization,
        address member
    ) public view returns (uint256) {
        return _members[organization].get(member);
    }

    function getMembers(
        address organization
    ) external view returns (address[] memory) {
        uint256 length = _members[organization].length();
        address[] memory members = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            (address member, ) = _members[organization].at(i);
            members[i] = member;
        }
        return members;
    }

    function addMember(address organization, address member) external {
        require(
            isMemberOf(organization, _msgSender()),
            "SoulHub: Not a member"
        );
        require(
            AccessControlUpgradeable(organization).hasRole(0x00, _msgSender()),
            "SoulHub: Not an admin of organization"
        );

        uint256 nextId = totalSupply() + 1;
        _members[organization].set(member, nextId);
        _organizations[nextId] = organization;
        _safeMint(_msgSender(), nextId);

        emit MemberAdded(organization, member);
    }

    function removeMember(address organization, address member) external {
        require(
            isMemberOf(organization, _msgSender()),
            "SoulHub: Not a member"
        );
        require(
            AccessControlUpgradeable(organization).hasRole(0x00, _msgSender()),
            "SoulHub: Not an admin of organization"
        );

        uint256 tokenId = tokenOfMember(organization, member);
        _members[organization].remove(member);
        _burn(tokenId);

        emit MemberRemoved(organization, member);
    }
}
