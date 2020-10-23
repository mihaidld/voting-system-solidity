// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

/**
* @title A blockchain voting smart contract 
* 
* @notice Members need to register first with 0.1 ethers for 4 weeks or buy more time afterwards. 
* Members can be promoted by to admin status by another admin. 
* Admins can be demoted by an admin.
* Admins can make proposals and warn members (if more than 2 warnings a member is blacklisted). 
* All members can vote for proposals (0 -> Blank, 1 -> Yes, 2 -> No)
* 
@dev All function calls are currently implemented without side effects
*/
contract Voting {
    
    // Variables de state
    
    /// @dev address who collects ethers from registration fees initialized by constructor, who cannot be blacklisted and is the first member and admin for life
    address payable superAdmin;
    
    /// @dev struct Member
    struct Member{
         bool isAdmin; // false if the member is not an admin, true is an admin
         uint warnings; // 0 at registration, can be increased
         bool isBlacklisted; //false at registration and as long as warnings < 2, true if warnings >=2
         uint delayRegistration; // till when is the member registered following his payment
    }
    
    /// @dev struct Proposal
    struct Proposal{
        uint id; // id of proposal
        bool active; // proposal active for 1 week 
        string question; // proposal question
        string description; // proposal description
        uint counterForVotes; // counter of votes `Yes`
        uint counterAgainstVotes; // counter of votes `No`
        uint counterBlankVotes; // ounter of votes `Blank`
        uint delay; // till when the proposal is active
        mapping (address => bool) didVote; // mapping to check that an address can not vote twice for same proposal id
    }
    
    mapping (address => Member) public members;
    
    mapping (uint => Proposal) public proposals;
    
    uint private counterIdProposal;
    
    string public howToVote = "0 -> Blank, 1 -> Yes, 2 -> No";
     
    enum Option { Blank, Yes, No } // variables de type Option prennent valeurs: 0 -> Option.Blank, 1 -> Option.Yes, 2 -> Option.No
    
    event Registration(
        address indexed _buyer,
        uint256 _amount_wei,
        uint256 _amount_delay
        );
        
    // Constructor
    
    constructor(address payable _addr) public{
        superAdmin = _addr;
        members[_addr].isAdmin = true;
        members[_addr].delayRegistration = block.timestamp + 5200 weeks;
    }

    //Modifiers
    
    modifier onlyAdmin (){
            require (members[msg.sender].isAdmin == true, "only admin can call this function");
            _;
        }
        
    modifier onlyActiveMembers (){
            require (members[msg.sender].delayRegistration >= block.timestamp, "only members who have paid the registration till present can call this function");
            _;
        }
        
    modifier onlyWhitelistedMembers (){
            require (members[msg.sender].isBlacklisted == false, "only members not blacklisted can call this function");
            _;
        }
        
    modifier onlyMembers (){
            require (members[msg.sender].delayRegistration > 0, "only members can call this function");
            _;
        }
    
    // Functions
    
    function propose(string memory _question, string memory _description) public onlyAdmin onlyActiveMembers onlyWhitelistedMembers{
        counterIdProposal++;
        uint count = counterIdProposal;
        proposals [count] = Proposal(count, true, _question, _description, 0, 0, 0, block.timestamp + 1 weeks );
        
    }
    
    function vote (uint _id, Option _voteOption ) public onlyActiveMembers onlyWhitelistedMembers{
        //verifier si votant n'est pas blacklisted et pas deja vote pour cette proposition
        require (proposals[_id].delay > block.timestamp, "proposal not active any more");
        require (proposals[_id].didVote[msg.sender] == false, "member already voted for this proposal");
        if (_voteOption == Option.Blank) {
            proposals[_id].counterBlankVotes++;
        } else if(_voteOption == Option.Yes) {
            proposals[_id].counterForVotes++;
        } else if(_voteOption == Option.No) {
            proposals[_id].counterAgainstVotes++;
        } else revert("Invalid vote");
        proposals[_id].didVote[msg.sender] = true;
    }
    
    function warn (address _addr) public onlyAdmin onlyActiveMembers onlyWhitelistedMembers{
        require (_addr != superAdmin, "superAdmin cannot be warned");
        members[_addr].warnings +=1;
        if (members[_addr].warnings > 2){ members[_addr].isBlacklisted = true;}
    }
    
    function whitelist (address _addr) public onlyAdmin onlyActiveMembers onlyWhitelistedMembers{
        members[_addr].warnings = 0;
        members[_addr].isBlacklisted = false;
    }
    
    function setAdmin (address _addr) public onlyAdmin onlyActiveMembers onlyWhitelistedMembers{
        require (members[_addr].delayRegistration >= block.timestamp, " member to be set admin is behind with registration payment");
        members[_addr].isAdmin = true;
        }
        
    function unsetAdmin (address _addr) public onlyAdmin onlyActiveMembers onlyWhitelistedMembers{
        members[_addr].isAdmin = false;
        }
    
    //only for non-members
    function register() public payable{
        require (members[msg.sender].delayRegistration == 0, "only for non members");
        require (msg. value >= 10**17, "not enough ethers");
        uint nbOf4WeekPeriods  = msg.value / 10 ** 17;
        uint validity = block.timestamp + nbOf4WeekPeriods * 4 weeks;
        members[msg.sender] = Member(false, 0, false, validity );
        superAdmin.transfer(msg.value);
        emit Registration( msg.sender, msg.value, validity);
    }
    
    //only for members (even inactive)
    function buy() public payable onlyMembers onlyWhitelistedMembers{
        require (msg. value >= 10**17, "not enough ethers");
        uint nbOf4WeekPeriods  = msg.value / 10 ** 17;
        uint validity = block.timestamp + nbOf4WeekPeriods * 4 weeks;
        members[msg.sender].delayRegistration = validity;
        superAdmin.transfer(msg.value);
        emit Registration( msg.sender, msg.value, validity);
        }
}