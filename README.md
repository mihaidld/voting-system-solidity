## `Voting`

Members need to register first with 0.1 ether for 4 weeks or buy more time afterwards.   
Members can be promoted by to admin status by another admin. 
Admins can be demoted by an admin.
Admins can make proposals and warn members (if more than 2 warnings a member is blacklisted). 
All members can vote for proposals (0 -> Blank, 1 -> Yes, 2 -> No)



All function calls are currently implemented without side effects

### `onlyAdmin()`



modifier to check if admin

### `onlyActiveMembers()`



modifier to check if member is up-to-date with registration payments

### `onlyWhitelistedMembers()`



modifier to check if member is not blacklisted

### `onlyMembers()`



modifier to check if member (even behind with his payments, if delayRegistration value was increased in the past from 0)


### `constructor(address payable _addr)` (public)



address _addr who collects ethers from registration fees initialized by constructor is the first member and admin for life (100 years)

### `propose(string _question, string _description)` (public)

a proposal is active for one week  


only an admin, up-to-date with his payments and not blacklisted can create a proposal. The id is given by counterIdProposal variable and delay 1 week from creation date 


### `vote(uint256 _id, enum Voting.Option _voteOption)` (public)

a proposal active for one week, check voting instructions with howToVote  


only a member up-to-date with his payments and not blacklisted can vote for an active proposal and only once. 


### `warn(address _addr)` (public)

after 2 warnings member is blacklisted and cannot vote anymore  


only an admin, up-to-date with his payments and not blacklisted can warn a member (even an another admin, but not the superAdmin). 


### `whitelist(address _addr)` (public)



only an admin, up-to-date with his payments and not blacklisted can whitelist a member. Warnings counter restarts at 0 and isBlacklisted property set to false. 


### `setAdmin(address _addr)` (public)



only an admin, up-to-date with his payments and not blacklisted can promote a member to admin status (if the member is up-to-date with his payments). 


### `unsetAdmin(address _addr)` (public)



only an admin, up-to-date with his payments and not blacklisted can demote a member from admin status. 


### `register()` (public)

Enter a value for registration : : for each 0.1 ether 4 extra weeks. Members please use buy function.

Register a new member, after checking that value is at least 0.1 ether (if more that duration is proportiional with value. The ethers are transfered to superAdmin adress. An event is sent to EVM log.


### `buy()` (public)

Enter a value for registration : : for each 0.1 ethers 4 extra weeks. Non-members please use register function.

Buy more registration time for an already member, after checking that value is at least 0.1 ether (if more that duration is proportional with value. The ethers are transfered to superAdmin adress. An event is sent to EVM log.



### `Registration(address _buyer, uint256 _amount_wei, uint256 _amount_delay)`



event for EVM log when payment for registration

