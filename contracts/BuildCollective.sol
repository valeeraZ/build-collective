pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";

contract BuildCollective is Ownable {
  struct User {
    string username;
    uint256 balance;
    bool registered;
  }

  address[] public userAddresses;

  struct Issue {
    User owner;
    uint256 reward;
    bool closed;
  }

  struct Enterprise {
    string name;
    User owner;
    uint256 balance;
  }

  mapping(address => address[]) private enterpriseMembersAddress;

  mapping(address => User) private users;

  mapping(address => Enterprise) private enterprises;

  event UserSignedUp(address indexed userAddress, User indexed user);

  event EnterpriseSignedUp(address indexed ownerAddress, Enterprise indexed enterprise);

  function user(address userAddress) public view returns (User memory) {
    return users[userAddress];
  }

  function getAllUsers() external view returns (address[] memory) {
    return userAddresses;
  }

  function enterprise(address enterpriseAddress) public view returns (Enterprise memory) {
    return enterprises[enterpriseAddress];
  }

  function members(address enterpriseAddress) external view returns (address[] memory) {
    return enterpriseMembersAddress[enterpriseAddress];
  }

  function signUp(string memory username, uint256 amount) public returns (User memory) {
    require(bytes(username).length > 0);
    users[msg.sender] = User(username, amount, true);
    emit UserSignedUp(msg.sender, users[msg.sender]);
    userAddresses.push(msg.sender);
    return users[msg.sender];
  }

  function enterpriseSignUp(string memory name, address[] memory address_members, uint256 amount) public returns (Enterprise memory) {
    require(users[msg.sender].registered);
    require(bytes(name).length > 0);
    enterprises[msg.sender] = Enterprise(name, users[msg.sender], amount);
    for(uint i = 0; i < address_members.length; i++){
      enterpriseMembersAddress[msg.sender].push(address_members[i]);
    }
    emit EnterpriseSignedUp(msg.sender, enterprises[msg.sender]);
    return enterprises[msg.sender];
  }

  function addBalance(uint256 amount) public returns (bool) {
    require(users[msg.sender].registered);
    users[msg.sender].balance += amount;
    return true;
  }
}
