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
    address owner;
    address[] membersAddress;
    uint256 balance;
  }

  uint256 internal ProjectId;

  struct Project {
    uint256 id;
    string name;
    string link;
    address owner; // an address pointing to user / enterprise
    bool ownedByUser; // if true, the "address owner" points to user; otherwise, enterprise
    address[] contributorsAddress;
    uint256 balance;
  }

  uint256 internal IssueId;

  struct Issue {
    uint256 id;
    string title;
    string description;
    string link; // GitHub or GitLab link of issue
    address issuer; // the one who spots the issue
    address payable fixer; // the one who fixes the issue, by default the value is address(0)
    uint256 reward; // the amount of ETH rewarded to fixer
    bool closed; // if true, the issue is fixed and reward is given
  }

  mapping(address => User) private users; // user's address -> User

  mapping(address => Enterprise) private enterprises; // owner's address -> owner's enterprise

  mapping(address => Project[]) private projects; // project's owner's address -> owner's projects

  mapping(uint => Issue[]) private issues; // project's id -> project's issues

  event UserSignedUp(address indexed userAddress, User indexed user);

  event EnterpriseSignedUp(address indexed ownerAddress, Enterprise indexed enterprise);

  event ProjectCreate(address indexed ownerAddress, Project indexed project);

  event IssueCreate(address indexed issuerAddress, Issue indexed issue);

  function getUserByAddress(address userAddress) public view returns (User memory) {
    require(users[userAddress].registered);
    return users[userAddress];
  }

  function getAllUsers() external view returns (address[] memory) {
    return userAddresses;
  }

  function getEnterpriseByAddress(address enterpriseAddress) public view returns (Enterprise memory) {
    require(users[enterpriseAddress].registered);
    return enterprises[enterpriseAddress];
  }

  function getProjectsByAddress(address ownerAddress) public view returns (Project[] memory){
    require(users[ownerAddress].registered);
    return projects[ownerAddress];
  }

  function getProjectByIdAndAddress(address ownerAddress, uint256 id) public view returns (Project memory) {
    require(users[ownerAddress].registered);
    Project[] memory ownerProjects = getProjectsByAddress(ownerAddress);
    for (uint i = 0; i < ownerProjects.length; i++){
      if (ownerProjects[i].id == id){
        return ownerProjects[i];
      }
    }
    return ownerProjects[0];
  }

  function getIssuesByProjectId(uint256 projectId) public view returns (Issue[] memory) {
    return issues[projectId];
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
    enterprises[msg.sender] = Enterprise(name, msg.sender, address_members, amount);
    emit EnterpriseSignedUp(msg.sender, enterprises[msg.sender]);
    return enterprises[msg.sender];
  }

  function projectCreate(string memory name, string memory link, bool ownedByUser, address[] memory address_contributors, uint256 amount) public returns (Project memory){
    require(users[msg.sender].registered);
    require(bytes(name).length > 0);
    ProjectId ++;
    Project memory project = Project(ProjectId, name, link, msg.sender, ownedByUser, address_contributors, amount);
    projects[msg.sender].push(project);
    emit ProjectCreate(msg.sender, project);
    return project;
  }

  function sponsorProject(address projectOwnerAddress, uint256 idProject, uint256 amountToken) public returns (bool) {
    require(users[projectOwnerAddress].registered);
    for (uint i = 0; i < projects[projectOwnerAddress].length; i++){
      if (projects[projectOwnerAddress][i].id == idProject){
        users[msg.sender].balance -= amountToken;
        projects[projectOwnerAddress][i].balance += amountToken;
        return true;
      }
    }
    return false;
  }

  function createAnIssue(address projectOwnerAddress, uint256 projectId, string memory title, string memory description, string memory link, uint256 reward) public returns (Issue memory){
    require(users[projectOwnerAddress].registered);
    require(users[msg.sender].registered);
    require(bytes(title).length > 0);
    IssueId++;
    Issue memory issue = Issue(IssueId, title, description, link, msg.sender, address(0), reward, false);
    issues[projectId].push(issue);
    emit IssueCreate(msg.sender, issue);
    return issue;
  }

  function fixAnIssue(uint256 projectId, uint256 issueId, address payable fixer) public payable returns (bool){
    for (uint i = 0; i < issues[projectId].length; i++){
      if (issues[projectId][i].id == issueId) {
        issues[projectId][i].closed = true;
        issues[projectId][i].fixer = fixer;
        uint amount = issues[projectId][i].reward;
        fixer.transfer(amount);
        return true;
      }
    }
    return false;
  }

  function addBalance(uint256 amount) public returns (bool) {
    require(users[msg.sender].registered);
    users[msg.sender].balance += amount;
    return true;
  }

  function transfer(address payable payee, uint256 amount) public payable returns (bool){
    bool success = payee.send(amount);
    return success;
  }

  // fallback
  function () external payable{}
}
