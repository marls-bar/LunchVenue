// SPDX-License-Identifier : UNLICENSED

pragma solidity ^0.8.0;
/// @title Contract to agree on the lunch venue
contract LunchVenue {
    
    struct Friend {
        string name ;
        bool voted ;
    }

    struct Vote {
        address voterAddress ;
        uint venue ;
    }

    mapping ( uint => string ) public venues ; // List of venues ( venue no , name )
    mapping ( address => Friend ) public friends ; // List of friends ( address , Friend )
    uint public numVenues = 0;
    uint public numFriends = 0;
    uint public numVotes = 0;
    address public manager ; // Manager of lunch venues
    string public votedVenue = ""; // Where to have lunch   
    
    mapping ( uint => Vote ) private votes ; // List of votes ( vote no , Vote )
    mapping ( uint => uint ) private results ; // List of vote counts ( venue no , no of votes )

    bool voteOpen = false ; // voting is closed
    bool lunchCancelled = false;
    bool lockFriendsAndVenues = false;

    // Creates a new lunch venue contract
    constructor () {
        manager = msg.sender ; // Set contract creator as manager
    }

    /// @notice Add a new lunch venue
    /// @dev To simplify the code duplication of venues is not checked
    /// @param name Name of the venue
    /// @return Number of lunch venues added so far
    function addVenue(string memory name) public addFriendAndVenuePhase restricted  returns (uint){
        numVenues ++;
        venues [numVenues] = name ;
        return numVenues ;
    }   

    /// @notice Add a new friend who can vote on lunch venue
    /// @dev To simplify the code duplication of friends is not checked
    /// @param friendAddress Friend ’s account address
    /// @param name Friend ’s name
    /// @return Number of friends added so far
    function addFriend ( address friendAddress , string memory name ) public addFriendAndVenuePhase restricted
        returns ( uint ){
        Friend memory f;
        f. name = name ;
        f. voted = false ;
        friends [ friendAddress ] = f ;
        numFriends++;
        return numFriends;
        }

    /// @notice Vote for a lunch venue
    /// @dev To simplify the code multiple votes by a friend is not checked
    /// @param venue Venue number being voted
    /// @return validVote Is the vote valid ? A valid vote should be from a registered end and to a registered venue
    function doVote ( uint venue ) public votingOpen lunchNotCancelled returns ( bool validVote ){
        validVote = false ; // Is the vote valid ?
        if ( bytes ( friends [ msg . sender ]. name ). length != 0) { // Does friend exist ?
            if (friends[msg.sender].voted == false) {  // Has friend already voted ?
                if ( bytes ( venues [ venue ]) . length != 0) { // Does venue exist ?
                    validVote = true ;
                    friends [msg . sender ]. voted = true ;
                    Vote memory v;
                    v. voterAddress = msg . sender ;
                    v. venue = venue ;
                    numVotes ++;
                    votes [ numVotes ] = v;
                }
            }
        }
        if ( numVotes >= numFriends /2 + 1) { // Quorum is met
            finalResult();
        }
        return validVote ;
        }
    /// @notice Determine winner venue
    /// @dev If top 2 venues have the same no of votes , final result depends on vote order
    function finalResult () private {
        uint highestVotes = 0;
        uint highestVenue = 0;
        for ( uint i = 1; i <= numVotes ; i++) { // For each vote
            uint voteCount = 1;
            if( results [ votes [i]. venue ] > 0) { // Already start counting
                voteCount += results [ votes [i]. venue ];
            }
            results [ votes [i]. venue ] = voteCount ;
            if ( voteCount > highestVotes ){ // New winner
                highestVotes = voteCount ;
                highestVenue = votes [i]. venue ;
            }
        }
        votedVenue = venues [ highestVenue ]; // Chosen lunch venue
        voteOpen = false ; // Voting is now closed
    }

    /// @notice allow manager to open voting
    function openVoting() public restricted {
        voteOpen = true;
    }

    /// @notice allow manager to cancel lunch whenever
    function cancelLunch() public restricted {
        lunchCancelled = true;
        votedVenue = 'No venue - lunch is cancelled';
    }

    /// @notice allow manager to uncancel lunch whenever
    function uncancelLunch() public restricted {
        lunchCancelled = false;
    }

    /// @notice allow manager to go into the voting phase
    function startVotingPhase() public restricted {
        lockFriendsAndVenues = true;
        openVoting();
    }

    function startEndPhase() public restricted {
        lockFriendsAndVenues = true;
        voteOpen = false;
    }

    /// @notice allow manager to initialise the votes
    function startAddFriendsAndVenuesPhase() public restricted {
        lockFriendsAndVenues = false;
        voteOpen = false;
    }

    /// @notice Only manager can do
    modifier lunchNotCancelled () {
        require ( lunchCancelled == false , "Cannot execute function while lunch is cancelled");
        _;
    }

    /// @notice Only manager can do
    modifier restricted () {
        require ( msg . sender == manager , "Can only be executed by the manager");
        _;
    }

    /// @notice Only whenb voting is still open
    modifier votingOpen () {
        require ( voteOpen == true , "Can vote only while voting is open .") ;
        _;
    }

    // @notice Only when in friend and venue phase
    modifier addFriendAndVenuePhase() {
        require (lockFriendsAndVenues == false, "Can only execute function in add friend and venue phase") ;
        _;
    }

    // @notice Only when in voting phase
    modifier votingPhase() {
        require (lockFriendsAndVenues == true, "Cannot execute function in voting phase") ;
        _;
    }

    // @notice Only when in voting phase
    modifier endPhase() {
        require (lockFriendsAndVenues == true && voteOpen == false, "Can only execute function in end phase") ;
        _;
    }

}