// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

/*
    Inspired by Solmate's RolesAuthority (https://github.com/Rari-Capital/solmate/blob/main/src/auth/authorities/RolesAuthority.sol)
    and OpenZeppelin's AccessControl (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol)

    Supports up to 256 roles
*/

uint8 constant ROOT_ROLE_ID = 0;
uint8 constant ROLE_MANAGER_ROLE = 1;
bytes32 constant ONLY_ROOT_ROLE = bytes32(uint256(1));

interface IRoles {
    function hasRole(address _user, uint8 _roleId) external view returns (bool);
}

contract Roles is IRoles {
    mapping (address => bytes32) public getUserRoles;
    mapping (uint8 => bytes32) public getRoleAdmin;
    uint256 public roleCount;

    event RoleCreated(uint8 indexed roleId, bytes32 roleAdmin, string name, address indexed actor);
    event RoleAdminSet(uint8 indexed roleId, bytes32 roleAdmin, address indexed actor);
    event RolesSet(address indexed user, bytes32 userRoles, address indexed actor);
    
    error AlreadyInitialized();
    error UnauthorizedNoRole(uint8 requiredRole);
    error UnauthorizedNotAdmin(uint8 role);
    error RoleLimitReached();
    
    constructor(address _initialRoot) {
        setUp(_initialRoot);
    }

    function setUp(address _initialRoot) public {
        // Since setUp creates the first two roles, this function can only be called once
        if (roleCount != 0)
            revert AlreadyInitialized();

        _createRole(ONLY_ROOT_ROLE, "Root");
        _createRole(ONLY_ROOT_ROLE, "Role manager");

        // Initial admin just gets root role which gives it permission to do anything
        // (Implicitly gets role manager role immediately)
        getUserRoles[_initialRoot] = ONLY_ROOT_ROLE;
    }

    function createRole(bytes32 _adminRoles, string memory _name) public returns (uint8 roleId) {
        if (!hasRole(msg.sender, ROLE_MANAGER_ROLE))
            revert UnauthorizedNoRole(ROLE_MANAGER_ROLE);

        return _createRole(_adminRoles, _name);
    }

    function _createRole(bytes32 _adminRoles, string memory _name) internal returns (uint8 roleId) {
        uint256 roleCount_ = roleCount;
        if (roleCount_ == 256) revert RoleLimitReached();
         unchecked {
            roleCount = roleCount_ + 1;
        }

        roleId = uint8(roleCount_);
        getRoleAdmin[roleId] = _adminRoles;

        emit RoleCreated(roleId, _adminRoles, _name, msg.sender);
    }

    function setRoleAdmin(uint8 _roleId, bytes32 _adminRoles) public {
        if (_roleId == ROOT_ROLE_ID) {
            // Root role is treated as a special case. Only root role admins can change it
            if (!isRoleAdmin(msg.sender, ROOT_ROLE_ID))
                revert UnauthorizedNotAdmin(ROOT_ROLE_ID);
        } else {
            // For all other roles, the general role manager role can change any roles admins
            if (!hasRole(msg.sender, ROLE_MANAGER_ROLE))
                revert UnauthorizedNoRole(ROLE_MANAGER_ROLE);
        }

        getRoleAdmin[_roleId] = _adminRoles;

        emit RoleAdminSet(_roleId, _adminRoles, msg.sender);
    }

    function setRole(address _user, uint8 _roleId, bool _grant) public {
        bytes32 userRoles = getUserRoles[_user];

        if (!_isRoleAdmin(getUserRoles[msg.sender], _roleId))
            revert UnauthorizedNotAdmin(_roleId);

        if (_grant) {
            userRoles |= bytes32(1 << _roleId);
        } else {
            userRoles &= ~bytes32(1 << _roleId);
        }

        getUserRoles[_user] = userRoles;

        emit RolesSet(_user, userRoles, msg.sender);
    }

    function setRoles(address _user, uint8[] memory _grantingRoles, uint8[] memory _revokingRoles) public {
        bytes32 senderRoles = getUserRoles[msg.sender];
        bytes32 userRoles = getUserRoles[_user];

        uint256 grantsLength = _grantingRoles.length;
        for (uint256 i = 0; i < grantsLength; i++) {
            uint8 roleId = _grantingRoles[i];
            if (!_isRoleAdmin(senderRoles, roleId))
                revert UnauthorizedNotAdmin(roleId);

            userRoles |= bytes32(1 << roleId);
        }

        uint256 revokesLength = _revokingRoles.length;
        for (uint256 i = 0; i < revokesLength; i++) {
            uint8 roleId = _revokingRoles[i];
            if (!_isRoleAdmin(senderRoles, roleId))
                revert UnauthorizedNotAdmin(roleId);

            userRoles &= ~(bytes32(1 << roleId));
        }

        getUserRoles[_user] = userRoles;

        emit RolesSet(_user, userRoles, msg.sender);
    }

    function hasRole(address _user, uint8 _roleId) public view returns (bool) {
        bytes32 userRoles = getUserRoles[_user];
        // either user has the specified role or user has root role (whichs gives it permission to do anything)
        // Note: For root it will return true even if the role hasn't been created yet
        return uint256(userRoles >> _roleId) & 1 != 0 || _hasRootRole(userRoles);
    }

    function isRoleAdmin(address _user, uint8 _roleId) public view returns (bool) {
        return _isRoleAdmin(getUserRoles[_user], _roleId);
    }

    function _isRoleAdmin(bytes32 _userRoles, uint8 _roleId) internal view returns (bool) {
        // Note: For root it will return true even if the role hasn't been created yet
        return (_userRoles & getRoleAdmin[_roleId]) != 0 || _hasRootRole(_userRoles);
    }

    function hasRootRole(address _user) public view returns (bool) {
        // Since root role is always at ID 0, we don't need to shift
        return _hasRootRole(getUserRoles[_user]);
    }

    function _hasRootRole(bytes32 _userRoles) internal pure returns (bool) {
        // Since root role is always at ID 0, we don't need to shift
        return uint256(_userRoles) & 1 != 0;
    }
}