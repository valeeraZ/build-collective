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

  struct Enterprise {
    string name;
    User owner;
    address[] membersAddress;
    uint256 balance;
  }

  struct Project {
    string name;
    address owner; // an address pointing to user / enterprise
    bool ownedByUser; // if true, the "address owner" points to user; otherwise, enterprise
    address[] contributorsAddress;
    uint256 balance;
  }

  struct Issue {
    string title;
    string description;
    string link; // GitHub or GitLab link of issue
    User issuer; // the one who spots the issue
    User fixer; // the one who fixes the issue
    uint256 reward; // the amount of ETH rewarded to fixer
    bool closed; // if true, the issue is fixed and reward is given
  }

  mapping(address => User) private users; // user's address -> User

  mapping(address => Enterprise) private enterprises; // owner's address -> owner's enterprise

  mapping(address => Project[]) private projects;

  event UserSignedUp(address indexed userAddress, User indexed user);

  event EnterpriseSignedUp(address indexed ownerAddress, Enterprise indexed enterprise);

  event ProjectCreate(address indexed ownerAddress, Project indexed project);

  function getUserByAddress(address userAddress) public view returns (User memory) {
    return users[userAddress];
  }

  function getAllUsers() external view returns (address[] memory) {
    return userAddresses;
  }

  function getEnterpriseByAddress(address enterpriseAddress) public view returns (Enterprise memory) {
    return enterprises[enterpriseAddress];
  }

  function getProjectsByAddress(address ownerAddress) public view returns (Project[] memory){
    return projects[ownerAddress];
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
    enterprises[msg.sender] = Enterprise(name, users[msg.sender], address_members, amount);
    emit EnterpriseSignedUp(msg.sender, enterprises[msg.sender]);
    return enterprises[msg.sender];
  }

  function projectCreate(string memory name, bool ownedByUser, address[] memory address_contributors, uint256 amount) public returns (Project memory){
    require(users[msg.sender].registered);
    require(bytes(name).length > 0);
    projects[msg.sender].push(Project(name, msg.sender, ownedByUser, address_contributors, amount));
    uint pos = projects[msg.sender].length;
    emit ProjectCreate(msg.sender, projects[msg.sender][pos-1]);
    return projects[msg.sender][pos-1];
  }

  function addBalance(uint256 amount) public returns (bool) {
    require(users[msg.sender].registered);
    users[msg.sender].balance += amount;
    return true;
  }
}
