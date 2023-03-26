// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../ERC721/ERC721EnumerableUpgradeable.sol";
import "../examples/ERC5727ExampleUpgradeable.sol";
import "../proxy/BeaconProxy.sol";
import "../proxy/UpgradeableBeacon.sol";

contract SoulHubUpgradeable is ERC721EnumerableUpgradeable {
    event OrganizationCreated(
        address indexed creator,
        address indexed organization
    );
    event MemberAdded(address indexed organization, address indexed member);
    event MemberRemoved(address indexed organization, address indexed member);

    mapping(uint256 => address) private _organizations;
    mapping(address => mapping(address => uint256)) private _members;

    ERC5727ExampleUpgradeable private _sbtImpl;
    UpgradeableBeacon private _beacon;

    function __SoulHub_init() public initializer {
        __SoulHub_init_unchained();
    }

    function __SoulHub_init_unchained() internal onlyInitializing {
        __ERC721_init_unchained("SoulHub", "SOUL");
        _sbtImpl = new ERC5727ExampleUpgradeable();
        _beacon = new UpgradeableBeacon(address(_sbtImpl));
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "https://soulhub.dev/organizations/";
    }

    function createOrganization(
        string memory name,
        string memory baseURI
    ) external returns (address) {
        bytes memory data = abi.encodeWithSignature(
            "__ERC5727Example_init(string,string,address,address[],string,string)",
            name,
            name,
            _msgSender(),
            [_msgSender()],
            baseURI,
            "v1"
        );
        BeaconProxy proxy = new BeaconProxy(address(_beacon), data);

        emit OrganizationCreated(_msgSender(), address(proxy));

        uint256 nextId = totalSupply();
        _organizations[nextId] = address(proxy);
        _members[address(proxy)][_msgSender()] = nextId;
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
        return _members[organization][member] > 0;
    }

    function tokenOfMember(
        address organization,
        address member
    ) public view returns (uint256) {
        return _members[organization][member];
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
        _members[organization][member] = nextId;
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
        delete _members[organization][member];
        _burn(tokenId);

        emit MemberRemoved(organization, member);
    }
}
