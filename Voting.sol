// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
/*

*/
contract Voting {
//Variables de state

address payable superAdmin;

struct Member{
     /*bool isAdmin;
     bool isSuperAdmin;*/
     uint warnings; //0,1,2
     bool isBlacklisted; //false si warnings <2, true si warnings >=2; mapping ?
     uint delayRegistration; //block.timestamp du paiement + 4 weeks pour chaque 0.1 ethers
 }

struct Proposal{
        uint id; // id de la proposition, automatiquement ou alloue a la creation
        bool active; // proposition toujours active pour être votée, si maintenant < delay 
        string question; // la proposition
        string description; // une description de la proposition
        uint counterForVotes; // nombre de vote `Yes` avec counter ex. function tick()
        uint counterAgainstVotes; // nombre de vote `No`
        uint counterBlankVotes; // nombre de vote `Blank`
        uint delay; // date à laquelle la proposition ne sera plus valide block.timestamp de creation + 1 weeks
        //mapping (address => Option) voted what; // mapping pour verifier si chaque addresse a vote pour cette proposition
    }
    
mapping (address => bool) public admin;

//mapping (address => uint) public registered;//jusque quand est inscrit chacun

mapping (address => Member) public members;

mapping (uint => Proposal) public proposals;

mapping (uint => mapping(address => bool)) public votes;

uint counterIdProposal;
 
enum Option { Yes, No, Blank }
Option voteOption; // prend valeurs: Option.Yes, Option.No, Option.Blank

event Registration(
        address indexed _buyer,
        uint256 _amount_wei,
        uint256 _amount_delay
    );
    
constructor(address payable _addr) public{
    superAdmin = _addr;
    admin[_addr] = true;
    admin[msg.sender] = true;
}
    
//Functions

modifier onlyAdmin (){
        require (admin[msg.sender] == true, "only admin can call this function");
        _;
    }
    
modifier onlyActiveMembers (){
        require (members[msg.sender].delayRegistration > block.timestamp, "only active members can call this function");
        _;
    }
    
modifier onlyMembers (){
        require (members[msg.sender].delayRegistration > 0, "only admin can call this function");
        _;
    }

function propose(string memory _question, string memory _description) public onlyAdmin{
    counterIdProposal++;
    uint count = counterIdProposal;
    proposals [count] = Proposal(counterIdProposal++, true, _question, _description, 0, 0, 0, block.timestamp + 1 weeks );
    
}

function vote (uint _id, Option _option ) public onlyActiveMembers{
    //verifier si votant n'est pas blacklisted et pas deja vote pour cette proposition
    
}

//only for non-members
function register() public payable{
    require (members[msg.sender].delayRegistration == 0, "only for non members");
    require (msg. value >= 10**17, "not enough ethers");
    uint nbOf4WeekPeriods  = msg.value / 10 ** 17;
    members[msg.sender] = Member(0, false, block.timestamp + nbOf4WeekPeriods * 4 weeks);
}

function warn (address _addr) public onlyAdmin{
    members[_addr].warnings +=1;
    if (members[_addr].warnings > 2){ members[_addr].isBlacklisted = true;}
}

function setAdmin (address _admin) public onlyAdmin {
        admin[_admin] = true;
    }
    
function unsetAdmin (address _admin) public onlyAdmin {
        admin[_admin] = false;
    }

//only for members (even inactive)
function buy() public payable onlyMembers{
        require (msg. value >= 10**17, "not enough ethers");
        uint nbOf4WeekPeriods  = msg.value / 10 ** 17;
        members[msg.sender].delayRegistration = block.timestamp + nbOf4WeekPeriods * 4 weeks;
        superAdmin.transfer(msg.value);
    }


 
}